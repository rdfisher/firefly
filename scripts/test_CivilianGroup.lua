local lu = require "luaunit"
dofile "CivilianGroup.lua"

-- stub class for a ship
Ship = {}
function Ship:new (_name, _x, _y, _valid) 
  local o = {
    name = _name,
    x = _x,
    y = _y,
    valid = _valid
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function Ship:getPosition()
  return self.x, self.y
end

function Ship:isValid()
  return self.valid
end


group1 = CivilianGroup:new()

local x, y = group1:getPosition()
lu.assertEquals(x, 0)
lu.assertEquals(y, 0)

ship1 = Ship:new("ship1", 100, 200, true)
ship2 = Ship:new("ship2", -100, 300, false)

group1:add(ship1)
group1:add(ship2)

lu.assertEquals(group1:getSize(), 2)

x, y = group1:getPosition()
lu.assertEquals(x, 0)
lu.assertEquals(y, 250)

group1:cleanup()
lu.assertEquals(group1:getSize(), 1)
x, y = group1:getPosition()
lu.assertEquals(x, 100)
lu.assertEquals(y, 200)
