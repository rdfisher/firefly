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

stations = {}
navyCaptains = {}
transportCaptains = {}

-- the whole gorram 'verse
verse = Verse:new()

function init()
    local scale = 5000
  
    -- huge distance away:  players should never find it
    local apb = SpaceStation():setTemplate("Medium Station"):setFaction("Alliance Navy"):setPosition(200 * scale, 100 * scale):setCallSign("APB")
    wave = Wave:new(apb)
    
    cortex = Cortex:new(wave)
    dispatcher = AllianceNavyDispatcher:new(cortex)
    
    browncoat = PlayerSpaceship():setFaction("Browncoats"):setTemplate("Atlantis"):setPosition(2 * scale, 5 * scale)
    wave:registerListener(browncoat)
    
    verse:generate(scale)
    
    -- Spawn some stations
    stations[1] = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setPosition(6 * scale, 5 * scale):setCallSign("DS1")
    stations[2] = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setPosition(-6 * scale, 5 * scale):setCallSign("DS2")
    stations[3] = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setPosition(-6 * scale, -5 * scale):setCallSign("DS3")
    stations[4] = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setPosition(6 * scale, -5 * scale):setCallSign("DS4")

    for i=1,4 do
        local group = CivilianGroup:new()
        for c=1,10 do
            local ship = CpuShip():setTemplate("Flavia"):setFaction("Independent"):setPosition(random(-6 * scale, 6 * scale), random(-5 * scale, 5 * scale)):orderDock(stations[i])
            group:add(ship)
            local captain = TransportCaptain:new()
            captain:assignShip(ship)
            captain:assignTargets(stations)
            captain:setCortex(cortex)
            table.insert(transportCaptains, captain)
        end
        local x, y = group:getPosition()
        escort = CpuShip():setTemplate("Starhammer II"):setFaction("Alliance Navy"):setPosition(x,y):orderIdle()
        
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

function update(delta)
    dispatcher:update(delta)
    swarm:update(delta)
    for _, captain in ipairs(navyCaptains) do
        captain:update(delta)
    end
    for i, captain in ipairs(transportCaptains) do
        if captain:isValid() then
            captain:update(delta)
        else
            table.remove(transportCaptains, i)
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
