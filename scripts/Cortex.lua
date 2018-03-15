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

function Cortex:reportAttack(ship, sector, x, y)
    self:broadcastAlert(string.format("Ship %s is under attack! Sector %s", ship:getCallSign(), sector))
    table.insert(self.entries, CortexEntry:new(ship, sector, x, y))
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

CortexEntry = {
    ship = nil,
    sector = nil,
    x = nil,
    y = nil
}

function CortexEntry:new(ship, sector, x, y)
    local o = {
        ship = ship,
        sector = sector,
        x = x,
        y = y
    }
    setmetatable(o, self)
    self.__index = self
    return o
end