Cortex = {
    entries = {},
    wave = {}
}

function Cortex:new(wave)
    local o = {}
    o.wave = wave
    setmetatable(o, self)
    self.__index = self
    return o
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
