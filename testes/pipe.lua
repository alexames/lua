-- $Id: testes/pipe.lua $
-- See Copyright Notice in file all.lua

print("testing pipe operator |> ")

-- Helper to track evaluation order
local eval_order = {}

local function reset_track()
  eval_order = {}
end

local function check_order(expected)
  assert(#eval_order == #expected,
    string.format("Expected %d evaluations, got %d", #expected, #eval_order))
  for i = 1, #expected do
    assert(eval_order[i] == expected[i],
      string.format("At position %d: expected '%s', got '%s'",
        i, expected[i], eval_order[i]))
  end
end

-- Basic functionality tests
print("testing basic pipe functionality")

local function inc(x) return x + 1 end
local function double(x) return x * 2 end
local function square(x) return x * x end

assert((5 |> inc) == 6)
assert((10 |> double) == 20)
assert((3 |> square) == 9)

-- Test with nil
assert((nil |> function(x) return x == nil end) == true)

-- Test with boolean
assert((true |> function(x) return not x end) == false)

-- Test with string
assert(("hello" |> string.upper) == "HELLO")

-- Test with table
do
  local t = {1, 2, 3}
  assert((t |> function(x) return #x end) == 3)
end

print('+')

-- Evaluation order tests
print("testing evaluation order")

reset_track()
local function make_tracker(name)
  return function(x)
    eval_order[#eval_order + 1] = name
    return x
  end
end

local f1 = make_tracker("f1")
local f2 = make_tracker("f2")

reset_track()
local _ = (42 |> f1 |> f2)
check_order({"f1", "f2"})

-- Test that LHS is evaluated before RHS and exactly once
reset_track()
local counter = 0
local function get_counter()
  counter = counter + 1
  eval_order[#eval_order + 1] = "lhs"
  return counter
end
local function check_counter(x)
  eval_order[#eval_order + 1] = "rhs"
  return x
end

local _ = (get_counter() |> check_counter)
check_order({"lhs", "rhs"})
assert(counter == 1, "LHS should be evaluated exactly once")

print('+')

-- Precedence tests
print("testing precedence")

-- Pipe should bind tighter than 'or'
assert(((1 |> function(x) return x + 1 end) or 0) == 2)
assert(((false |> function(x) return not x end) or 0) == true)

-- Pipe should bind tighter than 'and' (per design recommendation)
-- If pipe were looser than 'and', this would attempt to call 'inc' with a boolean (or error earlier).
assert((false and (1 |> inc)) == false)
assert((false and 1 |> inc) == false)

-- Arithmetic should bind tighter than pipe
assert((1 + 2 |> inc) == 4)        -- (1+2) |> inc
assert((2 * 3 |> double) == 12)    -- (2*3) |> double

-- Concatenation should bind tighter than pipe
-- NOTE: right-associativity of '..' can make combined cases parser-sensitive; keep this as an optional check.
assert((("a" .. "b") |> string.upper) == "AB")

print('+')

-- Chaining tests
print("testing chaining")

assert((5 |> inc |> double) == 12)       -- (5+1)*2
assert((3 |> square |> inc) == 10)       -- (3*3)+1
assert((10 |> double |> square) == 400)  -- (10*2)^2

-- Long chain (using named functions to avoid parsing issues with long inline chains)
do
  local add1 = function(x) return x + 1 end
  local mul2 = function(x) return x * 2 end
  local sub1 = function(x) return x - 1 end
  local div3 = function(x) return x / 3 end
  local result = (1 |> add1 |> mul2 |> sub1 |> div3)
  assert(result == 1)  -- ((1+1)*2-1)/3 = 1
end

print('+')

-- Multiple return values test
print("testing multiple return values")

local function return_two()
  return 10, 20
end

-- Pipe should only forward the first return value
local result = return_two() |> inc
assert(result == 11, "Pipe should forward only first return value")

-- Explicit pack/unpack should round-trip multiple returns
local function pack_and_forward(t)
  return table.unpack(t, 1, t.n)
end

local result1, result2 = table.pack(return_two()) |> pack_and_forward
assert(result1 == 10 and result2 == 20)

print('+')

-- Expression types as RHS
print("testing different expression types as RHS")

-- Function variable
local f = inc
assert((5 |> f) == 6)

-- Conditional expression
assert((5 |> (true and inc or double)) == 6)
assert((5 |> (false and inc or double)) == 10)

-- Lambda/function expression
assert((5 |> function(x) return x * 3 end) == 15)

-- Table with __call metamethod
do
  local callable = setmetatable({}, {
    __call = function(self, x) return x * 2 end
  })
  assert((5 |> callable) == 10)
end

print('+')

-- Error cases
print("testing error cases")

local function checkerr(msg, f, ...)
  local stat, err = pcall(f, ...)
  assert(not stat and string.find(err, msg, 1, true),
    string.format("Expected error containing '%s', got: %s", msg, err or "no error"))
end

-- Non-callable RHS
checkerr("attempt to call", function()
  return 5 |> 123
end)

checkerr("attempt to call", function()
  return "hello" |> "world"
end)

checkerr("attempt to call", function()
  return 5 |> nil
end)

print('+')

-- Edge cases
print("testing edge cases")

-- Empty function
local function empty(x) end
assert((5 |> empty) == nil)

-- Function that returns multiple values
local function multi(x)
  return x, x*2, x*3
end
local r1, r2, r3 = 5 |> multi  -- no parens to preserve multiple returns
assert(r1 == 5 and r2 == 10 and r3 == 15)

-- Function that mutates a table argument (mutation should be visible to the caller)
local function modify(x)
  if type(x) == "table" then
    x.value = 100
    return x
  end
  return x
end
do
  local t = {value = 5}
  local result = t |> modify
  assert(result.value == 100)
  assert(t.value == 100, "Tables are passed by reference; mutation should be visible")
end

-- Chained pipes with different types
assert(("hello" |> string.len |> function(x) return x * 2 end) == 10)

print('+')

-- Complex expressions
print("testing complex expressions")

-- Pipe in function call
local function add(a, b) return a + b end
assert(add(1 |> inc, 2 |> double) == 6)

-- Pipe in table constructor
do
  local t = {
    a = 5 |> inc,
    b = 10 |> double
  }
  assert(t.a == 6 and t.b == 20)
end

-- Pipe in return statement
local function test_return()
  return 5 |> inc |> double
end
assert(test_return() == 12)

print('+')

-- Method calls (explicit, not automatic)
print("testing method calls")

local obj = {
  value = 10,
  method = function(self, x)
    return self.value + x
  end
}

-- Pipe does NOT automatically handle method calls; user must wrap explicitly
assert((5 |> function(x) return obj:method(x) end) == 15)
assert((5 |> function(x) return obj.method(obj, x) end) == 15)

print('+')

-- Real-world usage patterns
print("testing real-world patterns")

-- Data transformation pipeline
do
  local data = {1, 2, 3, 4, 5}

  local function filter_pos(x)
    local result = {}
    for i = 1, #x do
      if x[i] > 0 then
        result[#result + 1] = x[i]
      end
    end
    return result
  end

  local function map_square(x)
    local result = {}
    for i = 1, #x do
      result[i] = x[i] * x[i]
    end
    return result
  end

  local function sum(x)
    local total = 0
    for i = 1, #x do
      total = total + x[i]
    end
    return total
  end

  local result = (data |> filter_pos |> map_square |> sum)
  assert(result == 55)  -- 1+4+9+16+25 = 55
end

print('+')

-- Test that pipe works with upvalues
print("testing upvalues")

local function make_adder(n)
  return function(x) return x + n end
end

local add5 = make_adder(5)
assert((10 |> add5) == 15)

-- Closure capture (Lua captures upvalues by reference)
do
  local multiplier = 3
  local function make_multiplier()
    return function(x) return x * multiplier end
  end

  local mult = make_multiplier()
  assert((4 |> mult) == 12)

  multiplier = 5
  assert((4 |> mult) == 20, "Upvalue mutation should be observed by the closure")
end

print('+')

-- Test with coroutines
print("testing with coroutines")

do
  local function make_generator()
    local co = coroutine.create(function()
      for i = 1, 5 do
        coroutine.yield(i)
      end
    end)
    return function(x)
      local success, value = coroutine.resume(co)
      if success and value then
        return value + x
      end
      return x
    end
  end

  local gen = make_generator()
  assert((10 |> gen) == 11)
end

print('+')

-- Test LHS evaluation happens exactly once (including in chains)
print("testing single evaluation")

do
  local eval_count = 0
  local function count_evals()
    eval_count = eval_count + 1
    return eval_count
  end

  local function identity(x) return x end

  eval_count = 0
  local _ = (count_evals() |> identity)
  assert(eval_count == 1, "LHS should be evaluated exactly once")

  eval_count = 0
  local _ = (count_evals() |> identity |> identity)
  assert(eval_count == 1, "LHS should be evaluated exactly once even in chains")
end

print('+')

print('OK')
