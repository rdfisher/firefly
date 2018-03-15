AllianceNavyCaptain = {
    ship = {},
    target = {},
    investigate_stack = {},
    cortex = nil,
    investigation = false
}

function AllianceNavyCaptain:new()
    local o = {
        ship = {},
        target = {},
        investigate_stack = {},
        cortex = nil,
        investigation = false
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

function AllianceNavyCaptain:investigate(bulletin)
    table.insert(self.investigate_stack, bulletin)
end

function AllianceNavyCaptain:update(delta)
    if not self:isValid() then
        return
    end

    if not self.investigation then
        if #self.investigate_stack > 0 then
            self.investigation = true
            local bulletin = table.remove(self.investigate_stack)
            print(string.format(
                "Order received by ship %s, proceeding to sector %s, x:%f, y:%f",
                self.ship:getCallSign(), bulletin.sector, bulletin.x, bulletin.y
            ))
            self.ship:orderFlyTowards(bulletin.x, bulletin.y)
        else
            -- Proceed with default mission
            -- TODO: Don't do this every update
            local x, y = self.target:getPosition()
            self.ship:orderFlyTowards(x, y)
        end
    else
        -- Test to see if we have arrived at our investigation destination
        -- ???
        -- Then clear the investigation
    end
end