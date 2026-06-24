-- Reflection, identity, and edge-case tests for typed functions.
--
-- A typed function literal compiles to a callable table built by the base
-- library's 'make_typed_function'. This suite pins the reflective surface
-- (the 'target' / 'parameter_types' / 'return_types' fields), the hand-written
-- equivalence, the method / recursion / nil-hole semantics, and the deliberate
-- 'type(f) == "table"' consequence (see the §7 trade-off in the design notes).

local passed = 0
local failed = 0

local function check(name, ok, msg)
  if ok then
    passed = passed + 1
  else
    failed = failed + 1
    print("FAIL: " .. name .. (msg and (" - " .. msg) or ""))
  end
end


-- Ad-hoc type objects (a "type" is any value with an __isinstance method).
local function maketype(name, pred)
  local t = setmetatable({}, {
    __name = name,
    __tostring = function() return name end,
  })
  t.__isinstance = function(_, v) return pred(v) end
  return t
end

local Number = maketype("Number", function(v) return type(v) == "number" end)
local String = maketype("String", function(v) return type(v) == "string" end)
local Table  = maketype("Table",  function(v) return type(v) == "table" end)
local Any    = maketype("Any",    function(v) return true end)


-- Recover the one shared metatable from a sample wrapper, and build the thin
-- reflection helpers the design documents (kept local; the only public builtin
-- is 'make_typed_function').
local TypedFunctionMT = getmetatable(make_typed_function{
  target = function() end,
  parameter_types = table.pack(),
  return_types = table.pack(),
})

local function is_typed_function(v)  return getmetatable(v) == TypedFunctionMT end
local function parameter_types_of(f) return f.parameter_types end
local function return_types_of(f)    return f.return_types end
local function unwrap(f)             return is_typed_function(f) and f.target or f end


-- Reflection --------------------------------------------------------------
do
  local function mixed(a: Number, b, c: String): Number
    return a
  end
  check("is_typed_function true", is_typed_function(mixed))
  check("is_typed_function false (plain)", not is_typed_function(function() end))
  check("is_typed_function false (number)", not is_typed_function(42))

  local pt = parameter_types_of(mixed)
  check("parameter_types.n counts all positions", pt.n == 3)
  check("parameter_types[1] is the type object", pt[1] == Number)
  check("parameter_types[2] is a nil hole", pt[2] == nil)
  check("parameter_types[3] is the type object", pt[3] == String)

  local rt = return_types_of(mixed)
  check("return_types.n", rt.n == 1)
  check("return_types[1]", rt[1] == Number)

  check("target is a raw function", type(mixed.target) == "function")
  check("unwrap bypasses checks", unwrap(mixed)("not a number") == "not a number")
end


-- Hand-written equivalence ------------------------------------------------
do
  local sugared = function(a: Number, b, c: String): Number return a end
  local byhand = make_typed_function{
    target          = function(a, b, c) return a end,
    parameter_types = table.pack(Number, nil, String),
    return_types    = table.pack(Number),
  }
  check("hand-built has same metatable", getmetatable(sugared) == getmetatable(byhand))
  check("hand-built type is table", type(byhand) == "table")
  check("hand-built parameter_types.n", byhand.parameter_types.n == 3)
  check("hand-built parameter_types hole", byhand.parameter_types[2] == nil)
  local ok1 = pcall(sugared, 1, "x", "y")
  local ok2 = pcall(byhand, 1, "x", "y")
  check("sugared and hand-built both accept", ok1 and ok2)
  local bad1 = pcall(sugared, "x", "x", "y")
  local bad2 = pcall(byhand, "x", "x", "y")
  check("sugared and hand-built both reject", not bad1 and not bad2)
end


-- Return arity with interior nils -----------------------------------------
do
  -- Return types that accept nil (Any) let the table.pack return path preserve
  -- a 1, nil, 3 result; a '{ t.target(...) }' body would truncate it to arity 1.
  local function three(): Any, Any, Any
    return 1, nil, 3
  end
  local a, b, c = three()
  check("interior nil returns round-trip", a == 1 and b == nil and c == 3)
  check("interior nil return arity", select("#", three()) == 3)

  -- Hand-built wrapper with a nil hole in return_types: position #2 is never
  -- checked, and the three values still come back.
  local byhand = make_typed_function{
    target = function() return 1, nil, 3 end,
    parameter_types = table.pack(),
    return_types = table.pack(Number, nil, Number),  -- {[1]=Number,[3]=Number,n=3}
  }
  check("nil hole in return_types is unchecked", select("#", byhand()) == 3)
  local x, y, z = byhand()
  check("hand-built interior nil round-trips", x == 1 and y == nil and z == 3)
end


