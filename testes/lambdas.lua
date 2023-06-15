
function transform(list, predicate)
  for i=1, #list do
    list[i] = predicate(i, list[i])
  end
end


-- Test single-statement lambda
local list = {1, 2, 3}
transform(list, $(i, v) v * 2)
for i, v in ipairs(list) do
  print(i, v)
end


-- Test multi-statement lambda
local list = {10, 20, 30}
transform(list, $(i, v) do
  local result = v * 2
  print('Doubling ' .. v .. ' to ' .. result)
  return result
end)
for i, v in ipairs(list) do
  print(i, v)
end


-- Test function call single-statement syntactic sugar
local list = {
  1, 2, 3,

  foreach = function(self, f)
    for i, v in ipairs(self) do
      f(i, v)
    end
  end
}
list:foreach $(i, v) print(i, v)


-- Test function call multi-statement syntactic sugar
local list = {
  1, 2, 3,

  foreach = function(self, f)
    for i, v in ipairs(self) do
      f(i, v)
    end
  end
}
list:foreach $(i, v) do
  print(i, v)
end