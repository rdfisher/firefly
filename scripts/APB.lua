APB = {
  missionInProgress = nil,
  availableMission = nil,
  browncoat = {},
  homeStation = {},
  reaverSwarms = {},
  cortex = {},
  accumulatedTime = 0
}

function APB:new (browncoat, homeStation, reaverSwarms, cortex)
  local o = {}
  o.browncoat = browncoat
  o.homeStation = homeStation
  o.reaverSwarms = reaverSwarms
  o.cortex = cortex
  setmetatable(o, self)
  self.__index = self
  return o
end

function APB:update(delta)
  if (type(self.missionInProgress) == "nil") and (#self.reaverSwarms > 0) then
    self.accumulatedTime = self.accumulatedTime + delta
  end
  
  if (self.accumulatedTime > 300) then
    self.missionInProgress = self:generateMission()
    
    self.homeStation:sendCommsMessage(
      self.browncoat.ship,
      self.missionInProgress:getObjective()
    )
    self.browncoat:acceptMission(self.missionInProgress)
    self.accumulatedTime = 0
  end
end

function APB:generateMission()
  local swarm = table.remove(self.reaverSwarms)
  local missingShipName = ""
  local mission = RescueMission:new(swarm, self.cortex, missingShipName, self.homeStation)
  mission:setGiver(self)
  return mission
end

function APB:missionCompleted(mission, success)
  self.missionInProgress = nil
end
