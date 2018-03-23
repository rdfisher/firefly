require("utils.lua")

AllianceNavyDispatcher = {
    cortex = nil,
    gunships = {},
    tohokus = {}
}

-- Its job is to follow up on the codex, and dispatch available ships to investigate
function AllianceNavyDispatcher:new(cortex)
    local o = {}
    o.cortex = cortex
    setmetatable(o, self)
    self.__index = self
    return o
end

function AllianceNavyDispatcher:addGunship(ship)
    table.insert(self.gunships, ship)
end

function AllianceNavyDispatcher:addTohoku(ship)
    table.insert(self.tohokus, ship)
end

function AllianceNavyDispatcher:update(delta)
    local bulletin = self.cortex:popLatestBulletin()
    -- TODO: Check if bulletin is still valid?
    if not bulletin then
        return
    end

    -- Cleanup
    for i, v in ipairs(self.gunships) do
        if not v:isValid() then
            table.remove(self.gunships, i)
        end
    end

    -- if this is an alliance gunship, send backup
    if bulletin.t == "backupRequired" then
        local ship = self:findClosestTohoku(bulletin.x, bulletin.y)
        ship:investigate(bulletin)
        return
    end

    -- Find the closest ship
    local ship = self:findClosestGunship(bulletin.x, bulletin.y)
    -- Give it a mission to investigate
    ship:investigate(bulletin)
end

function AllianceNavyDispatcher:findClosestTohoku(x, y)
    return self.tohokus[math.random(#self.tohokus)]
end

function AllianceNavyDispatcher:findResponsibleShip(callsign)
    for i, v in ipairs(self.gunships) do
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
function AllianceNavyDispatcher:findClosestGunship(x, y)
    -- TODO: find closest ship
    table.sort(self.gunships, function(a, b)
        local da = distance(a.ship, x, y)
        local db = distance(b.ship, x, y)
        return da < db
    end)
    -- for i, v in ipairs(self.gunships) do
    --     print(string.format("#%d Ship %s Queue: %d, Distance: %f",
    --         i, v.ship:getCallSign(), v:howBusy(), distance(v.ship, x, y)
    --     ))
    -- end
    return self.gunships[1]
end

