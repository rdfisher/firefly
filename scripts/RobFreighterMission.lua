require("utils.lua")

--[[
implicit mission interface:
    accept(browncoat)
    update(delta)
    shipSearched(cruiserCaptain)
]]

RobFreighterMission = {
  giverHome = {},
  giverName = "",
  targetFreighterCaptain = {},
  browncoat = {},
  cortex = {},
  state = "new",
  STATE_NEW = "new",
  STATE_HEADING_TO_TARGET = "headingToTarget",
  STATE_FIGHT = "fight",
  STATE_HEADING_TO_DROP_OFF_POINT = "headingToDropOffPoint",
  STATE_DONE = "done",
  giver = nil
}


function RobFreighterMission:new(giverName, giverHome, targetFreighterCaptain, cortex)
    local o = {}
    o.giverName = giverName
    o.giverHome = giverHome
    o.targetFreighterCaptain = targetFreighterCaptain
    o.cortex = cortex
    setmetatable(o, self)
    self.__index = self
    return o
end

function RobFreighterMission:setGiver(giver)
  self.giver = giver
end

function RobFreighterMission:getObjective()
  return string.format(
      "%s: There's a trinket I'd like you to ... acquire... for me.\nIt's currently in the hold of the freighter %s (last seen in sector %s).", 
      self.giverName, 
      self.targetFreighterCaptain.ship:getCallSign(), 
      self.targetFreighterCaptain.ship:getSectorName()      
  )
end

function RobFreighterMission:accept(browncoat)
  self.browncoat = browncoat
  self.state = self.STATE_HEADING_TO_TARGET
end

function RobFreighterMission:update(delta)
  if (self.state == self.STATE_NEW) or (self.state == self.STATE_DONE) then
    return
  end
  
  if (not self.targetFreighterCaptain.ship:isValid()) and (self.state ~= self.STATE_HEADING_TO_DROP_OFF_POINT) then
    self.giverHome:sendCommsMessage(
      self.browncoat.ship, 
      string.format(
        "%s: Yi Dwei Da Buen Chu! Now it's ruined. FFS.",
        self.giverName
      )
    )
    self.browncoat:completeMission(self, false)
    if type(self.giver) ~= "nil" then
      self.giver:missionCompleted(self, false)
    end
    self.state = self.STATE_DONE
    return
  end
  
  if (self.state == self.STATE_HEADING_TO_TARGET) and (distance(self.browncoat.ship, self.targetFreighterCaptain.ship) < 3000) then
    self.giverHome:sendCommsMessage(
      self.browncoat.ship, 
      string.format(
        "%s: OK, now rough them up just enough to get them to hand over the package.",
        self.giverName
      )
    )
    self.targetFreighterCaptain:setIsMissionTarget(true)
    self.state = self.STATE_FIGHT
    return 
  end
  
  if (self.state == self.STATE_FIGHT) and (distance(self.browncoat.ship, self.targetFreighterCaptain.ship) > 10000) then
    self.giverHome:sendCommsMessage(
      self.browncoat.ship, 
      string.format(
        "%s: They're getting away. After them!",
        self.giverName
      )
    )
    self.state = self.STATE_HEADING_TO_TARGET
    return 
  end

  if (self.state == self.STATE_FIGHT) and (self.targetFreighterCaptain.surrendered) then
    self.cortex:illegalActivity(self.targetFreighterCaptain.ship)
    self.giverHome:sendCommsMessage(
      self.browncoat.ship, 
      string.format(
        "%s: Alright, you've got it. Now get back here with it. Maybe take the scenic route, I don't want you bringing the alliance fleet back with you.\nDock at %s (sector %s)",
      self.giverName,
      self.giverHome:getCallSign(), 
      self.giverHome:getSectorName()   
      )
    )
    self.targetFreighterCaptain:setIsMissionTarget(false)
    self.state = self.STATE_HEADING_TO_DROP_OFF_POINT
  end

  if (self.state == self.STATE_HEADING_TO_DROP_OFF_POINT) and (self.browncoat.ship:isDocked(self.giverHome)) then
    self.giverHome:sendCommsMessage(
      self.browncoat.ship, 
      string.format(
        "%s: It's so pretty!", 
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

function RobFreighterMission:shipSearched(cruiserCaptain)
  if self.state == self.STATE_HEADING_TO_DROP_OFF_POINT then
    -- uh oh! caught with stolen goods on board
    victory(cruiserCaptain.ship:getFaction())
  end
end

function RobFreighterMission:getWaypoint()
  if self.state == self.STATE_HEADING_TO_DROP_OFF_POINT then
    local x, y = self.giverHome:getPosition()
    return x,y
  end
  
  local x, y = self.targetFreighterCaptain.ship:getPosition()
  return x, y
end