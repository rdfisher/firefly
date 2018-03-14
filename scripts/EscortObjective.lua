EscortObjective = {
    ship = {},
    target = {}
}

function EscortObjective:new()
    local o = {ship = {}, target = {}}
    setmetatable(o, self)
    self.__index = self
    return o
end

function EscortObjective:assignShip(ship)
  self.ship = ship
end

function EscortObjective:assignTarget(target)
  self.target = target
end

function EscortObjective:update(delta)
  local x, y = group:getPosition()
  self.ship:orderFlyTowards(x, y)
end