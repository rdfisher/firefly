AllianceNavyDispatcher = {
    cortex = nil,
    navyShips = {}
}

-- Its job is to follow up on the codex, and dispatch available ships to investigate
function AllianceNavyDispatcher:new(cortex)
    local o = {
        cortex = cortex
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function AllianceNavyDispatcher:addNavyShip(ship)
    table.insert(self.navyShips, ship)
end

function AllianceNavyDispatcher:update(delta)
    local bulletin = self.cortex:popLatestBulletin()
    -- TODO: Check if bulletin is still valid?
    if not bulletin then
        return
    end

    print(string.format("Ship %s is under attack! Sector %s", bulletin.ship:getCallSign(), bulletin.sector))
    -- Find the closest ship
    local ship = self:findClosestShip()
    -- Give it a mission to investigate
    ship:investigate(bulletin)
end

function AllianceNavyDispatcher:findClosestShip()
    -- TODO: find closest ship algo
    return self.navyShips[math.random(#self.navyShips)]
end

