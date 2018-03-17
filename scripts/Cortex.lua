Cortex = {
    entries = {},
    last_sighting = 0,
    SIGHTING_REP_THRESHOLD = 600,
    SIGHTING_DELAY = 1,
    REP_ENEMY_THRESHOLD = 200,
    rep_check_timeout = 0,
    REP_CHECK_DELAY = 10
}

function Cortex:new(wave, browncoat)
    local o = {}
    o.wave = wave
    o.browncoat = browncoat
    setmetatable(o, self)
    self.__index = self
    return o
end

function Cortex:update(delta)
    if self.rep_check_timeout < self.REP_CHECK_DELAY then
        self.rep_check_timeout = self.rep_check_timeout + delta
    else
        self.rep_check_timeout = 0
        if self.browncoat.ship:getReputationPoints() < self.REP_ENEMY_THRESHOLD then
            -- TODO: Set faction Alliance Navy to enemy
        else
            -- TODO: Set faction to friendly
        end
    end
end

function Cortex:reportAttack(ship)
    local x, y = ship:getPosition()
    local sector = ship:getSectorName()
    local callsign = ship:getCallSign()
    self:broadcastAlert(string.format("[APB] Ship %s is under attack! Sector %s", callsign, sector))
    table.insert(self.entries, Bulletin:distressCall(ship, callsign, sector, x, y))
end

function Cortex:enemySpotted(ship, target)
    local x, y = target:getPosition()
    local sector = target:getSectorName()
    local callsign = target:getCallSign()
    self:broadcastAlert(string.format("[APB] Enemy Ship %s spotted in Sector %s", callsign, sector))
    table.insert(self.entries, Bulletin:enemySpotted(callsign, sector, x, y))
end

function Cortex:illegalActivity(spaceObject)
    local x, y = spaceObject:getPosition()
    local sector = spaceObject:getSectorName()
    local callsign = spaceObject:getCallSign()
    self:broadcastAlert(string.format("[APB] Illegal activity involving %s reported in Sector %s", callsign, sector))
    table.insert(self.entries, Bulletin:illegalActivity(callsign, sector, x, y))

    -- Only used against the player
    self.rep_timer = 0
end

function Cortex:reportSighting(delta, target)
    -- if self.last_sighting < self.SIGHTING_DELAY then
    --     self.last_sighting = self.last_sighting + delta
    -- else
    --     self.last_sighting = 0
        if target:getReputationPoints() < self.SIGHTING_REP_THRESHOLD then
            -- reset timer
            self.rep_timer = 0
            -- add bulletin
            local x, y = target:getPosition()
            local sector = target:getSectorName()
            local callsign = target:getCallSign()
            self:broadcastAlert(string.format("[APB] Illegal activity involving %s reported in Sector %s", callsign, sector))
            table.insert(self.entries, Bulletin:illegalActivity(callsign, sector, x, y))
        end
    -- end
end

function Cortex:popLatestBulletin()
    if #self.entries > 0 then
        return table.remove(self.entries)
    end
    return false
end

function Cortex:broadcastAlert(message)
  self.wave:message(message)
end

Bulletin = {}

function Bulletin:new(type, ship, callsign, sector, x, y)
    local o = {
        t = type,
        ship = ship,
        callsign = callsign,
        sector = sector,
        x = x,
        y = y
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Attempt to get a more accurate position of a distress call
function Bulletin:getPosition()
    if self.t == "distressCall" then
        if self.ship:isValid() then
            self.x, self.y = self.ship:getPosition()
        end
    end
    return self.x, self.y
end

function Bulletin:distressCall(ship, callsign, sector, x, y)
    return Bulletin:new("distressCall", ship, callsign, sector, x, y)
end
-- Don't cheat by giving up enemy object
function Bulletin:enemySpotted(callsign, sector, x, y)
    return Bulletin:new("enemySpotted", nil, callsign, sector, x, y)
end
function Bulletin:illegalActivity(callsign, sector, x, y)
    return Bulletin:new("illegalActivity", nil, callsign, sector, x, y)
end
