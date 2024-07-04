--------------------------------------------------------------------------------
-- Example decorators

function call_twice(f)
  local f = function(...)
    f(...)
    f(...)
  end
  return f
end

function square(v)
  return v * v
end

decorators = {
  math = {
    double = function(f)
      return function(...)
        return 2 * f(...)
      end
    end
  }
}

--------------------------------------------------------------------------------
-- Local function test
@call_twice
local function local_test(s)
  print('local_test: ', s)
end
local_test('Hello, World!')

-- Global function test
@call_twice
function test(s)
  print('test: ', s)
end
test('Goodbye, World!')

-- -- Table function test
--[[
table_test = {
  @call_twice
  f = function(s)
    print('table_test', s)
  end
}
print(table_test.f('world world world?'))
]]

-- Local variable test
@square
local x = 2
print(x)

-- Global variable test
@square
y = 5
print(y)

-- Table function test
--[[
table_test = {
  @square
  z = 10
}
print(table_test.z)
]]

