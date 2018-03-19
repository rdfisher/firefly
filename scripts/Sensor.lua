--[[
Vary the detection parameter based on current reactor output (plus if shields
are up or down). Reactor on this ship is very huge (probably designed for a warp
drive). 10 minutes of runtime just from full storage, with reactor to 0%, 25
minutes with just running away.
Only works with passive sensors. If the enemy is roaming, they will find you
with regular active sensors

- Freighters min range is 5U, Alliance min range is 10U

Table:
Reactor power =  0% Detection range =  5 U
Reactor power = 20% Detection range = 10 U
Reactor power = 40% Detection range = 15 U
Reactor power = 60% Detection range = 20 U
Reactor power = 80% Detection range = 25 U
Reactor power =100% Detection range = 30 U
Reactor power =120% Detection range = 35 U
Reactor power =140% Detection range = 40 U
Reactor power =160% Detection range = 45 U
Reactor power =180% Detection range = 50 U
Reactor power =200% Detection range = 55 U
Reactor power =220% Detection range = 60 U
Reactor power =240% Detection range = 65 U
Reactor power =260% Detection range = 70 U
Reactor power =280% Detection range = 75 U
]]

Sensor = {
    MAX = 50000,
    MIN = 5000
}

function Sensor:new(browncoat)
    local o = {}
    o.browncoat = browncoat
    setmetatable(o, self)
    self.__index = self
    return o
end

function Sensor:getRange()
    if self.browncoat:getShieldsActive() then
        return self.MAX
    end
    -- Attennuate the level based on reactor power
    local reactorPower = self.browncoat:getSystemPower("reactor")
    local range = self.MAX - self.MIN
    local x = reactorPower*25000 + self.MIN
    return x
end

-- Clamp range of military ships to min 10U
function Sensor:getMilitaryRange()
    local range = self:getRange()
    return math.max(range, 10000)
end

function Sensor:getEnemyRange()
    return 10000
end