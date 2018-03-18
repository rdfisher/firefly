require("ObjectivePlan.lua")

AllianceNavyCaptain = {
    MISSION_ROAM_TIMEOUT = 10,
    ROAM_SCANNER_RANGE = 10000,
    ILLEGAL_REP_THRESHOLD = 300,
    CRIME_SCANNER_DELAY = 10,
    CRIME_SCANNER_RANGE = 5000,
    ARREST_TIMEOUT = 60, -- wait 1 minute for engines to stop
    MAX_DISTANCE_AWAY_FROM_FLOCK = 5000,
    ARREST_DISTANCE = 5000,
    SEARCH_DELAY = 120, -- wait 2 minutes to power down weapons
    MINIMUM_ARREST_SPEED = 10 -- meters/s
}

function AllianceNavyCaptain:new()
    local o = {
        plan = ObjectivePlan:new(),
        planPassiveScan = ObjectivePlan:new(),
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
    AllianceNavyCaptain.initObjectives(o)
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

function AllianceNavyCaptain:hasBrowncoatStopped()
    -- Velocity is in meters per second. 100% impulse seems to be around ~100m/s
    return self.cortex.browncoat.ship:getVelocity() < self.MINIMUM_ARREST_SPEED
end

function AllianceNavyCaptain:hasPoweredDownWeapons()
    for _, system in ipairs({"beamweapons", "missilesystem"}) do
        if self.cortex.browncoat.ship:getSystemPower(system) > 0 then
            return false
        end
    end
    return true
end

function AllianceNavyCaptain:hasDroppedShields()
    return not self.cortex.browncoat.ship:getShieldsActive()
end

function AllianceNavyCaptain:initObjectives()
    self.plan:add(Objective:new({
        name = "default",
        update = function(captain, delta)
            -- Check to see if we should be
            if #captain.bulletins > 0 then
                return "investigate"
            end
            -- Default behavior Move towards the centre of our flock
            local x, y = captain.target:getPosition()
            captain.ship:orderFlyTowards(x, y)
        end
    }))
    self.plan:add(Objective:new({
        name = "returnToFlock",
        enter = function(captain)
            local x, y = captain.target:getPosition()
            captain.ship:orderFlyTowardsBlind(x, y)
        end,
        update = function(captain)
            -- Stop flying blind once we are inside flock radius
            local x, y = captain.target:getPosition()
            if captain:distance(captain.ship, x, y) < captain.target:getRadius() then
                return "default"
            end
        end
    }))
    self.plan:add(Objective:new({
        name = "investigate",
        enter = function(captain)
            -- State machine of (fly-to, roam for X seconds, then clear the bulletin)
            print(string.format("MISSION LIST FOR %s", captain.ship:getCallSign()))
            for i, v in ipairs(captain.bulletins) do
                print(string.format("BULLETIN: %d, TYPE: %s, TARGET CALLSIGN: %s, SECTOR: %s", i, v.t, v.callsign, v.sector))
            end
            print(string.format(
                "Order received by ship %s, proceeding to sector %s, x:%f, y:%f",
                captain.ship:getCallSign(), captain:latestBulletin().sector, captain:latestBulletin().x, captain:latestBulletin().y
            ))
            captain.cortex:broadcastAlert(string.format(
                "[%s] Investigating hostile activity in sector %s",
                captain.ship:getCallSign(), captain:latestBulletin().sector
            ))
            local x, y = captain:latestBulletin():getPosition()
            captain.ship:orderFlyTowards(x, y)
        end,
        update = function(captain, delta)
            local x, y = captain:latestBulletin():getPosition()
            if captain:distance(captain.ship, x, y) < 5000 then
                return "roam"
            end
            -- Check if we are too far from out flock
            local x, y = captain.target:getPosition()
            if captain:distance(captain.ship, x, y) > (captain.target:getRadius() + captain.MAX_DISTANCE_AWAY_FROM_FLOCK) then
                return "returnToFlock"
            end
        end
    }))
    self.plan:add(Objective:new({
        name = "roam",
        enter = function(captain)
            captain.ship:orderRoaming()
        end,
        update = function(captain, delta)
            -- TODO: If any criminals in range, order them to stop and search them
            if captain.cortex.browncoat.ship:getReputationPoints() < captain.ILLEGAL_REP_THRESHOLD then
                local distanceToCriminal = captain:distance(captain.cortex.browncoat.ship, captain.ship)
                if distanceToCriminal < captain.ARREST_DISTANCE then
                    return "arrest"
                end
            end

            if delta > captain.MISSION_ROAM_TIMEOUT and not captain.ship:areEnemiesInRange(captain.ROAM_SCANNER_RANGE) then
                table.remove(captain.bulletins)
                return "default"
            end

            -- Check if we are too far from out flock
            local x, y = captain.target:getPosition()
            if captain:distance(captain.ship, x, y) > (captain.target:getRadius() + captain.MAX_DISTANCE_AWAY_FROM_FLOCK) then
                return "returnToFlock"
            end
        end
    }))
    self.plan:add(Objective:new({
        name = "arrest",
        enter = function(captain)
            captain.ship:sendCommsMessage(captain.cortex.browncoat.ship, [[
                HALT! Hold your position and prepare to be boarded
            ]])
        end,
        update = function(captain, delta)
            -- if the ship slows down, approach them
            if captain:hasBrowncoatStopped() then
                -- Stop close to them, so we don't crash into
                if captain:distance(captain.ship, captain.cortex.browncoat.ship) < 1000 then
                    captain.ship:orderIdle()
                    return "proceedWithArrest"
                end
            else
                if delta > captain.ARREST_TIMEOUT then
                    return "attackBrowncoat"
                end
                -- If they are running, chase them
                local x, y = captain.cortex.browncoat.ship:getPosition()
                captain.ship:orderFlyTowards(x, y)
            end
        end
    }))
    self.plan:add(Objective:new({
        name = "proceedWithArrest",
        enter = function(captain)
            captain.ship:sendCommsMessage(captain.cortex.browncoat.ship, [[
                Thankyou for complying. This will go on the official report
                Power down your weapons, if you move you will be fired upon

                You will now be arrested and thrown in the brig forever.
            ]])
        end,
        update = function(captain, delta)
            if not captain:hasBrowncoatStopped() then
                -- try to arrest them again, invoking the arrest step timeout
                return "arrest"
            end
            
            if captain:hasPoweredDownWeapons() and captain:hasDroppedShields() then
                captain.cortex.browncoat:shipSearched(captain)
                -- TODO: say someting else if arrested with contraband?
                captain.ship:sendCommsMessage(captain.cortex.browncoat.ship, [[
                    Everything seems to be in order. Be on your way.
                ]])
                return "default"
            end

            -- Wait for some time for weapon powerdown
            if delta > captain.SEARCH_DELAY then
                return "attackBrowncoat"
            end
        end
    }))
    self.plan:add(Objective:new({
        name = "attackBrowncoat",
        enter = function(captain)
            captain.ship:sendCommsMessage(captain.cortex.browncoat.ship, [[
                You've chosen to run. Prepare to die.
            ]])
            captain.ship:orderAttack(captain.cortex.browncoat.ship)
        end,
        update = function(captain, delta)
            if delta > 99999 and captain:distance(captain.ship, captain.cortex.browncoat.ship) > 9999 then
                return "default"
            end
        end
    }))

    self.planPassiveScan:add(Objective:new({
        name = "default",
        interval = self.CRIME_SCANNER_DELAY,
        update = function(captain)
            if captain:distance(captain.ship, captain.cortex.browncoat.ship) < captain.CRIME_SCANNER_RANGE then
                captain.cortex:reportSighting(captain.cortex.browncoat.ship)
            end
        end
    }))
    self.planPassiveScan:add(Objective:new({
        name = "browncoatSpotted",
        interval = self.CRIME_SCANNER_DELAY,
        enter = function(captain)
            captain.cortex:reportSighting(captain.cortex.browncoat.ship)
        end,
        update = function(captain, delta)
            if captain:distance(captain.ship, captain.cortex.browncoat.ship) > captain.CRIME_SCANNER_RANGE then
                return "default"
            end
        end
    }))
end

function AllianceNavyCaptain:update(delta)
    if not self:isValid() then
        return
    end

    self.plan:update(self, delta)
    self.planPassiveScan:update(self, delta)
end