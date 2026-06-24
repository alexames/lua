-- Runtime type checking tests

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

-- Define simple type objects with __isinstance metamethods
local Number = setmetatable({}, {
  __name = "Number",
  __tostring = function() return "Number" end,
})
Number.__isinstance = function(self, v) return type(v) == "number" end

local String = setmetatable({}, {
  __name = "String",
  __tostring = function() return "String" end,
})
String.__isinstance = function(self, v) return type(v) == "string" end

local Bool = setmetatable({}, {
  __name = "Bool",
  __tostring = function() return "Bool" end,
})
Bool.__isinstance = function(self, v) return type(v) == "boolean" end

local Table = setmetatable({}, {
  __name = "Table",
  __tostring = function() return "Table" end,
})
Table.__isinstance = function(self, v) return type(v) == "table" end

local Any = setmetatable({}, {
  __name = "Any",
  __tostring = function() return "Any" end,
})
Any.__isinstance = function(self, v) return true end


-- Test 1: Basic typed parameter (passing)
do
  local function add(a: Number, b: Number)
    return a + b
  end
  local ok, result = pcall(add, 10, 20)
  check("basic typed params pass", ok and result == 30)
end


-- Test 2: Basic typed parameter (failing)
do
  local function add(a: Number, b: Number)
    return a + b
  end
  local ok, err = pcall(add, "hello", 20)
  check("basic typed params fail", not ok)
  check("error mentions argument number", err:find("#1"))
  check("error mentions expected type", err:find("Number"))
end


-- Test 3: Mixed typed and untyped parameters
do
  local function mixed(a: Number, b, c: String)
    return tostring(a) .. b .. c
  end
  local ok, result = pcall(mixed, 42, "-", "hello")
  check("mixed typed/untyped pass", ok and result == "42-hello")

  local ok2, err2 = pcall(mixed, 42, "-", 123)
  check("mixed typed/untyped fail on typed", not ok2)
  check("fails on correct argument", err2:find("#3"))
end


-- Test 4: Return type checking (single)
do
  local function getnum(): Number
    return 42
  end
  local ok, result = pcall(getnum)
  check("return type pass", ok and result == 42)

  local function getnum_bad(): Number
    return "not a number"
  end
  local ok2, err2 = pcall(getnum_bad)
  check("return type fail", not ok2)
  check("return error mentions expected", err2:find("Number"))
end


-- Test 5: Multiple return type checking
do
  local function getPair(): Number, String
    return 10, "hello"
  end
  local ok, a, b = pcall(getPair)
  check("multi return type pass", ok and a == 10 and b == "hello")

  local function getPair_bad(): Number, String
    return "oops", "hello"
  end
  local ok2, err2 = pcall(getPair_bad)
  check("multi return type fail on first", not ok2)
  check("multi return error mentions #1", err2:find("#1"))

  local function getPair_bad2(): Number, String
    return 10, 20
  end
  local ok3, err3 = pcall(getPair_bad2)
  check("multi return type fail on second", not ok3)
  check("multi return error mentions #2", err3:find("#2"))
end


-- Test 6: Type annotations are expressions evaluated at definition time
do
  local mytype = Number
  local function foo(a: mytype)
    return a
  end
  -- Change mytype after definition - should not affect the check
  mytype = String
  local ok, result = pcall(foo, 42)
  check("type evaluated at definition time", ok and result == 42)

  local ok2, err2 = pcall(foo, "hello")
  check("type evaluated at def time (fail)", not ok2)
end


-- Test 7: No type annotation means no check
do
  local function notype(a, b)
    return a, b
  end
  local ok, a, b = pcall(notype, 1, "hello")
  check("no annotations passes anything", ok and a == 1 and b == "hello")
end


-- Test 8: Function with both param and return types
do
  local function double(x: Number): Number
    return x * 2
  end
  local ok, result = pcall(double, 5)
  check("param and return types pass", ok and result == 10)

  local ok2, err2 = pcall(double, "five")
  check("param type catches bad input", not ok2)
end


-- Test 9: Custom type with __isinstance
do
  local PositiveNumber = setmetatable({}, {
    __name = "PositiveNumber",
    __tostring = function() return "PositiveNumber" end,
  })
  PositiveNumber.__isinstance = function(self, v)
    return type(v) == "number" and v > 0
  end

  local function abs_val(x: PositiveNumber)
    return x
  end
  local ok, result = pcall(abs_val, 42)
  check("custom isinstance pass", ok and result == 42)

  local ok2, err2 = pcall(abs_val, -5)
  check("custom isinstance fail", not ok2)
  check("custom error mentions type", err2:find("PositiveNumber"))
end


-- Test 10: Anonymous function with types
do
  local f = function(x: Number): String
    return tostring(x)
  end
  local ok, result = pcall(f, 42)
  check("anonymous func type pass", ok and result == "42")

  local ok2, err2 = pcall(f, "hello")
  check("anonymous func type fail", not ok2)
end


-- Test 11: Lambda with types
do
  local square = $(x: Number) x * x
  local ok, result = pcall(square, 5)
  check("lambda typed param pass", ok and result == 25)

  local ok2, err2 = pcall(square, "five")
  check("lambda typed param fail", not ok2)
end


-- Test 12: Lambda with return type
do
  local square = $(x: Number): Number x * x
  local ok, result = pcall(square, 5)
  check("lambda typed return pass", ok and result == 25)
end


-- Test 13: Bare return with return types should not crash
do
  local function maybe(x: Bool): Number
    if not x then return end
    return 42
  end
  local ok, result = pcall(maybe, true)
  check("bare return with ret type (good)", ok and result == 42)

  local ok2, result2 = pcall(maybe, false)
  check("bare return with ret type (bare)", ok2 and result2 == nil)
end


-- Test 14: Error message format (expected and got types)
do
  local function MyFunc(x: Number)
    return x
  end
  local ok, err = pcall(MyFunc, "bad")
  check("error has expected type", not ok and err:find("Number"))
  check("error has got type", err:find("string"))
end


-- Test 15: Type as table field expression
do
  local Types = { num = Number, str = String }
  local function foo(a: Types.num, b: Types.str)
    return tostring(a) .. b
  end
  local ok, result = pcall(foo, 42, "hello")
  check("type from table field pass", ok and result == "42hello")

  local ok2, err2 = pcall(foo, "bad", "hello")
  check("type from table field fail", not ok2)
end


-- Print summary
print(string.format("\n%d passed, %d failed, %d total", passed, failed, passed + failed))
if failed > 0 then
  error(string.format("%d test(s) failed!", failed))
end
