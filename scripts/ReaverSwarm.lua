ReaverSwarm = {
  reavers = {},
  x = 0,
  y = 0,
  size = 1,
  targets = {},
  accumulatedDelta = 0
}

function ReaverSwarm:new(size, x, y, targets)
  local o = {}
  o.x = x
  o.y = y
  o.size = size 
  o.targets = targets
  setmetatable(o, self)
  self.__index = self
  return o
end

function ReaverSwarm:grow()
  self.size = self.size + 1
end

function ReaverSwarm:update(delta)
  self.accumulatedDelta = self.accumulatedDelta + delta
  
  if self.accumulatedDelta < 10 then
    return 0
  end
  
  self.accumulatedDelta = 0
  
  -- prune dead reavers
  for i, reaver in ipairs(self.reavers) do
    if not reaver:isValid() then
      table.remove(self.reavers, i)
    end
  end
  
  -- spawn a new one if necessary
  if #self.reavers < self.size then
    local reaver = CpuShip():setTemplate("Phobos T3"):setFaction("Reavers"):setPosition(self.x, self.y)
    local targetNumber =  math.floor(random(1, #self.targets + 0.99))
    local targetCaptain = self.targets[targetNumber]
    local target = targetCaptain.ship
    print(target:getCallSign())
    reaver:orderAttack(target)
    print(string.format("Reaver %s is hunting", reaver:getCallSign()))
    table.insert(self.reavers, reaver)
  end
end