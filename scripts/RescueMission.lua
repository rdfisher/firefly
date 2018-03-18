--[[
implicit mission interface:
    accept(browncoat)
    update(delta)
    shipSearched(cruiserCaptain)
]]

RescueMission = {
  reaverSwarm = {},
  browncoat = {},
  cortex = {},
  giver = {},
  derelict = {},
  apb = {},
  state = "new",
  STATE_NEW = "new",
  STATE_HEADING_TO_DERELICT = "headingToDerelict",
  STATE_FIGHT_REAVER ="fightReaver",
  STATE_DONE = "done",
  reaver = {}
}

function RescueMission:new(reaverSwarm, cortex, missingShipName, apb)
    local o = {}
    o.reaverSwarm = reaverSwarm
    o.cortex = cortex
    o.apb = apb
    local locationX, locationY = reaverSwarm:getRandomBorderPoint()
    local derelict = CpuShip():setTemplate("Flavia"):setFaction("Independent "):setPosition(locationX, locationY)
    derelict:setCanBeDestroyed(false)
    derelict:setCallSign(missingShipName)
    derelict:orderIdle()
    o.derelict = derelict
    setmetatable(o, self)
    self.__index = self
    return o
end

function RescueMission:setGiver(giver)
  self.giver = giver
end

function RescueMission:getObjective()
  return string.format(
      "All Points Broadcast -  Distress signal received from sector %s: \n Mayday M<...static...> freighter %s requesting <....static....> adrift near to reaver space. Engines dead.", 
      self.derelict:getSectorName(),
      self.derelict:getCallSign()
  )
end

function RescueMission:accept(browncoat)
  self.browncoat = browncoat
  self.state = self.STATE_HEADING_TO_DERELICT
end

function RescueMission:update(delta)
  if self.state == self.STATE_NEW then
    return
  end
  
  local x, y = self.derelict:getPosition()
  if (self.state == self.STATE_HEADING_TO_DERELICT) and (distance(self.browncoat.ship, x, y) < 10000) then
    self.derelict:destroy()
    ExplosionEffect():setPosition(x, y):setSize(1000)
    
    local reaver = CpuShip():setTemplate("Phobos T3"):setFaction("Reavers"):setPosition(self.reaverSwarm.originX, self.reaverSwarm.originY):orderAttack(self.browncoat.ship)
    reaver:setCallSign("RVX1")
    reaver:setWarpDrive(true)
    self.reaver = reaver    
    
    reaver:sendCommsMessage(
      self.browncoat.ship, 
      "HAHAHA BOOM. BOOM! FUN. NOW I FIND YOU AND EAT YOUR EYES"
    )

    self.state = self.STATE_FIGHT_REAVER
    return
  end
  
  if (self.state == self.STATE_FIGHT_REAVER) and (not self.reaver:isValid()) then
    self.reaver:sendCommsMessage(
      self.browncoat.ship, 
      "<INDESCRIBABLE RAGE>\n<EXPLOSION>\n<STATIC>"
    )
    self.browncoat:completeMission(self, true)
    if type(self.giver) ~= "nil" then
      self.giver:missionCompleted(self, true)
    end
    self.state = self.STATE_DONE
  end
end

function RescueMission:shipSearched(cruiserCaptain)
  return
end

function RescueMission:getWaypoint()
  if self.state == self.STATE_FIGHT_REAVER then
    local x, y = self.reaver:getPosition()
    return x,y
  end
  if self.state == self.STATE_HEADING_TO_DERELICT then
    local x, y = self.derelict:getPosition()
    return x,y
  end
  return self.swarm.originX, self.swarm.originY
end