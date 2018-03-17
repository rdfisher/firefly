--[[
    ObjectivePlan:new()
    ObjectivePlan:add(Objective:new({
        name = "foo",
        interval = 5,
        enter = function() end,
        update = function() end,
    }))
    ObjectivePlan:update(delta)


    Objective condition engine
    Objective:onEnter()
    Objective:update(delta) => return type:
        false: don't proceed to next Objective
        "string": Objective complete, pick next one in the table

]]

ObjectivePlan = {
    objectives = {},
    current = nil
}
function ObjectivePlan:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end
function ObjectivePlan:add(objective)
    table.insert(self.objectives, objective)
end
function ObjectivePlan:update(captain, delta)
    local obj = self:getCurrentObjective()
    local next = obj:update(captain, delta)
    if next ~= nil then
        self.current = self:getIndexByName(next)
        self:getCurrentObjective():enter(captain)
    end
end
function ObjectivePlan:getIndexByName(name)
    for i, o in ipairs(self.objectives) do
        if o.name == name then
            return i
        end
    end
end
function ObjectivePlan:getCurrentObjective()
    if self.current == nil then
        self.current = self:getIndexByName("default")
    end
    return self.objectives[self.current]
end

Objective = {
    timer = 0,
    interval = false,
    updateFunction = function() end,
    time_spent_here = 0
}
function Objective:new(objective)
    --TODO: error out if any typos
    local o = {}
    o.name = objective.name
    if objective.interval ~= nil then
        o.interval = objective.interval
    end
    o.enterFunction = objective.enter
    if objective.updateFunction ~= nil then
        o.updateFunction = objective.update
    end
    setmetatable(o, self)
    self.__index = self
    return o
end
function Objective:update(captain, delta)
    self.time_spent_here = self.time_spent_here + delta
    if self.interval ~= false and self.timer < self.interval then
        self.timer = self.timer + delta
    else
        self.timer = 0
        return self.updateFunction(captain, self.time_spent_here)
    end
end
function Objective:enter(captain)
    self.time_spent_here = 0
    self.enterFunction(captain)
end