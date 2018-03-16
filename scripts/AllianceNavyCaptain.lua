AllianceNavyCaptain = {}

function AllianceNavyCaptain:new()
    local o = {
        ship = {},
        target = {},
        investigate_stack = {},
        current_bulletin = nil,
        cortex = nil,
        investigation = false,
        mission_timer = 0,
        mission_progress = 1
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
    -- Remove any previous sightings of this callsign
    if bulletin.t == "enemySpotted" then
        for i,b in ipairs(self.investigate_stack) do
            if b.t == "enemySpotted" and b.callsign == bulletin.callsign then
                table.remove(self.investigate_stack, i)
            end
        end
    end
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

    -- If we are not on a mission
    if not self.investigation then
        -- Check to see if we should be
        if #self.investigate_stack > 0 then
            self.investigation = true
            self.mission_progress = "NONE"
        end
    end

    if not self.investigation then
        -- Move towards the centre of our flock
        local x, y = self.target:getPosition()
        self.ship:orderFlyTowards(x, y)
        return
    end

    -- State machine of (fly-to, roam for X seconds, then clear the bulletin)
    self.mission_timer = self.mission_timer + delta
    if self.mission_progress == "NONE" then
        self.mission_progress = "FLYTO"
        self.mission_timer = 0
        print(string.format("MISSION LIST FOR %s", self.ship:getCallSign()))
        for i, v in ipairs(self.investigate_stack) do
            print(string.format("BULLETIN: %d, TYPE: %s, TARGET CALLSIGN: %s, SECTOR: %s", i, v.t, v.callsign, v.sector))
        end
        print(string.format(
            "Order received by ship %s, proceeding to sector %s, x:%f, y:%f",
            self.ship:getCallSign(), self.investigate_stack[1].sector, self.investigate_stack[1].x, self.investigate_stack[1].y
        ))
        self.cortex:broadcastAlert(string.format(
            "[%s] Investigating hostile activity in sector %s",
            self.ship:getCallSign(), self.investigate_stack[1].sector
        ))
        self.ship:orderFlyTowards(self.investigate_stack[1].x, self.investigate_stack[1].y)
    end

    if self.mission_progress == "FLYTO" then
        if self:distance(self.ship, self.investigate_stack[1].x, self.investigate_stack[1].y) < 1000 then
            self.mission_progress = "ROAM"
            self.mission_timer = 0
            self.ship:orderRoaming()
        end
    end

    if self.mission_progress == "ROAM" then
        if self.mission_timer > 10 and not self.ship:areEnemiesInRange(10000) then
            self.mission_progress = "NONE"
            self.investigation = false
            table.remove(self.investigate_stack)
        end
    end
end