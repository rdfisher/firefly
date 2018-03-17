Browncoat = {
    ship = {},
    missions = {},
    missionsCompleted = 0,
}

function Browncoat:new(ship)
    local o = {}
    o.ship = ship
    setmetatable(o, self)
    self.__index = self
    ship:setReputationPoints(10)
    return o
end

function Browncoat:update(delta) 
  for _, mission in ipairs(self.missions) do
    mission:update(delta)
  end
end

function Browncoat:shipSearched(allianceNavyCaptain)
  if (self.ship:getReputationPoints() < 200) then
    -- arrested
    victory(allianceNavyCaptain.ship:getFaction())
  end
  
  -- check missions
  for _, mission in ipairs(self.missions) do
    mission:shipSearched(allianceNavyCaptain)
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