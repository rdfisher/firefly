require("CivilianGroup")

Ship = {
    x, y
}
function Ship:new(x, y)
    local o = {
        x = x,
        y = y
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Ship:isValid()
    return true
end

function Ship:getPosition()
    return self.x, self.y
end

groups = {}
for i=1,4 do
    table.insert(groups, CivilianGroup:new())
end
function newAutotable(dim)
    local MT = {};
    for i=1, dim do
        MT[i] = {__index = function(t, k)
            if i < dim then
                t[k] = setmetatable({}, MT[i+1])
                return t[k];
            end
        end}
    end

    return setmetatable({}, MT[1]);
end

local f = newAutotable(2);
ships = {}
for i=1,100 do
    local ship = Ship:new(math.random(0, 40), math.random(0, 100))
    local x, y = ship:getPosition()
    table.insert(ships, {x=x, y=y})
    
    groups[1]:add(ship)
    --groups[math.random(#groups)]:add(ship)
    --groups[math.random(#groups-1)]:add(ship)
    --print(string.format("Ship position X: %d, Y: %d", x, y))
end

for i=1,10 do
    -- for _,ship in ipairs(ships) do
    --     f[ship.x][ship.y] = '.'
    -- end
    for i, v in ipairs(groups) do
        for _, ship in ipairs(v.civilians) do
            local x, y = ship:getPosition()
            f[math.floor(x)][math.floor(y)] = i
        end
        local x, y = v:getPosition()
        print(string.format("Cluster %d centroid position X: %d, Y: %d, size %d, radius %f", i, x, y, v:getSize(), v:getRadius()))
        f[math.floor(x)][math.floor(y)] = "."
    end
    local moved = CivilianGroup:balance(groups)

    for x=0,40 do
        for y=0,100 do
            local char = f[x][y]
            if char then
                io.write(char)
            else
                io.write(" ")
            end
            f[x][y] = " "
        end
        io.write("\n")
    end
    if moved < 1 then
        --break
    end
end

