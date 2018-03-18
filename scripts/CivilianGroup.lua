CivilianGroup = {
  civilians = {},
  defaultX = 0,
  defaultY = 0
}

function CivilianGroup:cost(a, b)
  return self:distance(a, b) * (#a.civilians + 1) * (#b.civilians + 1)
end

function CivilianGroup:balance(groups)
    local moved = 0
    for _, a in ipairs(groups) do
      for _, b in ipairs(groups) do
        if a ~= b then
          for i, ship in ipairs(b.civilians) do
            local prev_cost = self:cost(a, b)
            table.insert(a.civilians, table.remove(b.civilians, i))
            local new_cost = self:cost(a, b)
            moved = moved + 1
            if new_cost < prev_cost then
              -- revert
              moved = moved - 1
              table.insert(b.civilians, table.remove(a.civilians))
            end
          end
        end
      end
    end
    return moved
end

function CivilianGroup:distance(a, b, c, d)
    local x1, y1 = 0, 0
    local x2, y2 = 0, 0
    if type(a) == "table" and type(b) == "table" then
        -- a and b are bth tables.
        -- Assume distance(obj1, obj2)
        x1, y1 = a:getPosition()
        x2, y2 = b:getPosition()
    elseif type(a) == "table" and type(b) == "number" and type(c) == "number" then
        -- Assume distance(obj, x, y)
        x1, y1 = a:getPosition()
        x2, y2 = b, c
    elseif type(a) == "number" and type(b) == "number" and type(c) == "table" then
        -- Assume distance(x, y, obj)
        x1, y1 = a, b:getPosition()
        x2, y2 = c:getPosition()
    elseif type(a) == "number" and type(b) == "number" and type(c) == "number" and type(d) == "number" then
        -- a and b are both tables.
        -- Assume distance(obj1, obj2)
        x1, y1 = a, b
        x2, y2 = c, d
    else
        -- Not a valid use of the distance function. Throw an error.
        print(type(a), type(b), type(c), type(d))
        error("distance() function used incorrectly", 2)
    end
    local xd, yd = (x1 - x2), (y1 - y2)
    return math.sqrt(xd * xd + yd * yd)
end

function CivilianGroup:new (defaultX, defaultY)
  local o = {civilians = {}, defaultX = 0, defaultY = 0}
  o.defaultX = defaultX
  o.defaultY = defaultY
  setmetatable(o, self)
  self.__index = self
  return o
end

function CivilianGroup:add(civilian) 
  table.insert(self.civilians, civilian)
end

function CivilianGroup:remove()
  return table.remove(self.civilians)
end

-- Get largest radius
function CivilianGroup:getRadius()
  if #self.civilians < 1 then
    return 0.0
  end
  local x, y = self:getPosition()
  local distances = {}
  for _, c in ipairs(self.civilians) do
    table.insert(distances, self:distance(c, x, y))
  end
  table.sort(distances)
  return distances[#distances]
end

-- Get centre
function CivilianGroup:getPosition()
  local numberOfCivilians = #self.civilians
  if numberOfCivilians == 0 then
    return self.defaultX, self.defaultY
  end
  local xTotal = 0;
  local yTotal = 0;
  for i, civilian in ipairs(self.civilians) do
    if civilian:isValid() then
      local x, y = civilian:getPosition()
      xTotal = xTotal + x
      yTotal = yTotal + y
    else -- auto clean up ? 
      table.remove(self.civilians, i)
    end
  end
  local xMean = xTotal / numberOfCivilians
  local yMean = yTotal / numberOfCivilians
  return xMean, yMean
end

function CivilianGroup:cleanup()
  for i, civilian in ipairs(self.civilians) do
    if not civilian:isValid() then
      table.remove(self.civilians, i)
    end
  end
end

function CivilianGroup:getSize()
  return #self.civilians
end
