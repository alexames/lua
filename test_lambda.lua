
--------------------------------------------------------------------------------
-- Simple list example
List = {}
function List.new(t)
  return setmetatable(t, List)
end
function List:xform(p)
  for i, v in ipairs(self) do
    self[i] = p(v)
  end
end
List.__index = List

-- Test xform lambda
list = List.new{1, 2, 3}
list:xform $(v) v * 2

-- Check values
for i, v in ipairs(list) do
  print(i, v)
end

--------------------------------------------------------------------------------
-- python style `with` statement
local function with(...)
  return {
    __args = {...},
    __opened_args = {},
    as = function(self, f)
      local args = self.__args
      local opened_args = self.__opened_args
      function with_helper(f, v, ...)
        if v ~= nil then
          local mt = getmetatable(v)
          local success, result = pcall(mt.__open, v)
          if not success then
            error(result)
          end
          table.insert(self.__opened_args, result)
          local success, result = pcall(with_helper, f, ...)
          mt.__close(v, success, result)
          if not success then
            error(result)
          end
        else
          f(table.unpack(opened_args))
        end
      end
      with_helper(f, table.unpack(args))
    end
  }
end

-- Simple fake file 'class'
File = {}
function File.new(filename)
  return setmetatable({__filename = filename, __contents = 'empty file'}, File)
end
function File:__open()
  print('opening ' .. self.__filename)
  self.__contents = self.__filename .. self.__filename .. self.__filename
  return self
end
function File:__close()
  self.__contents = 'empty file'
  print('closing ' .. self.__filename)
end
function File:read()
  return self.__contents
end
File.__index = File

with (File.new('fn1')) :as $(file) do
  print(file:read())
end
