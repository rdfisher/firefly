Browncoat = {
    ship = {},
    missions = {},
    missionsCompleted = 0,
    CLEAN = 1000,
    PETTY_CRIMINAL = 500,
    FELLON = 200,
    ENEMY = 0
}

--[[
Reputation:
1000 = No crime committed, squeeky clean
>500 = Petty criminal, stop and scan
>200 = Fellon, Detain and arrest
  >0 = Enemy of Alliance, shoot on sight

Killing a freighter is about -100 rep points
]]

function Browncoat:repClean()
  if self.ship:getReputationPoints() >= self.CLEAN then
    return true
  end
  return false
end
function Browncoat:repPettyCriminalOrBelow()
  if self.ship:getReputationPoints() < self.CLEAN then
    return true
  end
  return false
end
function Browncoat:repFellonOrBelow()
  if self.ship:getReputationPoints() < self.PETTY_CRIMINAL then
    return true
  end
  return false
end
function Browncoat:repEnemy()
  if self.ship:getReputationPoints() < self.FELLON then
    return true
  end
  return false
end

-- Ensure rep is lower than this value
function Browncoat:setRep(rep)
  if self.ship:getReputationPoints() > rep then
    self.ship:setReputationPoints(rep)
  end
end

function Browncoat:new(ship)
    local o = {}
    o.ship = ship
    setmetatable(o, self)
    self.__index = self
    o.ship:setReputationPoints(Browncoat.CLEAN)
    return o
end

function Browncoat:update(delta) 
  --remove all waypoints
  local numberOfWaypoints = self.ship:getWaypointCount()
  
  if (numberOfWaypoints > 0) then
    for i=1,numberOfWaypoints do
      self.ship:commandRemoveWaypoint(i)
    end
  end
  
  for _, mission in ipairs(self.missions) do
    mission:update(delta)
    local x, y = mission:getWaypoint()
    self.ship:commandAddWaypoint(x, y)
  end
end

function Browncoat:getVelocity()
  local x, y = self.ship:getVelocity()
  return math.max(math.abs(x), math.abs(y))
end

function Browncoat:shipSearched(allianceNavyCaptain)
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

function Browncoat:completeMission(mission, success)
  self:removeMission(mission)
  if success then
    self.missionsCompleted = self.missionsCompleted + 1
    if self.missionsCompleted > 1 then
      victory(self.ship:getFaction())
    end
  end
end

--[[
implicit mission interface:
    accept(browncoat)
    update(delta)
    shipSearched(cruiserCaptain)
]]