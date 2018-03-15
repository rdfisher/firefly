AllianceNavyCaptain = {
    ship = {},
    target = {},
    cortex = nil
}

function AllianceNavyCaptain:new()
    local o = {
        ship = {},
        target = {},
        cortex = nil
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function AllianceNavyCaptain:assignShip(ship)
    self.ship = ship
end

function AllianceNavyCaptain:assignTarget(target)
    self.target = target
end

function AllianceNavyCaptain:setCortex(cortex)
    self.cortex = cortex
end

function AllianceNavyCaptain:isValid()
    return self.ship:isValid()
end

function AllianceNavyCaptain:update(delta)
    if not self:isValid() then
        return
    end

    -- TODO: Don't do this every update
    local x, y = self.target:getPosition()
    self.ship:orderFlyTowards(x, y)
end