Verse = {stations = {}, byName = {}}

function Verse:new()
  local o = {stations = {}, byName = {}}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Verse:getCentre(scale)
  return (12.5 * scale), (5 * scale)
end

function Verse:generate(scale)
  -- overall dimensions: 25x 10y
  
  -- stars
    -- white sun 0 0
    self.byName['whiteSun'] = Planet():setPosition(scale * 12.5, scale * 5):setPlanetRadius(0.1 * scale):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,1.0,1.0)

    -- lux
    self.byName['lux'] = Planet():setPosition(14.5 * scale, 2.2 * scale):setPlanetRadius(0.06 * scale):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,1.0,0)

    -- qin shi huang 
    self.byName['qinshihuang'] = Planet():setPosition(10 * scale, 7.5 * scale):setPlanetRadius(0.06 * scale):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,1.0,0)

    -- georgia -5.5 -3
    self.byName['georgia'] = Planet():setPosition(7 * scale, 2 * scale):setPlanetRadius(0.08 * scale):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,1.0,0.25)
    
    -- murphy -7 0
    self.byName['murphy'] = Planet():setPosition(5 * scale, 5 * scale):setPlanetRadius(0.05 * scale):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,1.0,0.25)
    
    -- burnham -12.5 -5
    self.byName['burnham'] = Planet():setPosition(0 * scale, 0 * scale):setPlanetRadius(0.04 * scale):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(0.7,0.7,0.7)
    
    -- kalidasa 12 0
    self.byName['kalidasa'] = Planet():setPosition(24.5 * scale, 5 * scale):setPlanetRadius(0.1 * scale):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,1.0,1.0)
    
    -- blue sun -12 3
    self.byName['blueSun'] = Planet():setPosition(0.5 * scale, 8 * scale):setPlanetRadius(0.1 * scale):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(0.2,0.2,1.0)
    
    -- red sun 5.5 2.5
    self.byName['redSun'] = Planet():setPosition(20 * scale, 7.5 * scale):setPlanetRadius(0.08 * scale):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,0.1,0.1)
    
    -- himinbjorg 5.5 -0.5
    self.byName['himinbjorg'] = Planet():setPosition(17.5 * scale, 4.5 * scale):setPlanetRadius(0.1 * scale):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0, 0.8, 0.25)
    
    -- penglai 10 3.5
    self.byName['penglai'] = Planet():setPosition(12.5 * scale, 8.5 * scale):setPlanetRadius(0.06 * scale):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,0.8,0.25)
    
    -- Heinlein 2.8 4.5
    self.byName['heinlein'] = Planet():setPosition(15.3 * scale, 9.5 * scale):setPlanetRadius(0.04 * scale):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,0.8,0.25)
      
  -- planets + moons (stations)
    -- cortex relay 7: Mr Universe
    self.byName['cortex-relay-7'] = SpaceStation():setTemplate("Medium Station"):setFaction("neutral"):setCanBeDestroyed(false):setPosition(2.75 * scale, 7.5 * scale):setCallSign("cortex-relay-7")
    
    -- ezra: Niska
    self.byName['ezra'] = SpaceStation():setTemplate("Medium Station"):setFaction("neutral"):setCanBeDestroyed(false):setPosition(7.2 * scale, 2.2 * scale):setCallSign("ezra")
    
    -- athens: Patience
    self.byName['athens'] = SpaceStation():setTemplate("Medium Station"):setFaction("neutral"):setCanBeDestroyed(false):setPosition(9.5 * scale, 3.5 * scale):setCallSign("athens")
    
    -- persephone: Badger
    self.byName['persephone'] = SpaceStation():setTemplate("Medium Station"):setFaction("neutral"):setCanBeDestroyed(false):setPosition(14.95 * scale, 2.1 * scale):setCallSign("persephone")
    
    -- space bazaar: Amnon Duul
    self.byName['space-bazaar'] = SpaceStation():setTemplate("Medium Station"):setFaction("neutral"):setCanBeDestroyed(false):setPosition(16.5 * scale, 6 * scale):setCallSign("space-bazaar")
    
    -- silverhold
    self.byName['silverhold'] = SpaceStation():setTemplate("Medium Station"):setFaction("neutral"):setCanBeDestroyed(false):setPosition(15.2 * scale, 9.5 * scale):setCallSign("silverhold")
    
  -- asteroids
end

function Verse:getStations()
  return this.stations
end