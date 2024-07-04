
decorators = {
  square = function(t, k, v)
    return t, k, v * v
  end,

  calltwice = function(t, k, v)
    return t, k, function(...)
      v(...)
      v(...)
    end
  end,
}

-- globals ---------------------------------------------------------------------
@decorators.square
x = 5

@decorators.calltwice
function printhello()
  print 'Hello!'
end

print(x)
printhello()

-- locals ----------------------------------------------------------------------
@decorators.square
local x = 5

@decorators.calltwice
local function printhello()
  print 'Hello!'
end

print(x)
printhello()

-- table -----------------------------------------------------------------------
t = {
  @decorators.square
  x = 5,

  @decorators.calltwice
  printhello = function()
    print 'Hello!'
  end,
}

print(t.x)
t.printhello()