-- nil-hole iteration: checking uses 1..n, never ipairs (which stops at a hole)
do
  -- typed #1, untyped #2..#3: a leading typed param with trailing holes.
  local function lead(a: Number, b, c)
    return a
  end
  check("nil-hole .n is authoritative", lead.parameter_types.n == 3)
  local ipairscount = 0
  for _ in ipairs(lead.parameter_types) do ipairscount = ipairscount + 1 end
  check("nil-hole ipairs undercounts (stops at first hole)", ipairscount == 1)
  check("nil-hole still checks position 1", not pcall(lead, "x", 1, 2))
  check("nil-hole passes others through", (lead(5, "anything", {})) == 5)
end


-- Methods: argument_offset skips self; self is never checked ---------------
do
  local obj = { total = 0 }
  function obj:add(n: Number): Number
    self.total = self.total + n
    return self.total
  end
  check("method is typed", is_typed_function(obj.add))
  check("method has argument_offset 1", obj.add.argument_offset == 1)
  check("method parameter_types.n excludes self", obj.add.parameter_types.n == 1)
  check("method call works", (obj:add(10)) == 10 and obj.total == 10)
  check("method checks param #1, not self", not pcall(function() return obj:add("x") end))
  -- error numbering is over explicit params (self is #0/never numbered)
  local _, err = pcall(function() return obj:add("x") end)
  check("method error blames #1", err:find("#1") ~= nil)
end


-- Recursion ---------------------------------------------------------------
do
  -- param-only typed recursion keeps TCO (fast path) -> O(1) stack at depth.
  local function countdown(n: Number)
    if n == 0 then return "done" end
    return countdown(n - 1)
  end
  check("param-only deep recursion (TCO)", countdown(1000000) == "done")

  -- return-typed recursion loses TCO (documented), but still computes.
  local function sum(n: Number): Number
    if n == 0 then return 0 end
    return n + sum(n - 1)
  end
  check("return-typed recursion computes", sum(100) == 5050)
end


-- Identity consequences (pin the deliberate trade-off, §7) -----------------
do
  local f = function(x: Number): Number return x end
  check("typed function is a table", type(f) == "table")
  check("coroutine.create on wrapper errors", not pcall(coroutine.create, f))
  check("coroutine.create on target works", pcall(coroutine.create, unwrap(f)))
  check("string.dump on wrapper errors", not pcall(string.dump, f))
  check("string.dump on target works", pcall(string.dump, unwrap(f)))
  -- silent case: a typed function in an __index slot is treated as a table.
  local proxy = setmetatable({}, { __index = f })
  check("typed function as __index returns nil (silent)", proxy.whatever == nil)
  check("tostring is honest", tostring(f):find("typed function") ~= nil)
end


-- Decorator order: @deco applies around the type contract ------------------
do
  local function trace(t, k, v)
    return t, k, function(...) return "<" .. tostring(v(...)) .. ">" end
  end
  do
    @trace
    local function g(x: Number): Number return x * 2 end
    check("decorator wraps typed local", (g(4)) == "<8>")
  end
  -- decorator over a typed global funcstat
  do
    DecoTarget = nil
    @trace
    function DecoTarget(x: Number): Number return x + 1 end
    check("decorator wraps typed funcstat", (DecoTarget(4)) == "<5>")
    DecoTarget = nil
  end
  -- NOTE: '@deco function obj:m(...)' (decorator over a *method*) is a
  -- pre-existing limitation of the decorator feature on this base branch
  -- (it crashes even with no type annotations), so it is not exercised here.
end


-- Lambdas with types ------------------------------------------------------
do
  local sq = $(x: Number) x * x
  check("lambda typed param", (sq(5)) == 25 and is_typed_function(sq))
  check("lambda typed param rejects", not pcall(sq, "x"))

  -- non-delimited return-typed lambda body (Test-12 form)
  local sq2 = $(x: Number): Number x * x
  check("lambda typed return (expr body)", (sq2(6)) == 36)

  -- delimited return-typed lambda body
  local sq3 = $(x: Number): Number do return x * x end
  check("lambda typed return (do body)", (sq3(7)) == 49)

  -- greedy hazard: a return type followed by a string/paren/table body is
  -- swallowed into a call; as the sole expression it fails to parse cleanly.
  check("greedy return-typed lambda errors", load("return $(x): Number \"hi\"") == nil)
end


-- Trigger rule: no annotation anywhere => plain closure, zero overhead ------
do
  local function plain(a, b) return a, b end
  check("untyped stays a function", type(plain) == "function")
  check("untyped not a typed function", not is_typed_function(plain))
  local lam = $(x) x
  check("untyped lambda stays a function", type(lam) == "function")
end


print(string.format("\n%d passed, %d failed, %d total", passed, failed, passed + failed))
if failed > 0 then
  error(string.format("%d test(s) failed!", failed))
end
