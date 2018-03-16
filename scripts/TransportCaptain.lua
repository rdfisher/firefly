TransportCaptain = {
    ship = {},
    cortex = {},
    targets = {},
    current_target = nil,
    ordered = false,
    docking = false,
    docking_time = 0,
    dock_count = 0,
    integrity = 1,
    red_alert_timer = 0,
    red_alert = false,
    attacked_counter = 0
}

function TransportCaptain:new()
    local o = {
        ship = {},
        cortex = {},
        targets = {},
        current_target = nil,
        ordered = false,
        docking = false,
        docking_time = 0,
        dock_count = 0
    }
    setmetatable(o, self)
    self.__index = self
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

    local shield = 0.0;
    for s=0,self.ship:getShieldCount()-1 do
        shield = shield + (self.ship:getShieldLevel(s) / self.ship:getShieldMax(s))
    end
    shield = shield / self.ship:getShieldCount()

    local integrity = (hull + shield / 2.0)
    return integrity
end

function TransportCaptain:getAttackedCounter()
    return self.attacked_counter
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

function TransportCaptain:findEnemies(range)
    output = {}
    for _, object in ipairs(self.ship:getObjectsInRange(range)) do
        if object:isValid() and self.ship:isEnemy(object) then
            table.insert(output, object)
        end
    end
    return output
end

function TransportCaptain:update(delta)
    if not self.ship:isValid() then
        return
    end

    -- Enemy on the scanner
    if self.ship:areEnemiesInRange(30000) then
        self.red_alert_timer = 0
        if not self.red_alert then
            self.red_alert = true
            for _,enemy in ipairs(self:findEnemies(30000)) do
                self.cortex:enemySpotted(self.ship, enemy)
            end
        end
    end

    -- Check if we have suffered damage
    if self:isUnderAttack() then
        self.red_alert_timer = 0
        if not self.red_alert then
            self.red_alert = true
            self.cortex:reportAttack(self.ship) -- TODO: this wont report if enemy already on the scanner
        end
    end

    -- Cancel red alert if its been on for 10 seconds (re-sending all bulletins)
    if self.red_alert then
        if self.red_alert_timer < 10 then
            self.red_alert_timer = self.red_alert_timer + delta
        else
            self.red_alert = false
        end
    end

    -- TODO: Stop if attacked and damaged
    if self.ordered and self.integrity <= 0.5 then
        self.ship:orderIdle()
        self.ordered = false
    end
    -- TODO: Signal attacker for some role play

    -- If our target is now invalid, just pick a new one
    if not self.current_target:isValid() then
        self.ordered = false
        self:pickNewTarget()
        return
    end

    -- Start with being given an order to fly
    if not self.ordered and self.integrity > 0.5 then
        local x, y = self.current_target:getPosition()
        self.ship:orderFlyTowardsBlind(x, y)
        self.ordered = true
        --print(string.format("Ship %s ordered to sector %s", self.ship:getCallSign(), self.current_target:getSectorName()))
    end

    -- Short circuit. We are not moving
    if not self.ordered then
        return
    end

    -- If we are close to our objective, request dock
    local d = self:distance(self.ship, self.current_target)
    if d < 3000 and not self.docking then
        self.docking = true
        self.ship:orderDock(self.current_target)
        self.docking_time = 0
    end

    -- If we have docked, wait a little bit, and undock
    if self.docking and self.ship:isDocked(self.current_target) then
        self.docking_time = self.docking_time + delta
        -- Undock after 10 seconds
        if self.docking_time > 10.0 then
            self.dock_count = self.dock_count + 1
            self.docking = false
            self:pickNewTarget()
            self.ordered = false
        end
    end
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