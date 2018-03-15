ReaverSwarm = {
  reavers = {},
  spawnPoints = {},
  size = 1,
  accumulatedDelta = 0
}

function ReaverSwarm:new(size, spawnPoints)
  local o = {}
  o.spawnPoints = spawnPoints
  o.size = size 
  setmetatable(o, self)
  self.__index = self
  return o
end

function ReaverSwarm:grow()
  self.size = self.size + 1
end

function ReaverSwarm:update(delta)
  self.accumulatedDelta = self.accumulatedDelta + delta
  
  if self.accumulatedDelta < 60 then
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
    local spawnPointIndex = math.random(1, #self.spawnPoints)
    local x, y = self.spawnPoints[spawnPointIndex]:getPosition()
    local reaver = CpuShip():setTemplate("Phobos T3"):setFaction("Reavers"):setPosition(x, y):orderRoaming()
    table.insert(self.reavers, reaver)
  end
end