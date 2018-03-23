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

ObjectivePlan = {}
function ObjectivePlan:new(debug)
    local o = {
        objectives = {},
        current = nil,
        debug = false
    }
    if debug then
        o.debug = true
    end
    setmetatable(o, self)
    self.__index = self
    return o
end
function ObjectivePlan:add(objective)
    table.insert(self.objectives, objective)
end
function ObjectivePlan:update(captain, delta)
    if self.current == nil then
        self.current = self:getIndexByName("default")
        self.objectives[self.current]:enter(captain)
    end
    local obj = self.objectives[self.current]
    local next = obj:update(captain, delta)
    if next ~= nil then
        self.current = self:getIndexByName(next)
        if self.debug then
            print(string.format("switching to state [%s]", self.objectives[self.current].name))
        end
        self.objectives[self.current]:enter(captain)
    end
end
function ObjectivePlan:getIndexByName(name)
    for i, o in ipairs(self.objectives) do
        if o.name == name then
            return i
        end
    end
end

Objective = {}
function Objective:new(objective)
    --TODO: error out if any typos
    local o = {
        name = "default",
        timer = 0,
        interval = 1,
        time_spent_here = 0,
        updateFunction = function() end,
        enterFunction = function() end,
        state = {} -- custom state table
    }
    if objective.name ~= nil then
        o.name = objective.name
    end
    if objective.interval ~= nil then
        o.interval = objective.interval
    end
    if objective.enter ~= nil then
        o.enterFunction = objective.enter
    end
    if objective.update ~= nil then
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
        return self.updateFunction(captain, self.time_spent_here, self.state)
    end
end
function Objective:enter(captain)
    self.time_spent_here = 0
    self.enterFunction(captain, self.state)
end