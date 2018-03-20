--[[
Transport Captain that flies in a more interesting wiggle, rather than a simple
straight line between destinations.
Logic: Given we are going from A to B, Split the route into chunks N long, then
pick a course at a random angle, that decreases with closer to our destination,
re-evaluate the course if we reach a chunk, or if we reach a timeout, as we
might be lost.
]]
require("ObjectivePlan.lua")

TransportCaptain = {
    SIGHTING_DELAY = 3,
    DOCK_TIMEOUT = 1.0,
    SURRENDER_DAMAGE_THRESHOLD = 0.55,
    RED_ALERT_CANCEL_TIMEOUT = 10
}

function TransportCaptain:new()
    local o = {
        movement = ObjectivePlan:new(),
        scanning = ObjectivePlan:new(),
        redAlert = ObjectivePlan:new(),
        ship = {},
        cortex = {},
        sensor = {},
        targets = {},
        current_target = nil,
        ordered = false,
        dock_count = 0,
        integrity = 1,
        surrendered = false,
        isMissionTarget = false
    }
    setmetatable(o, self)
    self.__index = self
    TransportCaptain.initObjectives(o)
    return o
end

function TransportCaptain:assignShip(ship)
    self.ship = ship
end

function TransportCaptain:assignTargets(targets)
    self.targets = targets
    self.current_target = self.targets[math.random(#self.targets)]
end

function TransportCaptain:setCortex(cortex)
    self.cortex = cortex
end

function TransportCaptain:setSensor(sensor)
    self.sensor = sensor
end

function TransportCaptain:distance(a, b, c, d)
    local x1, y1 = 0, 0
    local x2, y2 = 0, 0
    if type(a) == "table" and type(b) == "table" then
        -- a and b are bth tables.
        -- Assume distance(obj1, obj2)
        x1, y1 = a:getPosition()
        x2, y2 = b:getPosition()
    elseif type(a) == "table" and type(b) == "number" and type(c) == "number" then
        -- Assume distance(obj, x, y)
        x1, y1 = a:getPosition()
        x2, y2 = b, c
    elseif type(a) == "number" and type(b) == "number" and type(c) == "table" then
        -- Assume distance(x, y, obj)
        x1, y1 = a, b:getPosition()
        x2, y2 = c:getPosition()
    elseif type(a) == "number" and type(b) == "number" and type(c) == "number" and type(d) == "number" then
        -- a and b are both tables.
        -- Assume distance(obj1, obj2)
        x1, y1 = a, b
        x2, y2 = c, d
    else
        -- Not a valid use of the distance function. Throw an error.
        print(type(a), type(b), type(c), type(d))
        error("distance() function used incorrectly", 2)
    end
    local xd, yd = (x1 - x2), (y1 - y2)
    return math.sqrt(xd * xd + yd * yd)
end

function TransportCaptain:getIntegrity()
    local hull = self.ship:getHull() / self.ship:getHullMax()

    local shield = 1;
    for s=0,self.ship:getShieldCount()-1 do
        shield = math.min(shield, self.ship:getShieldLevel(s) / self.ship:getShieldMax(s))
    end

    local integrity = (hull + shield) / 2.0
    return integrity
end

function TransportCaptain:isUnderAttack(delta)
    local under_attack = false
    -- If integrity fell below previous value
    local currentIntegrity = self:getIntegrity()
    if currentIntegrity < self.integrity then
        under_attack = true
    end
    self.integrity = currentIntegrity
    return under_attack
end

function TransportCaptain:isValid()
    return self.ship:isValid()
end

function TransportCaptain:reportIllegalSightings(delta)
    -- TODO: if browncoat is in range, report them to the feds
    if self:distance(self.cortex.browncoat.ship, self.ship) < self.sensor:getRange() then
        self.cortex:reportSighting(self.cortex.browncoat.ship)
    end
end

function TransportCaptain:reportEnemySightings(ships)
    for _, object in ipairs(ships) do
        if object:isValid() and self.ship:isEnemy(object) then
            self.cortex:enemySpotted(self.ship, object)
        end
    end
end

function TransportCaptain:setIsMissionTarget(isMissionTarget)
  self.isMissionTarget = isMissionTarget
  if (isMissionTarget) then
    self.ship:setFaction("Independent ")
    -- Hopefully this is only called once
    self.cortex:reportPiracy(self.ship)
  else
    self.ship:setFaction("Independent")
  end
end

function TransportCaptain:initObjectives()
    self.movement:add(Objective:new({
        name = "default", -- en route
        enter = function(captain)
            -- calculate where we are suppose to be heading
            local x, y = captain.current_target:getPosition()
            captain.ship:orderFlyTowardsBlind(x, y)
            captain.ordered = true
            captain.surrendered = false
            -- Calculate next step
        end,
        update = function(captain, delta)
            -- Have we reached the end of our step?
            -- return "default" -- start a new step
            -- Is target invalid? -- Will probably never happen
            if not captain.current_target:isValid() then
                return "newTarget"
            end
            -- Are we close enough to dock
            local d = captain:distance(captain.ship, captain.current_target)
            if d < 3000 then
                return "dock"
            end
            -- Do we need to surrender?
            if captain:getIntegrity() <= captain.SURRENDER_DAMAGE_THRESHOLD then
                print(string.format("Ship %s surrendering, don't shoot", captain.ship:getCallSign()))
                return "surrender"
            end
        end
    }))
    self.movement:add(Objective:new({
        name = "newTarget",
        update = function(captain, delta)
            captain:pickNewTarget()
            return "default"
        end
    }))
    self.movement:add(Objective:new({
        name = "dock",
        enter = function(captain)
            captain.ship:orderDock(captain.current_target)
        end,
        update = function(captain, delta)
            if captain.ship:isDocked(captain.current_target) then
                captain.dock_count = captain.dock_count + 1
                return "docked"
            end
        end
    }))
    self.movement:add(Objective:new({
        name = "docked",
        update = function(captain, delta)
            if delta > captain.DOCK_TIMEOUT then
                return "newTarget"
            end
        end
    }))
    self.movement:add(Objective:new({
        name = "surrender",
        enter = function(captain)
            captain.ship:orderIdle()
            captain.ordered = false
            captain.surrendered = true
        end,
        update = function(captain, delta)
            -- Have we regained enough health to continue?
            if captain:getIntegrity() > captain.SURRENDER_DAMAGE_THRESHOLD then
                return "default"
                --print(string.format("Ship %s ordered to sector %s", self.ship:getCallSign(), self.current_target:getSectorName()))
            end
        end
    }))

    self.scanning:add(Objective:new({
        interval = self.SIGHTING_DELAY,
        update = function(captain, delta)
            -- Passively report illegal activity to the cortex
            captain:reportIllegalSightings(delta)
            -- Enemy on the scanner
            if captain.ship:areEnemiesInRange(captain.sensor:getEnemyRange()) then
                captain:reportEnemySightings(captain.ship:getObjectsInRange(captain.sensor:getEnemyRange()))
            end
        end
    }))
    self.redAlert:add(Objective:new({
        update = function(captain, delta)
            -- Check if we have suffered damage
            -- TODO: Refactor this out
            if captain:isUnderAttack() then
                return "redAlert"
            end
            -- TODO: Signal attacker for some role play
        end
    }))
    self.redAlert:add(Objective:new({
        name = "redAlert",
        enter = function(captain)
            captain.cortex:reportAttack(captain.ship)
        end,
        update = function(captain, delta)
            if delta > captain.RED_ALERT_CANCEL_TIMEOUT then
                return "default"
            end
        end
    }))
end

function TransportCaptain:update(delta)
    if not self.ship:isValid() then
        return
    end

    self.movement:update(self, delta)
    self.scanning:update(self, delta)
    self.redAlert:update(self, delta)
end

-- Pick new target that isn't the same as the current one
function TransportCaptain:pickNewTarget()
    local target = nil
    repeat
        target = self.targets[math.random(#self.targets)]
    until(target ~= self.current_target or #self.targets == 1)
    self.current_target = target
end

function TransportCaptain:getDockCount()
    return self.dock_count
end