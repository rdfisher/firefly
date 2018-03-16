Browncoat = {
    ship = {},
    wantedLevel = 0,
    missions = {},
    missionsCompleted = 0
}

function Browncoat:new(ship)
    local o = {}
    o.ship = ship
    setmetatable(o, self)
    self.__index = self
    return o
end

function Browncoat:update(delta)
  self.wantedLevel = self.wantedLevel - delta
  if self.wantedLevel < 0 then
    self.wantedLevel = 0
  end
  for _, mission in ipairs(self.missions) do
    mission:update(delta)
  end
end

function Browncoat:misbehave(severity)
  self.wantedLevel = self.wantedLevel + severity
end

function Browncoat:shipSearched(allianceNavyCaptain)
  -- wanted level
  if (self.wantedLevel > 600) then
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

function Browncoat:completeMisison(mission)
  self:removeMission(mission)
  self.missionsCompleted = self.missionsCompleted + 1
  if self.missionsCompleted > 2 then
    victory(self.ship:getFaction())
  end
end

--[[
implicit mission interface:
    accept(browncoat)
    update(delta)
    shipSearched(cruiserCaptain)
]]