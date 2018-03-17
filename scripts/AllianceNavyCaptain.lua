AllianceNavyCaptain = {
    MISSION_ROAM_TIMEOUT = 10,
    ROAM_SCANNER_RANGE = 10000,
    ILLEGAL_REP_THRESHOLD = 300,
    CRIME_SCANNER_DELAY = 10,
    CRIME_SCANNER_RANGE = 5000
}

function AllianceNavyCaptain:new()
    local o = {
        ship = {},
        target = {},
        bulletins = {},
        cortex = nil,
        investigation = false,
        mission_timer = 0,
        mission_progress = 1,
        crime_scanner_timeout = 0
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

function AllianceNavyCaptain:shouldDedupeByCallsign(bulletin_type)
    if bulletin_type == "enemySpotted" then
        return true
    end
    if bulletin_type == "illegalActivity" then
        return true
    end
    return false
end

function AllianceNavyCaptain:investigate(bulletin)
    -- Remove any previous sightings of this callsign
    if self:shouldDedupeByCallsign(bulletin.t) then
        for i,b in ipairs(self.bulletins) do
            if self:shouldDedupeByCallsign(b.t) and b.callsign == bulletin.callsign then
                table.remove(self.bulletins, i)
            end
        end
    end
    table.insert(self.bulletins, bulletin)
    -- Reset current mission
    self.mission_progress = "NONE"
    self.investigation = false
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
    return #self.bulletins
end

function AllianceNavyCaptain:latestBulletin()
    return self.bulletins[#self.bulletins]
end

function AllianceNavyCaptain:scanRangeForCriminals(range)
    objects = {}
    local allShipsInRange = self.ship:getObjectsInRange(range)
    for _, object in ipairs(allShipsInRange) do
        if object:isValid() and object:getFaction() == "Browncoats" and object:getReputationPoints() < self.ILLEGAL_REP_THRESHOLD then
            table.insert(objects, object)
        end
    end
    return objects
end

function AllianceNavyCaptain:update(delta)
    if not self:isValid() then
        return
    end

    -- Scan the area for Browncoats
    if self.crime_scanner_timeout < self.CRIME_SCANNER_DELAY then
        self.crime_scanner_timeout = self.crime_scanner_timeout + delta
    else
        self.crime_scanner_timeout = 0
        local criminals = self:scanRangeForCriminals(self.CRIME_SCANNER_RANGE)
        for _, criminal in ipairs(criminals) do
            -- Report them to the cortex
            self.cortex:reportIllegalSightings(delta, criminal)
        end
    end

    -- If we are not on a mission
    if not self.investigation then
        -- Check to see if we should be
        if #self.bulletins > 0 then
            self.investigation = true
            self.mission_progress = "NONE"
            return
        end

        -- Default behavior Move towards the centre of our flock
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
        for i, v in ipairs(self.bulletins) do
            print(string.format("BULLETIN: %d, TYPE: %s, TARGET CALLSIGN: %s, SECTOR: %s", i, v.t, v.callsign, v.sector))
        end
        print(string.format(
            "Order received by ship %s, proceeding to sector %s, x:%f, y:%f",
            self.ship:getCallSign(), self:latestBulletin().sector, self:latestBulletin().x, self:latestBulletin().y
        ))
        self.cortex:broadcastAlert(string.format(
            "[%s] Investigating hostile activity in sector %s",
            self.ship:getCallSign(), self:latestBulletin().sector
        ))
        local x, y = self:latestBulletin():getPosition()
        self.ship:orderFlyTowards(x, y)
    end

    if self.mission_progress == "FLYTO" then
        local x, y = self:latestBulletin():getPosition()
        if self:distance(self.ship, x, y) < 5000 then
            self.mission_progress = "ROAM"
            self.mission_timer = 0
            self.ship:orderRoaming()
        end
    end

    if self.mission_progress == "ROAM" then
        -- TODO: If any criminals in range, order them to stop and search them
        if self.mission_timer > self.MISSION_ROAM_TIMEOUT and not self.ship:areEnemiesInRange(self.ROAM_SCANNER_RANGE) then
            self.mission_progress = "NONE"
            self.investigation = false
            table.remove(self.bulletins)
        end
    end
end