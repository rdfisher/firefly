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

    -- Cleanup
    for i, v in ipairs(self.navyShips) do
        if not v:isValid() then
            table.remove(self.navyShips, i)
        end
    end

    -- If this is a distress call, get to the navy ship in charge
    if bulletin.t == "distressCall" then
        local ship = self:findResponsibleShip(bulletin.callsign)
        if ship ~= nil then
            ship:investigate(bulletin)
            return
        end
    end

    -- Find the closest ship
    local ship = self:findClosestShip(bulletin.x, bulletin.y)
    -- Give it a mission to investigate
    ship:investigate(bulletin)
end

function AllianceNavyDispatcher:findResponsibleShip(callsign)
    for i, v in ipairs(self.navyShips) do
        for _, charge in ipairs(v.target) do
            if charge:isValid() and charge:getCallSign() == bulletin.callsign then
                return v
            end
        end
    end
end

-- Room for improvement:
-- effectiveLocation: hasTarget ? target : location
-- effectiveDistance: distance(effectiveLocation) * (numberOfJobs + 1)
function AllianceNavyDispatcher:findClosestShip(x, y)
    -- TODO: find closest ship
    table.sort(self.navyShips, function(a, b)
        local da = distance(a.ship, x, y)
        local db = distance(b.ship, x, y)
        return da < db
    end)
    -- for i, v in ipairs(self.navyShips) do
    --     print(string.format("#%d Ship %s Queue: %d, Distance: %f",
    --         i, v.ship:getCallSign(), v:howBusy(), distance(v.ship, x, y)
    --     ))
    -- end
    return self.navyShips[1]
end

