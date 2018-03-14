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
require("CivilianGroup.lua")
groups = {}
function init()
    browncoat = PlayerSpaceship():setFaction("Browncoats"):setTemplate("Atlantis")
    
    -- Spawn some stations
    SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setPosition(20000, 20000):setCallSign("DS1")
    SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setPosition(-20000, 20000):setCallSign("DS2")
    SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setPosition(-20000, -20000):setCallSign("DS3")
    SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setPosition(20000, -20000):setCallSign("DS4")

    for i=1,4 do
        for c=1,10 do
            ship = CpuShip():setTemplate("Flavia"):setFaction("Independent"):setPosition(random(-10000, 10000), random(-10000, 10000)):orderRoaming()
            group = CivilianGroup:new()
            group:add(ship)
        end
        local x, y = group:getGeographicCentre()
        escort = CpuShip():setTemplate("Starhammer II"):setFaction("Allience Navy"):setPosition(x,y):orderRoaming()
        table.insert(groups, {group=group, escort=escort})
    end

    -- Temporary function to test finding probes
    addGMFunction("Find Probes", function()
        probes = findProbes()
        for _,v in ipairs(probes) do
            if v:isValid() then
                local x, y = v:getPosition()
                print(string.format("Probe location: %f, %f", x, y))
            end
        end
    end)
end

function update(delta)
    -- todo: make escort follow the center
    for _, group in ipairs(groups) do
        local x, y = group.group:getGeographicCentre()
        group.escort:orderFlyTowards(x, y)
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