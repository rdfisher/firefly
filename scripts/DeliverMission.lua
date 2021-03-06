--[[
implicit mission interface:
    accept(browncoat)
    update(delta)
    shipSearched(cruiserCaptain)
]]
require("DefenceFleet.lua")

DeliverMission = {
  giverHome = {},
  giverName = "",
  originStation = {},
  destinationStation = {},
  browncoat = {},
  cortex = {},
  state = "new",
  STATE_NEW = "new",
  STATE_HEADING_TO_ORIGIN = "headingToOrigin",
  STATE_HEADING_TO_DESTINATION = "headingToDestination",
  STATE_DONE = "done",
  giver = nil
}

function DeliverMission:new(giverName, giverHome, originStation, destinationStation, cortex)
    local o = {}
    o.giverName = giverName
    o.giverHome = giverHome
    o.originStation = originStation
    o.destinationStation = destinationStation
    o.cortex = cortex
    o.fleet = nil
    setmetatable(o, self)
    self.__index = self
    return o
end

function DeliverMission:setGiver(giver)
  self.giver = giver
end

function DeliverMission:getObjective()
  return string.format(
      "%s: There are certain... items... which I'd like to be moved from %s (sector %s) to %s (sector %s).", 
      self.giverName, 
      self.originStation:getCallSign(), 
      self.originStation:getSectorName(), 
      self.destinationStation:getCallSign(),
      self.destinationStation:getSectorName()
      
  )
end

function DeliverMission:accept(browncoat)
  self.browncoat = browncoat
  self.state = self.STATE_HEADING_TO_ORIGIN
end

function DeliverMission:update(delta)
  if self.fleet then
    self.fleet:update(delta)
  end
  if self.state == self.STATE_NEW then
    return
  end
  
  if (self.state == self.STATE_HEADING_TO_ORIGIN) and (self.browncoat.ship:isDocked(self.originStation)) then
    self.giverHome:sendCommsMessage(
      self.browncoat.ship, 
      string.format(
        "%s: Finally! OK, take this to  %s (sector %s). Watch out, this stuff is hot!", 
        self.giverName,  
        self.destinationStation:getCallSign(), 
        self.destinationStation:getSectorName()
      )
    )
    self.cortex:illegalActivity(self.originStation)
    self.browncoat:setRep(Browncoat.PETTY_CRIMINAL)
    self.fleet = DefenceFleet:new(self.destinationStation, self.browncoat.ship, 6, 2)
    self.state = self.STATE_HEADING_TO_DESTINATION
    return
  end
  
  if (self.state == self.STATE_HEADING_TO_DESTINATION) and (self.browncoat.ship:isDocked(self.destinationStation)) then
    self.giverHome:sendCommsMessage(
      self.browncoat.ship, 
      string.format(
        "%s: You did alright. I owe ya.", 
        self.giverName
      )
    )
    self.browncoat:completeMission(self, true)
    if type(self.giver) ~= "nil" then
      self.giver:missionCompleted(self, true)
    end
    self.state = self.STATE_DONE
  end
end

function DeliverMission:shipSearched(cruiserCaptain)
  if self.state == self.STATE_HEADING_TO_DESTINATION then
    -- uh oh! caught with contraband on board
    victory(cruiserCaptain.ship:getFaction())
  end
end

function DeliverMission:getWaypoint()
  if self.state == self.STATE_HEADING_TO_ORIGIN then
    local x, y = self.originStation:getPosition()
    return x,y
  end
  if self.state == self.STATE_HEADING_TO_DESTINATION then
    local x, y = self.destinationStation:getPosition()
    return x,y
  end
  
  local x, y = self.giverHome:getPosition()
  return x, y
end