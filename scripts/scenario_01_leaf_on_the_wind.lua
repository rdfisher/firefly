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
    local scale = 5000
  
    -- huge distance away:  players should never find it
    local apb = SpaceStation():setTemplate("Medium Station"):setFaction("Alliance Navy"):setPosition(200 * scale, 100 * scale):setCallSign("APB")
    wave = Wave:new(apb)
    
    cortex = Cortex:new(wave)
    dispatcher = AllianceNavyDispatcher:new(cortex)
    
    verse:generate(scale)
    
    playerX, playerY = verse.byName['persephone']:getPosition()
    browncoat = PlayerSpaceship():setFaction("Browncoats"):setTemplate("Atlantis"):setPosition(playerX + 100, playerY + 100)
    
    browncoatCaptain = Browncoat:new(browncoat)
    
    stations = {
      verse.byName['cortex-relay-7'],
      verse.byName['ezra'],
      verse.byName['athens'],
      verse.byName['persephone'],
      verse.byName['space-bazaar'],
      verse.byName['silverhold']
    }

    stations[1]:setCommsScript(""):setCommsFunction(MrUniverse)

    local badgerMission = DeliverMission:new(
      "Badger", 
      verse.byName['persephone'], 
      verse.byName['silverhold'],
      verse.byName['space-bazaar'], 
      cortex
    )
    
    stations[4]:setCommsScript(""):setCommsFunction(function()
        if comms_source:getFaction() == "Alliance Navy" then
          return
        end
        setCommsMessage("Badger: I'm above you! Better than! Businessman, see?")
        addCommsReply("We aim to misbehave.", function()
            setCommsMessage(badgerMission:getObjective())
            browncoatCaptain:acceptMission(badgerMission)
        end)
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

    swarm = ReaverSwarm:new(5, {verse.byName["burnham"], verse.byName["kalidasa"]})

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
    dispatcher:update(delta)
    swarm:update(delta)
    browncoatCaptain:update(delta)
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
