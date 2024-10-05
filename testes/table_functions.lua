t = {
  function()
    print('Anonymous table with index key!')
  end,

  f = function()
    print('Anonymous table with string key!')
  end,

  function named_function()
    print('New named function, success!')
  end,
}

t[1]()
t.f()
t.named_function()
