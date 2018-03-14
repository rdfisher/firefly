TransportMission = {
    ship = {},
    target = {},
    ordered = false
}

function TransportMission:new()
    local o = {
        ship = {},
        target = {},
        ordered = false
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function TransportMission:assignShip(ship)
    self.ship = ship
end

function TransportMission:assignTarget(spaceObject)
    self.target = spaceObject
end

function TransportMission:isComplete()
    -- TODO: Implement an Epsilon comparison `abs(a - b) < EPSILON`
    if ship:getPosition() == target:getPosition() then
        return true
    end
    return false
end

function TransportMission:update(delta)
    if not self.ordered then
        local x, y = self.target:getPosition()
        self.ship:orderFlyTowardsBlind(x, y)
        self.ordered = true
    end

    -- TODO: State machine to manage docking.
end