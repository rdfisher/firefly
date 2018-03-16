Browncoat = {
    ship = {},
    wantedLevel = 0,
    missions = {}
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
  if (self.wantedLevel > 600)
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

--[[
implicit mission interface:
    accept(browncoat)
    update(delta)
    shipSearched(cruiser)
]]