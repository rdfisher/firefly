Verse = {stations = {}, byName = {}}

function Verse:new()
  local o = {stations = {}, byName = {}}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Verse:generate(scale)
  -- overall dimensions: 25x 10y
  
  -- stars
    -- white sun 0 0
    self.byName['whiteSun'] = Planet():setPosition(0, 0):setPlanetRadius(0.1 * scale):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,1.0,1.0)

    -- georgia -5.5 -3
    self.byName['georgia'] = Planet():setPosition(-5.5 * scale, -3 * scale):setPlanetRadius(0.08 * scale):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,1.0,0.25)
    
    -- murphy -7 0
    self.byName['murphy'] = Planet():setPosition(-7 * scale, 0):setPlanetRadius(0.05 * scale):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,1.0,0.25)
    
    -- burnham -12.5 -5
    self.byName['burnham'] = Planet():setPosition(-12.5 * scale, -5 * scale):setPlanetRadius(0.04 * scale):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(0.7,0.7,0.7)
    
    -- kalidasa 12 0
    self.byName['kalidasa'] = Planet():setPosition(12 * scale, 0):setPlanetRadius(0.1 * scale):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,1.0,1.0)
    
    -- blue sun -12 3
    self.byName['blueSun'] = Planet():setPosition(-12 * scale, 3 * scale):setPlanetRadius(0.1 * scale):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(0.2,0.2,1.0)
    
    -- red sun 11 2.5
    self.byName['redSun'] = Planet():setPosition(11 * scale, 2.5 * scale):setPlanetRadius(0.08 * scale):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,0.1,0.1)
    
    -- himinbjorg 5.5 -0.5
    self.byName['himinbjorg'] = Planet():setPosition(5.5 * scale, -0.5 * scale):setPlanetRadius(0.1 * scale):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0, 0.8, 0.25)
    
    -- penglai 10 3.5
    self.byName['penglai'] = Planet():setPosition(10 * scale, 3.5 * scale):setPlanetRadius(0.06 * scale):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,0.8,0.25)
    
    -- Heinlein 2.8 4.5
    self.byName['heinlein'] = Planet():setPosition(2.8 * scale, 4.5 * scale):setPlanetRadius(0.04 * scale):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,0.8,0.25)
      
  -- planets + moons
  
  -- stations
  
  -- asteroids
end

function Verse:getStations()
  return this.stations
end