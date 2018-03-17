Badger = {
  missionInProgress = nil,
  availableMission = nil,
  browncoat = {},
  homeStation = {},
  locations = {},
  cortex = {},
  accumulatedTime = 270 --ensure a mission is generated soon after the game starts
}

function Badger:new (browncoat, homeStation, locations, cortex)
  local o = {}
  o.browncoat = browncoat
  o.homeStation = homeStation
  o.locations = locations
  o.cortex = cortex
  setmetatable(o, self)
  self.__index = self
  return o
end

function Badger:update(delta)
  if (type(self.missionInProgress) == "nil") and (type(self.availableMission) == "nil") then
    self.accumulatedTime = self.accumulatedTime + delta
  end
  
  if (self.accumulatedTime > 300) then
    -- comms to the player ship
    self.homeStation:sendCommsMessage(
      self.browncoat.ship,
      string.format(
        "Badger: I have a job for you. Contact me at %s (sector %s)",   
        self.homeStation:getCallSign(), 
        self.homeStation:getSectorName()
      )
    )
    
    self.availableMission = self:generateMission()
    self.accumulatedTime = 0
  end
end

function Badger:generateMission()
  local originIndex = math.random(1, #self.locations)
  local destinationIndex = 0
  
  while (destinationIndex == 0) or (destinationIndex == originIndex) do
    destinationIndex = math.random(1, #self.locations)
  end
  
  local originStation = self.locations[originIndex]
  local destinationStation = self.locations[destinationIndex]
    
  local mission = DeliverMission:new("Badger", self.homeStation, originStation, destinationStation, self.cortex)
  mission:setGiver(self)
  return mission
end

function Badger:isMissionAvailable()
  if type(self.availableMission) == "nil" then
    return false
  end
  return true
end

function Badger:getAvailableMission()
  return self.availableMission
end

function Badger:isMissionInProgress()
  if type(self.missionInProgress) == "nil" then
    return false
  end
  return true
end

function Badger:getMissionInProgress()
  return self.missionInProgress
end

function Badger:missionCompleted(mission)
  self.missionInProgress = nil
end

function Badger:acceptMission(mission)
  self.missionInProgress = mission
  self.availableMission = nil
end