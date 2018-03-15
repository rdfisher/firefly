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

function CivilianGroup:getPosition()
  local numberOfCivilians = #self.civilians
  if numberOfCivilians == 0 then
    return 0, 0
  end
  local xTotal = 0;
  local yTotal = 0;
  for i, civilian in ipairs(self.civilians) do
    if civilian:isValid() then
      local x, y = civilian:getPosition()
      xTotal = xTotal + x
      yTotal = yTotal + y
    else -- auto clean up ? 
      table.remove(self.civilians, i)
    end
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
  return #self.civilians
end
