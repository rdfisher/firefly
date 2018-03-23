-- Name: Leaf on the wind
-- Description: Scenario Description
-- Type: Basic
-- Variation[TwoPlayer]: Two player scenario

--[[
Observations:
Ranges:
- Tactical: Anything below 5U is role of tactical. Useful missile range is 2-5U.
Beam range is < 2U.

- Operations: Below 5U is essentially a local contact. Anything above 5U will not
be seen by other members of the crew except Ops. Ops range is anywhere between 5U
and 50U, with 50U being max comm range.

50U radius is about 2.5 sectors worth.

Shooting / interacting with a ship requires you to be < 5U, Transfering cargo < 2U

For Alliance > 5U is comms range. < 5U is where aggression happens. and 2U should
be close enough to immediately destroy a ship.
]]

require("Verse.lua")
require("CivilianGroup.lua")
require("AllianceNavyCaptain.lua")
require("AllianceNavyDispatcher.lua")
require("TransportCaptain.lua")
require("Cortex.lua")
require("ReaverSwarm.lua")
require("Wave.lua")
require("Browncoat.lua")
require("DeliverMission.lua")
require("Badger.lua")
require("RobFreighterMission.lua")
require("Niska.lua")
require("RescueMission.lua")
require("APB.lua")
require("Sensor.lua")

civilians = {}
stations = {}
navyCaptains = {}
transportCaptains = {}

-- the whole gorram 'verse
scale = 10000
verse = Verse:new(scale)

-- characters
function MrUniverse()
  if comms_source:getFaction() == "Alliance Navy" then
    return
  end
      
  setCommsMessage("Mr Universe: Oh my stars and garters, look at you!")
  addCommsReply("Can you throw us some playback?", function()
    local playback = "Mr Universe: There is no news."
    local messages = wave:getAccumulatedMessages()
    
    if #messages > 0 then
      playback = "Mr Universe: Can't stop the signal. Everything goes somewhere, and I go everywhere.\n\n" .. table.concat(messages, "\n") 
    end
        
    setCommsMessage(playback)			
  end)
end


