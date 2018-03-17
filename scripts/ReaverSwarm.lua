require("utils.lua")

ReaverSwarm = {
  reavers = {},
  originX = 0,
  originY = 0,
  radius = 0,
  size = 1,
  delays = {}
}

function ReaverSwarm:new(originX, originY, radius, size)
  local o = {
    reavers = {},
    originX = originX,
    originY = originY,
    radius = radius,
    size = size,
    delays = {}
  }
  setmetatable(o, self)
  self.__index = self
  return o
end


function ReaverSwarm:update(delta)
  if (#self.reavers < self.size) then
    local x, y = self:getDestination()
    local reaver = CpuShip():setTemplate("Phobos T3"):setFaction("Reavers"):setPosition(self.originX, self.originY):orderFlyTowardsBlind(x, y)
    table.insert(self.reavers, reaver)
    table.insert(self.delays, 0)
  end
  
  for i, reaver in ipairs(self.reavers) do
    if reaver:isValid() then
      self.delays[i] = self.delays[i] + delta
      if (self.delays[i] >= 0) then
        if reaver:areEnemiesInRange(self.radius * 0.5) then
          reaver:orderRoaming()
        elseif distance(reaver, self.originX, self.originY) > (0.95 * self.radius) then
          local x,y = self:getDestination()
          reaver:orderFlyTowardsBlind(x,y)
          self.delays[i] = -30 -- give the reaver time to turn around before giving it a new heading
        end
      end
    else
      table.remove(self.reavers, i)
      table.remove(self.delays, i)
    end
  end
end

function ReaverSwarm:getDestination()
  local angle = math.rad(random(1, 360))
  local x = (math.cos(angle) * self.radius) + self.originX
  local y = (math.sin(angle) * self.radius) + self.originY
  return x, y
end