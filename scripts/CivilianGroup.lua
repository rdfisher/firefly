CivilianGroup = {
  civilians = {}
}

function CivilianGroup:new ()
  local o = {civilians = {}}
  setmetatable(o, self)
  self.__index = self
  return o
end

function CivilianGroup:add(civilian) 
  table.insert(self.civilians, civilian)
end

function CivilianGroup:getGeographicCentre()
  local numberOfCivilians = table.getn(self.civilians)
  local xTotal = 0;
  local yTotal = 0;
  for _, civilian in ipairs(self.civilians) do
    local x, y = civilian:getPosition()
    xTotal = xTotal + x
    yTotal = yTotal + y
  end
  local xMean = xTotal / numberOfCivilians
  local yMean = yTotal / numberOfCivilians
  return xMean, yMean
  
end

function CivilianGroup:cleanup()
  for i, civilian in ipairs(self.civilians) do
    if not civilian:isValid() then
      table.remove(self.civilians, i)
    end
  end
end

function CivilianGroup:getSize()
  return table.getn(self.civilians)
end