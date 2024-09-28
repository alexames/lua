-- Lua extension: Compound operator

local add_test = 10
add_test += 20
assert(add_test == 30)

local sub_test = 30
sub_test -= 20
assert(sub_test == 10)

local mult_test = 10
mult_test *= 20
assert(mult_test == 200)

local div_test = 30
div_test /= 10
assert(div_test == 3)

local lshift_test = 0x0101
lshift_test <<= 4
assert(lshift_test == 0x1010)

local lshift_test = 0x1010
lshift_test >>= 4
assert(lshift_test == 0x0101)

local band_test = 0xFEFF
band_test &= 0x0101
assert(band_test == 0x0001)

local band_test = 0x0101
band_test |= 0x1010
assert(band_test == 0x1111)

local band_test = 0x0F0F
band_test ^= 0xFFFF
assert(band_test == 0xF0F0)
