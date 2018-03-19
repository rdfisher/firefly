require("utils.lua")

ReaverSwarm = {
  reavers = {},
  originX = 0,
  originY = 0,
  radius = 0,
  size = 1,
  delays = {},
  callsignStart = "RV",
  callsignIndex = 1,
  borderX = 0,
  eruptionTime = 600,
  accumulatedTime = 590,
  hostility = 3
}

function ReaverSwarm:new(originX, originY, radius, size, callsignStart)
  local o = {
    reavers = {},
    originX = originX,
    originY = originY,
    radius = radius,
    size = size,
    delays = {},
    callsignStart = callsignStart,
    callsignIndex = 1
  }
  setmetatable(o, self)
  self.__index = self

  --minefield on the border
  local mineSpacing = math.ceil((1 * radius) / size)
  local borderX = originX + radius
  if originX > 0 then
    borderX = originX - radius
  end
  self.borderX = borderX
  createObjectsOnLine(borderX, originY - (2 * radius), borderX, originY + (2 * radius), mineSpacing, Mine, 1, 100, math.ceil(radius / 4))
  return o
end

function ReaverSwarm:getRandomBorderPoint()
  local borderY = (math.random(1, self.radius) + self.originY) - (self.radius / 2)
  return self.borderX, borderY
end

function ReaverSwarm:update(delta)  
  if (#self.reavers < self.size) then
    
    local r = random(0, 360)
    local distance = random(0, self.radius)
    x0 = self.originX + math.cos(r / 180 * math.pi) * distance
    y0 = self.originY + math.sin(r / 180 * math.pi) * distance
    
    local x, y = self:getDestination()
    local reaver = CpuShip():setTemplate("Phobos T3"):setFaction("Reavers"):setPosition(x0, y0):orderFlyTowards(x, y)
    local callsign = self.callsignStart .. self.callsignIndex
    reaver:setCallSign(callsign)
    self.callsignIndex = self.callsignIndex + 1
    reaver:setWarpDrive(true)
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
  
  self.accumulatedTime = self.accumulatedTime + delta
  
  if self.accumulatedTime > self.eruptionTime then
    self.accumulatedTime = 0
    self:erupt(self.hostility)
  end
end

function ReaverSwarm:getDestination()
  local angle = math.rad(random(1, 360))
  local x = (math.cos(angle) * self.radius) + self.originX
  local y = (math.sin(angle) * self.radius) + self.originY
  return x, y
end

function ReaverSwarm:erupt(count)
  print("REAVER ERUPTION")
  -- remove 3 reavers from the array, order them to roam
  for i=1,count do
    local reaver = table.remove(self.reavers)
    reaver:orderRoaming()
    print("ROAMING: " .. reaver:getCallSign())
  end
end