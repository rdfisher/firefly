Cortex = {
    entries = {},
    last_sighting = 0,
    SIGHTING_REP_THRESHOLD = 600,
    SIGHTING_DELAY = 1,
    REP_ENEMY_THRESHOLD = 200,
    rep_check_timeout = 0,
    rep_timer = 0,
    REP_CHECK_DELAY = 1,
    REP_DELAY_BEFORE_INCREASE = 100
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
  if self.rep_timer < self.REP_DELAY_BEFORE_INCREASE then
    self.rep_timer = self.rep_timer + delta
  else
    -- 1 rep point per 10 seconds
    if self.browncoat.ship:getReputationPoints() < 1000 then
      self.browncoat.ship:addReputationPoints(delta * 0.1)
    end
  end
  if self.rep_check_timeout < self.REP_CHECK_DELAY then
      self.rep_check_timeout = self.rep_check_timeout + delta
  else
    self.rep_check_timeout = 0

    -- Switch factions and account for rep change
    local newFaction = "Browncoats"
    if self.browncoat:repEnemy() then
      newFaction = "Browncoats "
    end

    if self.browncoat.ship:getFaction() ~= newFaction then
      local rep = self.browncoat.ship:getReputationPoints()
      self.browncoat.ship:setFaction(newFaction)
      self.browncoat.ship:setReputationPoints(rep)
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

-- Piracy by browncoat, only used against the player in a mission
function Cortex:reportPiracy(ship)
    local x, y = ship:getPosition()
    local sector = ship:getSectorName()
    local callsign = ship:getCallSign()

    self:broadcastAlert(string.format("[APB] Ship %s is under attack! Sector %s", callsign, sector))
    table.insert(self.entries, Bulletin:distressCall(ship, callsign, sector, x, y))
    self.rep_timer = 0
end

function Cortex:gunshipUnderAttack(location)
    local x, y = location:getPosition()
    local sector = location:getSectorName()
    local callsign = location:getCallSign()
    
    self:broadcastAlert(string.format("[APB] Gunship %s is under attack! Sector %s", callsign, sector))
    table.insert(self.entries, Bulletin:new("backupRequired", location, callsign, sector, x, y))
end

function Cortex:reportSighting(target)
    if self.browncoat:repPettyCriminalOrBelow() then
        -- reset timer
        self.rep_timer = 0
        -- add bulletin
        local x, y = target:getPosition()
        local sector = target:getSectorName()
        local callsign = target:getCallSign()
        self:broadcastAlert(string.format("[APB] Illegal activity involving %s reported in Sector %s", callsign, sector))
        table.insert(self.entries, Bulletin:illegalActivity(callsign, sector, x, y))
    end
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
