CivilianGroup = {
  civilians = {}
}

function CivilianGroup:balance(groups)
    -- Sort by biggest cluster
    table.sort(groups, function(a, b)
        return a:getRadius() < b:getRadius()
    end)

    for i, c in ipairs(groups) do
        local x, y = c:getPosition()
        --print(string.format("Cluster %d centroid position X: %f, Y: %f, size %d, radius %f", i, x, y, c:getSize(), c:getRadius()))
    end
    local g = groups[1] -- smallest cluster
    local v = groups[#groups] -- biggest cluster
    --print(string.format("Size difference (%d/%d) = %d", g:getSize(), v:getSize(), (v:getSize()-g:getSize())))
    --print(string.format("Radius difference (%d/%d) = %d", g:getRadius(), v:getRadius(), (v:getRadius()-g:getRadius())))
    local x, y = g:getPosition()
    --print(string.format("Picked point %f, %f", x, y))
    local count = math.floor(
      ((v:getSize() + v:getRadius()) - (g:getSize() + g:getRadius())) / 5
    )
    if count < 5 then
        count = 0
    end
    local ships = v:popClosestTo(x, y, count)
    for _, ship in ipairs(ships) do
        g:add(ship)
    end
    return count
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

function CivilianGroup:new ()
  local o = {civilians = {}}
  setmetatable(o, self)
  self.__index = self
  return o
end

function CivilianGroup:add(civilian) 
  table.insert(self.civilians, civilian)
end

function CivilianGroup:popClosestTo(x, y, count)
  local cx, cy = self:getPosition()
  table.sort(self.civilians, function(a, b)
    -- But also furthest away from our centre
    -- local total = self:distance(x, y, cx, cy)
    -- local da = total - self:distance(a, cx, cy) + self:distance(a, x, y)
    -- local db = total - self:distance(b, cx, cy) + self:distance(b, x, y)
    local da = self:distance(a, x, y)
    local db = self:distance(b, x, y)
    return  da < db
  end)
  output = {}
  for i=1,count do
    table.insert(output, table.remove(self.civilians))
  end
  print(string.format("Moving %d ships", count))
  for i,v in ipairs(output) do
    print(string.format("Ship %d distance %f", i, self:distance(v, x, y)))
  end
  return output
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
    return 0, 0
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
