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

stations = {}
navyCaptains = {}
transportCaptains = {}

-- the whole gorram 'verse
verse = Verse:new()
cortex = Cortex:new()
dispatcher = AllianceNavyDispatcher:new(cortex)

function init()
    browncoat = PlayerSpaceship():setFaction("Browncoats"):setTemplate("Atlantis"):setPosition(0, 0)
    
    
    verse:generate(5000)
    
    -- Spawn some stations
    stations[1] = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setPosition(200000, 200000):setCallSign("DS1")
    stations[2] = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setPosition(-200000, 200000):setCallSign("DS2")
    stations[3] = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setPosition(-200000, -200000):setCallSign("DS3")
    stations[4] = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setPosition(200000, -200000):setCallSign("DS4")

    for i=1,4 do
        local group = CivilianGroup:new()
        for c=1,10 do
            local ship = CpuShip():setTemplate("Flavia"):setFaction("Independent"):setPosition(random(-100000, 100000), random(-100000, 100000)):orderDock(stations[i])
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
