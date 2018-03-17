Browncoat = {
    ship = {},
    missions = {},
    missionsCompleted = 0,
    misbehaving = 0
}

function Browncoat:new(ship)
    local o = {}
    o.ship = ship
    setmetatable(o, self)
    self.__index = self
    ship:setReputationPoints(1000)
    return o
end

function Browncoat:update(delta)
  if self.misbehaving > 0 then
    local tookReputation = self.ship:takeReputationPoints(delta * self.misbehaving)
    if (not tookReputation) then
      self.ship:setReputationPoints(0)
    end
  else
    if self.ship:getReputationPoints() < 1000 then
      self.ship:addReputationPoints(delta)
    end
  end  
  
  for _, mission in ipairs(self.missions) do
    mission:update(delta)
  end
end

function Browncoat:startMisbehaving()
  self.misbehaving = self.misbehaving + 1
  if self.ship:getReputationPoints() > 500 then
    self.ship:setReputationPoints(500)
  end
end

function Browncoat:stopMisbehaving()
  self.misbehaving = self.misbehaving - 1
  if self.misbehaving < 0 then
    self.misbehaving = 0
  end
end

function Browncoat:shipSearched(allianceNavyCaptain)
  -- wanted level
  if (self.ship:getReputationPoints() < 200) or (self.misbehaving > 0) then
    victory(allianceNavyCaptain.ship:getFaction())
  end
  
  --missions
  for _, mission in ipairs(self.missions) do
    mission:shipSearched(allianceCruiser)
  end
end

function Browncoat:acceptMission(mission)
  mission:accept(self)
  table.insert(self.missions, mission)
end

function Browncoat:removeMission(mission)
  for i, m in ipairs(self.missions) do
    if mission == m then
      table.remove(self.missions, i)
    end
  end
end

function Browncoat:completeMission(mission)
  self:removeMission(mission)
  self.missionsCompleted = self.missionsCompleted + 1
  if self.missionsCompleted > 1 then
    victory(self.ship:getFaction())
  end
end

--[[
implicit mission interface:
    accept(browncoat)
    update(delta)
    shipSearched(cruiserCaptain)
]]