function init()

    verse:generate()
    
    playerX, playerY = verse.byName['persephone']:getPosition()
    browncoat = PlayerSpaceship():setFaction("Browncoats"):setTemplate("Serenity"):setPosition(playerX - 2000, playerY - 2000)
    browncoat:setCallSign("Serenity")
    browncoatCaptain = Browncoat:new(browncoat)
    local sensor = Sensor:new(browncoat)
    -- huge distance away:  players should never find it
    local apb = SpaceStation():setTemplate("Medium Station"):setFaction("Alliance Navy"):setPosition(-200 * scale, -100 * scale):setCallSign("APB")
    wave = Wave:new(apb)
    -- Debug APB broadcast, should probably only enable this for the Alliance
    --wave:registerListener(browncoat)
    cortex = Cortex:new(wave, browncoatCaptain)
    dispatcher = AllianceNavyDispatcher:new(cortex)
    
    stations = {
      verse.byName['cortex-relay-7'],
      verse.byName['ezra'],
      verse.byName['athens'],
      verse.byName['persephone'],
      verse.byName['space-bazaar'],
      verse.byName['silverhold']
    }

    stations[1]:setCommsScript(""):setCommsFunction(MrUniverse)
    
    badger = Badger:new(
      browncoatCaptain,
      verse.byName['persephone'],
      {
        verse.byName['space-bazaar'],
        verse.byName['silverhold'],
        verse.byName['ezra'],
        verse.byName['athens']
      }, 
      cortex
    )
    
    stations[4]:setCommsScript(""):setCommsFunction(function()
      if comms_source:getFaction() == "Alliance Navy" then
        return
      end
        
      if badger:isMissionInProgress() then
        setCommsMessage("Badger: Did you get that thing done yet?")
        return
      end
        
      if badger:isMissionAvailable() then
        local badgerMission = badger:getAvailableMission()
        setCommsMessage(badgerMission:getObjective())
        browncoatCaptain:acceptMission(badgerMission)
        badger:acceptMission(badgerMission)
      else
        setCommsMessage("Badger: I'm above you! Better than! Businessman, see?")
      end
    end)

    -- Create civilian groups
    local verseX, verseY = verse:getCentre()
    for i=1,4 do
        local group = CivilianGroup:new(verseX, verseY)
        table.insert(civilians, group)
    end
    -- add transports to one group
    local group = civilians[1]
    for c=1,40 do
        local ship = CpuShip():setTemplate("Flavia"):setFaction("Independent"):setPosition(random(6.5 * scale, 18.5 * scale), random(0, 10 * scale))
        group:add(ship)
        ship:setImpulseMaxSpeed(70)
        local captain = TransportCaptain:new()
        captain:assignShip(ship)
        captain:assignTargets(stations)
        captain:setCortex(cortex)
        captain:setSensor(sensor)
        table.insert(transportCaptains, captain)
    end
    -- rebalance groups
    CivilianGroup:balance(civilians)
    -- Add Navy escorts
    for i,group in ipairs(civilians) do
        local x, y = group:getPosition()
        escort = CpuShip():setTemplate("Gunship"):setFaction("Alliance Navy"):setPosition(x,y):orderIdle()
        escort:setCallSign("IAV" .. i)
        escort:setWarpDrive(false)
        local captain = AllianceNavyCaptain:new()
        captain:assignShip(escort)
        captain:assignTarget(group)
        captain:setCortex(cortex)
        captain:setSensor(sensor)
        table.insert(navyCaptains, captain)
        dispatcher:addGunship(captain)
    end

    -- Configure Tohoku escort
    local navyGroup = CivilianGroup:new(verseX, verseY)
    for _, captain in ipairs(navyCaptains) do
      navyGroup:add(captain.ship)
    end
    local x, y = navyGroup:getPosition()
    local tohoku = CpuShip():setTemplate("Tohoku"):setCallSign("Tohoku"):setFaction("Alliance Navy"):setPosition(x,y):orderIdle()
    tohokuCaptain = AllianceNavyCaptain:new()
    tohokuCaptain:assignShip(tohoku)
    tohokuCaptain:assignTarget(navyGroup)
    tohokuCaptain:setCortex(cortex)
    tohokuCaptain:setSensor(sensor)
    dispatcher:addTohoku(tohokuCaptain)

    niska = Niska:new(
      browncoatCaptain,
      verse.byName['ezra'],
      transportCaptains,
      cortex
    )
    
    stations[2]:setCommsScript(""):setCommsFunction(function()
      if comms_source:getFaction() == "Alliance Navy" then
        return
      end
        
      if niska:isMissionInProgress() then
        setCommsMessage("Niska: Don't contact me until it's done")
        return
      end
        
      if niska:isMissionAvailable() then
        local niskaMission = niska:getAvailableMission()
        setCommsMessage(niskaMission:getObjective())
        browncoatCaptain:acceptMission(niskaMission)
        niska:acceptMission(niskaMission)
      else
        setCommsMessage("Niska: Do you know the writings of Shan Yu?")
      end
    end)

    local swarm1X, swarm1Y = verse.byName["burnham"]:getPosition()
    swarm1 = ReaverSwarm:new(scale * -2.5, scale * 5, scale * 5, 30, "RVA")

    local swarm2X, swarm2Y = verse.byName["kalidasa"]:getPosition()
    swarm2 = ReaverSwarm:new(scale * 27.5, scale * 5, scale * 5, 30, "RVB")
    
    cortexApb = APB:new (browncoatCaptain, apb, {swarm1, swarm2}, cortex)
end

local balance = 0
function update(delta)
    if balance < 10 then
        balance = balance + delta
    else
        balance = 0
        for i=1,10 do
            if CivilianGroup:balance(civilians) < 1 then
                break;
            end
        end
    end
    cortex:update(delta)
    dispatcher:update(delta)
    swarm1:update(delta)
    swarm2:update(delta)
    browncoatCaptain:update(delta)
    badger:update(delta)
    niska:update(delta)
    cortexApb:update(delta)
    
    -- Update all captains
    for _, captains in ipairs({navyCaptains, transportCaptains}) do
        for i, captain in ipairs(captains) do
            if captain:isValid() then
                captain:update(delta)
            else
                table.remove(captains, i)
            end
        end
    end
    tohokuCaptain:update(delta)
end
