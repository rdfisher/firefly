TransportMission = {
    ship = {},
    targets = {},
    current_target = nil,
    ordered = false
}

function TransportMission:new()
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

function TransportMission:assignShip(ship)
    self.ship = ship
end

function TransportMission:assignTargets(targets)
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

function TransportMission:isComplete()
    -- TODO: Implement an Epsilon comparison `abs(a - b) < EPSILON`
    local d = distance(self.ship, self.current_target)
    print(string.format("Distance between ship and target is %f", d))
    if d < 1000 then
        return true
    end
    return false
end

function TransportMission:update(delta)
    if not self.ordered then
        local x, y = self.current_target:getPosition()
        self.ship:orderFlyTowardsBlind(x, y)
        self.ordered = true
    end

    if self:isComplete() then
        -- Pick new target that isn't the same as the current one
        local target = nil
        repeat
            target = self.targets[math.random(#self.targets)]
        until(target ~= self.current_target or #targets == 1)
        self.current_target = target
        self.ordered = false
    end
    -- TODO: State machine to manage docking.
end