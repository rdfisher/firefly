-- Name: Leaf on the wind
-- Description: Scenario Description
-- Type: Basic
-- Variation[TwoPlayer]: Two player scenario

-- TODO:
-- Last position
-- disperse stations
-- Create merchant fleet of transports
-- Spawn mission types (transport, salvage, data hack)
-- Create Allience Navy fleet
-- Create Reever incursion script
-- Add Ships (Tohoku-class cruiser, Allience Navy Gunships, Firefly, Reever ships?)
-- Create a "follow investigate last position" script
-- Create a search pattern script
-- Implement Cry Baby

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

civilians = {}
stations = {}
navyCaptains = {}
transportCaptains = {}

-- the whole gorram 'verse
verse = Verse:new()

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
    local scale = 20000
    verse:generate(scale)
    
    playerX, playerY = verse.byName['persephone']:getPosition()
    browncoat = PlayerSpaceship():setFaction("Browncoats"):setTemplate("Atlantis"):setPosition(playerX + 100, playerY + 100)
    browncoatCaptain = Browncoat:new(browncoat)

    -- huge distance away:  players should never find it
    local apb = SpaceStation():setTemplate("Medium Station"):setFaction("Alliance Navy"):setPosition(200 * scale, 100 * scale):setCallSign("APB")
    wave = Wave:new(apb)

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
    for i=1,4 do
        local group = CivilianGroup:new()
        table.insert(civilians, group)
    end
    -- add transports to one group
    local group = civilians[1]
    for c=1,40 do
        local ship = CpuShip():setTemplate("Flavia"):setFaction("Independent"):setPosition(random(-6 * scale, 6 * scale), random(-5 * scale, 5 * scale))
        ship:setWarpDrive(true)
        group:add(ship)
        local captain = TransportCaptain:new()
        captain:assignShip(ship)
        captain:assignTargets(stations)
        captain:setCortex(cortex)
        table.insert(transportCaptains, captain)
    end
    -- rebalance groups
    CivilianGroup:balance(civilians)
    -- Add Navy escorts
    for _,group in ipairs(civilians) do
        local x, y = group:getPosition()
        escort = CpuShip():setTemplate("Starhammer II"):setFaction("Alliance Navy"):setPosition(x,y):orderIdle()
        escort:setWarpDrive(true):setJumpDrive(true):setJumpDriveRange(0,10000000)
        local captain = AllianceNavyCaptain:new()
        captain:assignShip(escort)
        captain:assignTarget(group)
        captain:setCortex(cortex)
        table.insert(navyCaptains, captain)
        dispatcher:addNavyShip(captain)
    end

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
    swarm1 = ReaverSwarm:new(scale * -15, 0, scale * 5, 100)

    local swarm2X, swarm2Y = verse.byName["kalidasa"]:getPosition()
    swarm2 = ReaverSwarm:new(scale * 15, 0, scale * 5, 100)

    -- Temporary function to test finding probes
    addGMFunction("Find Probes", function()
        local probes = findProbes()
        for _,v in ipairs(probes) do
            if v:isValid() then
                local x, y = v:getPosition()
                print(string.format("Probe location: %f, %f", x, y))
            end
        end
    end)
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
        -- print("Civilian group rebalance in progress")
        -- for i, v in ipairs(civilians) do
        --     local x, y = v:getPosition()
        --     print(string.format("Cluster %d centroid position X: %f, Y: %f, size %d, radius %f", i, x, y, v:getSize(), v:getRadius()))
        -- end
    end
    cortex:update(delta)
    dispatcher:update(delta)
    swarm1:update(delta)
    swarm2:update(delta)
    browncoatCaptain:update(delta)
    badger:update(delta)
    niska:update(delta)
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
end

function findProbes()
    list = {}
    for _, probe in ipairs(getAllObjects()) do
        if probe.typeName == "ScanProbe" then
            if probe:getPosition() == probe:getTarget() then
                table.insert(list, probe)
            end
        end
    end
    return list
end
