Niska = {
  missionInProgress = nil,
  availableMission = nil,
  browncoat = {},
  homeStation = {},
  transportCaptains = {},
  cortex = {},
  accumulatedTime = 280 --ensure a mission is generated soon after the game starts
}

function Niska:new (browncoat, homeStation, transportCaptains, cortex)
  local o = {}
  o.browncoat = browncoat
  o.homeStation = homeStation
  o.transportCaptains = transportCaptains
  o.cortex = cortex
  setmetatable(o, self)
  self.__index = self
  return o
end

function Niska:update(delta)
  if (type(self.missionInProgress) == "nil") and (type(self.availableMission) == "nil") then
    self.accumulatedTime = self.accumulatedTime + delta
  end
  
  if (self.accumulatedTime > 300) then
    -- comms to the player ship
    self.homeStation:sendCommsMessage(
      self.browncoat.ship,
      string.format(
        "Niska: Call me. Now. %s (sector %s)",   
        self.homeStation:getCallSign(), 
        self.homeStation:getSectorName()
      )
    )
    
    self.availableMission = self:generateMission()
    self.accumulatedTime = 0
  end
end

function Niska:generateMission()
  local transportCaptainIndex = math.random(1, #self.transportCaptains)
  local transportCaptain = self.transportCaptains[transportCaptainIndex]
  local mission = RobFreighterMission:new("Niska", self.homeStation, transportCaptain, self.cortex)
  mission:setGiver(self)
  return mission
end

function Niska:isMissionAvailable()
  if type(self.availableMission) == "nil" then
    return false
  end
  return true
end

function Niska:getAvailableMission()
  return self.availableMission
end

function Niska:isMissionInProgress()
  if type(self.missionInProgress) == "nil" then
    return false
  end
  return true
end

function Niska:getMissionInProgress()
  return self.missionInProgress
end

function Niska:missionCompleted(mission, success)
  self.missionInProgress = nil
end

function Niska:acceptMission(mission)
  self.missionInProgress = mission
  self.availableMission = nil
end