TransportCaptain = {
    ship = {},
    targets = {},
    current_target = nil,
    ordered = false,
    docking = false,
    docking_time = 0,
    dock_count = 0
}

function TransportCaptain:new()
    local o = {
        ship = {},
        targets = {},
        current_target = nil,
        ordered = false
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

function distance(a, b, c, d)
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

function TransportCaptain:update(delta)
    -- Start with being given an order to fly
    if not self.ordered then
        local x, y = self.current_target:getPosition()
        self.ship:orderFlyTowardsBlind(x, y)
        self.ordered = true
    end

    -- If we are close to our objective, request dock
    local d = distance(self.ship, self.current_target)
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
            -- Pick new target that isn't the same as the current one
            local target = nil
            repeat
                target = self.targets[math.random(#self.targets)]
            until(target ~= self.current_target or #self.targets == 1)
            self.current_target = target
            self.ordered = false
        end
    end
end

function TransportCaptain:getDockCount()
    return self.dock_count
end