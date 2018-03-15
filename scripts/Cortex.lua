Cortex = {
    entries = {}
}

function Cortex:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Cortex:reportAttack(ship, sector, position)
    print(string.format("Ship %s is under attack! Sector %s", ship:getCallSign(), sector))
    table.insert(self.entries, CortexEntry:new(ship, sector, position))
end

function Cortex:popLatestBulletin()
    if #self.entries > 0 then
        return table.remove(self.entries)
    end
    return false
end


CortexEntry = {
    ship = nil,
    sector = nil,
    position = nil
}

function CortexEntry:new(ship, sector, position)
    local o = {
        ship = ship,
        sector = sector,
        position = position,
        investigated = false
    }
    setmetatable(o, self)
    self.__index = self
    return o
end