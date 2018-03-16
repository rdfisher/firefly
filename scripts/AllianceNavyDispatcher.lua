require("utils.lua")

AllianceNavyDispatcher = {
    cortex = nil,
    navyShips = {}
}

-- Its job is to follow up on the codex, and dispatch available ships to investigate
function AllianceNavyDispatcher:new(cortex)
    local o = {}
    o.cortex = cortex
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

    print(string.format("Ship %s is under attack! Sector %s", bulletin.callsign, bulletin.sector))
    -- Cleanup
    for i, v in ipairs(self.navyShips) do
        if not v:isValid() then
            table.remove(self.navyShips, i)
        end
    end

    -- Find the closest ship
    local ship = self:findClosestShip(bulletin.x, bulletin.y)
    -- Give it a mission to investigate
    ship:investigate(bulletin)
end

-- Room for improvement:
-- effectiveLocation: hasTarget ? target : location
-- effectiveDistance: distance(effectiveLocation) * (numberOfJobs + 1)
function AllianceNavyDispatcher:findClosestShip(x, y)
    -- TODO: find closest ship, less busy ship algo
    table.sort(self.navyShips, function(a, b)
        -- local qa = a:howBusy()
        -- local qb = b:howBusy()

       -- if qa == qb then
            local da = distance(a.ship, x, y)
            local db = distance(b.ship, x, y)
            return da < db
        -- end

        -- return qa < qb
    end)
    for i, v in ipairs(self.navyShips) do
        print(string.format("#%d Ship %s Queue: %d, Distance: %f",
            i, v.ship:getCallSign(), v:howBusy(), distance(v.ship, x, y)
        ))
    end
    return self.navyShips[1]
end

