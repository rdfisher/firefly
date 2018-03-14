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
require("EscortObjective.lua")
require("TransportCaptain.lua")
groups = {}
stations = {}
escortObjectives = {}
transportCaptains = {}
function init()
    browncoat = PlayerSpaceship():setFaction("Browncoats"):setTemplate("Atlantis")
    
    -- Spawn some stations
    stations[1] = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setPosition(20000, 20000):setCallSign("DS1")
    stations[2] = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setPosition(-20000, 20000):setCallSign("DS2")
    stations[3] = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setPosition(-20000, -20000):setCallSign("DS3")
    stations[4] = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setPosition(20000, -20000):setCallSign("DS4")

    for i=1,4 do
        local group = CivilianGroup:new()
        for c=1,10 do
            local ship = CpuShip():setTemplate("Flavia"):setFaction("Independent"):setPosition(random(-10000, 10000), random(-10000, 10000)):orderIdle()
            group:add(ship)
            local captain = TransportCaptain:new()
            captain:assignShip(ship)
            captain:assignTargets(stations)
            table.insert(transportCaptains, captain)
        end
        local x, y = group:getPosition()
        escort = CpuShip():setTemplate("Starhammer II"):setFaction("Alliance Navy"):setPosition(x,y):orderDock(stations[i])
        
        local objective = EscortObjective:new()
        objective:assignShip(escort)
        objective:assignTarget(group)
        table.insert(escortObjectives, objective)

        table.insert(groups, {group=group, escort=escort})
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
    for _, objective in ipairs(escortObjectives) do
        objective:update(delta)
    end
    for _, captain in ipairs(transportCaptains) do
        captain:update(delta)
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