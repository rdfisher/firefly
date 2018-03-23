--[[
Fleet in charge of defending against a cargo delivery. Smugglers must sneak past them
to deliver their contraband. At a critical part of the mission they become hostile
and attack the player on sight. They position themselves as several blockades around
the destination station, as well as a few fast scout ships that tail and report
the smuggler's position to the defence fleet, which re-arranges itself around the
station to better secure it. Once the smuggler gets within range they simply attack.
if far enough away they will order themselves back to protect the station.
Defence force is disbanded if the cargo is delivered.

Data required:
- SpaceObject to protect
- Destination where smuggler is coming from
- Number of blockades
- Number of scouts
]]
require("ObjectivePlan.lua")
require("utils.lua")

DefenceFleet = {
    SUSPECT_SCOUT_RANGE = 10000,
    SUSPECT_BLOCKADE_RANGE = 10000
}

function DefenceFleet:new(target, suspect, blockades, scouts)
    local o = {}
    o.target = target
    o.suspect = suspect
    local x, y = suspect:getPosition()
    o.lastKnownPosition = {
        x=x,
        y=y
    }
    o.numberOfBlockades = blockades
    o.numberOfScouts = scouts
    o.scouts = {}
    o.blockades = {}

    o.blockadeStateMachine = ObjectivePlan:new(true)
    o.scoutStateMachine = ObjectivePlan:new(true)
    setmetatable(o, self)
    self.__index = self
    DefenceFleet.initStateMachine(o)
    return o
end

function DefenceFleet:spawnScouts()
    local x, y = self.target:getPosition()
    -- TODO: Randomly position them
    -- TODO: Pick a better ship type
    for i=1,self.numberOfScouts do
        local scout = CpuShip():setTemplate("Phobos T3"):setFaction("Independent ")
        scout:setPosition(x, y)
        scout:setScanned(true)
        table.insert(self.scouts, scout)
    end
end

function DefenceFleet:spawnBlockade()
    -- Position in an arc around the station
    -- TODO: Pick a better ship type
    local tx, ty = self.target:getPosition()
    for i=1,self.numberOfBlockades do
        local r = random(0, 360)
        local distance = 5000
        local x = tx + math.cos(r / 180 * math.pi) * distance
        local y = ty + math.sin(r / 180 * math.pi) * distance

        local blockadeShip = CpuShip():setTemplate("Phobos T3"):setFaction("Independent ")
        blockadeShip:setPosition(x, y)
        blockadeShip:setScanned(true)
        table.insert(self.blockades, blockadeShip)
    end
end

function DefenceFleet:suspectInRangeOfBlockade()
    for _, b in ipairs(self.blockades) do
        if distance(b, self.suspect) < self.SUSPECT_BLOCKADE_RANGE then
            return true
        end
    end
    return false
end

function DefenceFleet:suspectTooFarFromBlockade()
    return not self:suspectInRangeOfBlockade()
end

function DefenceFleet:suspectInRange()
    for _, s in ipairs(self.scouts) do
        if distance(s, self.suspect) < self.SUSPECT_SCOUT_RANGE then
            return true
        end
    end
    return false
end

function DefenceFleet:suspectTooFar()
    return not self:suspectInRange()
end

function DefenceFleet:rearrangeBlockade()
    -- Move the blockade around a circle to face the new suspect location
    local cx, cy = self.target:getPosition()
    local angle = math.atan2(self.lastKnownPosition.y - cy, self.lastKnownPosition.x - cx)
    local x = cx + math.cos(angle) * 5000
    local y = cy + math.sin(angle) * 5000

    for _, b in ipairs(self.blockades) do
        b:orderDefendLocation(x, y)
    end
end

function DefenceFleet:blockadeAttack()
    for _, b in ipairs(self.blockades) do
        b:orderAttack(self.suspect)
    end
end

function DefenceFleet:scoutsAttack()
    for _, s in ipairs(self.scouts) do
        s:orderAttack(self.suspect)
    end
end

function DefenceFleet:scoutsFlyTo(x, y)
    for _, s in ipairs(self.scouts) do
        s:orderFlyTowards(x, y)
    end
end

function DefenceFleet:updateSuspectsLastKnownPosition()
    local x, y = self.suspect:getPosition()
    self.lastKnownPosition = {
        x = x,
        y = y
    }
end

function DefenceFleet:initStateMachine()
    -- Spawn/collect blockade ships
    self:spawnBlockade()
    self.blockadeStateMachine:add(Objective:new({
        name = "default",
        enter = function(fleet)

        end,
        update = function(fleet, delta)
            -- Order the spawned ships into correct positions
            fleet:rearrangeBlockade()

            if fleet:suspectInRangeOfBlockade() then
                return "attack"
            end
        end
    }))
    self.blockadeStateMachine:add(Objective:new({
        name = "attack",
        enter = function(fleet)
            fleet:blockadeAttack()
        end,
        update = function(fleet, delta)
            if fleet:suspectTooFarFromBlockade() then
                return "default"
            end
        end
    }))

    -- Spawn scouts
    self:spawnScouts()
    self.scoutStateMachine:add(Objective:new({
        name = "default",
        enter = function(fleet)
            -- Order scouts to search for the suspect forward
            fleet:scoutsFlyTo(fleet.lastKnownPosition.x, fleet.lastKnownPosition.y)
        end,
        update = function(fleet, delta)
            -- If suspect is found, go to "tail"
            if fleet:suspectInRange() then
                return "tail"
            end
        end
    }))
    self.scoutStateMachine:add(Objective:new({
        name = "tail",
        enter = function(fleet)
            fleet:scoutsAttack()
        end,
        update = function(fleet, delta)
            -- report suspect current position to the fleet
            fleet:updateSuspectsLastKnownPosition()
            -- If suspect is out of range, "lose" them
            if fleet:suspectTooFar() then
                return "search"
            end
        end
    }))
    self.scoutStateMachine:add(Objective:new({
        name = "search",
        enter = function(fleet)
            -- Fly back towards the station, hopefully spotting the transport
            local x, y = fleet.target:getPosition()
            fleet:scoutsFlyTo(x, y)
        end,
        update = function(fleet, delta)
            -- If we spot the transport
            if fleet:suspectInRange() then
                return "tail"
            end
        end
    }))
end

function DefenceFleet:update(delta)
    self.blockadeStateMachine:update(self, delta)
    self.scoutStateMachine:update(self, delta)
end

-- function DefenceFleet:assemble()
-- end

function DefenceFleet:disband()
    for _, table in ipairs({self.blockades, self.scouts}) do
        for _, ship in ipairs(table) do
            ship:orderRoaming()
        end
    end
end



