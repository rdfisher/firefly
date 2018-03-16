AllianceNavyCaptain = {
    ship = {},
    target = {},
    investigate_stack = {},
    current_bulletin = nil,
    cortex = nil,
    investigation = false
}

function AllianceNavyCaptain:new()
    local o = {
        ship = {},
        target = {},
        investigate_stack = {},
        current_bulletin = nil,
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

function AllianceNavyCaptain:distance(a, b, c, d)
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

-- Return how busy we are. Size of our stack + current objective
function AllianceNavyCaptain:howBusy()
    local busy = 0
    if self.investigation then
        busy = 1
    end
    return (#self.investigate_stack + busy)
end

function AllianceNavyCaptain:update(delta)
    if not self:isValid() then
        return
    end

    if not self.investigation then
        if #self.investigate_stack > 0 then
            for i, v in ipairs(self.investigate_stack) do
                print(string.format("BULLETIN: %d, CALLSIGN: %s, SECTOR: %s", i, v.callsign, v.sector))
            end
            self.investigation = true
            self.current_bulletin = table.remove(self.investigate_stack)
            print(string.format(
                "Order received by ship %s, proceeding to sector %s, x:%f, y:%f",
                self.ship:getCallSign(), self.current_bulletin.sector, self.current_bulletin.x, self.current_bulletin.y
            ))
            self.cortex:broadcastAlert(string.format(
                "[%s] Investigating hostile activity in sector %s",
                self.ship:getCallSign(), self.current_bulletin.sector
            ))
            self.ship:orderFlyTowards(self.current_bulletin.x, self.current_bulletin.y)
        else
            -- Proceed with default mission
            -- TODO: Don't do this every update
            local x, y = self.target:getPosition()
            self.ship:orderFlyTowards(x, y)
        end
    else
        if self.ship:areEnemiesInRange(10000) then
            self:orderRoaming()
        else
            self.ship:orderFlyTowards(self.current_bulletin.x, self.current_bulletin.y)
        end
        -- Test to see if we have arrived at our investigation destination
        if self:distance(self.ship, self.current_bulletin.x, self.current_bulletin.y) < 1000 then
            -- ???
            -- Then clear the investigation
            self.investigation = false
            self.current_bulletin = nil
        end
    end
end