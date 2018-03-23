--[[
Ship speed tweaks: Settings: Impulse 90, warp1 250
- Nominal: Everything to 100% (impulse 5.4U/m) (warp1 40% cooling 15U/m)
- Maximum: Speed with 300% to the engines (impulse 16.2U/m)(warp4 180U/m)
- Cruising: max speed without overheating, (230% on impulse 12.4U/m) (warp2 130% 39U/m) (alt warp3 2 crew 100% 45U/m)
- Power saving: Max energy positive speed (impulse 230% 12.4U/m) (warp1 200% 30U/m) 

Impulse
Mode        Power % | Cooling % | Energy Use | Speed U/m | Time until damage |
Nominal     100%    | 0%        |            | 5.4       |                   |
Maximum     300%    | 100%      |            | 16.2      | ~30s              |
Cruising    230%    | 100%      |            | 12.4      |                   |
Power+      230%    | 100%      | +70/m      | 12.4      |                   |

Warp
Mode        Power % | Cooling % | Energy Use | Warp Speed | Speed U/m        | TTD  | TTE   |
Nominal     100%    | 40%       | +0/m       | 1          | 15U/m            | N/A  | N/A   |
Maximum     300%    | 100%      | -268/m     | 4          | 180U/m           | 2s   | 3.7m  |
Cruising    130%    | 100%      | -49/m      | 2          | 39U/m            | N/A  | 20.4m |
AltCruising 100%    | 100%      | -128/m     | 3          | 45U/m            | N/A* | 7.81m |
Power+      200%    | 100%      | +70/m      | 1          | 30U/m            | N/A  | N/A   |

Time limited modes
Warp 3 100% -220/m 60U/m TTD 31s
Warp 2 200% -65/m 60U/m TTD 42s
Warp 2 170% -58/m 51U/m TTD 1m10s

I = 30U/s
M = maximum speed
D = duration maximum speed can be maintained (before battery runs out or ship explodes from the heat) in minutes
D = 
S = sensor range in U
X = cruiser warp1 speed

X > I
D(M - X) > S

Warp 2 is top cruising speed, at speed(250) ends up being 30-42U/m
]]
-- Player ship

template = ShipTemplate():setName("Serenity"):setClass("Corvette", "Destroyer"):setModel("battleship_destroyer_1_upgraded")
template:setRadarTrace("radar_dread.png")
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0,100, -20, 1500.0, 6.0, 8)
template:setBeam(1,100,  20, 1500.0, 6.0, 8)
template:setBeam(2,100, 180, 1500.0, 6.0, 8)
template:setTubes(4, 10.0)
template:setWeaponStorage("HVLI", 20)
template:setWeaponStorage("Homing", 4)
template:setTubeDirection(0, -90)
template:setTubeDirection(1, -90)
template:setTubeDirection(2,  90)
template:setTubeDirection(3,  90)

template:setType("playership")
template:setDescription([[A refitted Atlantis X23 for more general tasks. The large shield system has been replaced with an advanced combat maneuvering systems and improved impulse engines. Its missile loadout is also more diverse. Mistaking the modified Atlantis for an Atlantis X23 would be a deadly mistake.]])
template:setShields(200, 200)
template:setHull(250)

template:setJumpDrive(false)
template:setSpeed(90, 10, 20) -- Cruising speed 180
template:setWarpSpeed(250) -- 1/4 of default (warp1)
template:setCombatManeuver(400, 250)

template:setBeam(2, 0, 0, 0, 0, 0)
template:setWeaponStorage("Homing", 12)
template:setWeaponStorage("Nuke", 4)
template:setWeaponStorage("Mine", 8)
template:setWeaponStorage("EMP", 6)
template:setTubes(5, 8.0) -- Amount of torpedo tubes, and loading time of the tubes.
template:weaponTubeDisallowMissle(0, "Mine"):weaponTubeDisallowMissle(1, "Mine")
template:weaponTubeDisallowMissle(2, "Mine"):weaponTubeDisallowMissle(3, "Mine")
template:setTubeDirection(4, 180):setWeaponTubeExclusiveFor(4, "Mine")

template:addRoomSystem(1, 0, 2, 1, "Maneuver");
template:addRoomSystem(1, 1, 2, 1, "BeamWeapons");
template:addRoom(2, 2, 2, 1);

template:addRoomSystem(0, 3, 1, 2, "RearShield");
template:addRoomSystem(1, 3, 2, 2, "Reactor");
template:addRoomSystem(3, 3, 2, 2, "Warp");
template:addRoomSystem(5, 3, 1, 2, "JumpDrive");
template:addRoom(6, 3, 2, 1);
template:addRoom(6, 4, 2, 1);
template:addRoomSystem(8, 3, 1, 2, "FrontShield");

template:addRoom(2, 5, 2, 1);
template:addRoomSystem(1, 6, 2, 1, "MissileSystem");
template:addRoomSystem(1, 7, 2, 1, "Impulse");

template:addDoor(1, 1, true);
template:addDoor(2, 2, true);
template:addDoor(3, 3, true);
template:addDoor(1, 3, false);
template:addDoor(3, 4, false);
template:addDoor(3, 5, true);
template:addDoor(2, 6, true);
template:addDoor(1, 7, true);
template:addDoor(5, 3, false);
template:addDoor(6, 3, false);
template:addDoor(6, 4, false);
template:addDoor(8, 3, false);
template:addDoor(8, 4, false);


-- Alliance Cruiser
template = ShipTemplate():setName("Tohoku"):setClass("Corvette", "Destroyer"):setModel("battleship_destroyer_4_upgraded")
template:setDescription([[Contrary to its predecessor, the Starhammer II lives up to its name. By resolving the original Starhammer's power and heat management issues, the updated model makes for a phenomenal frontal assault ship. Its low speed makes it difficult to position, but when in the right place at the right time, even the strongest shields can't withstand a Starhammer's assault for long.]])
template:setRadarTrace("radar_dread.png")
template:setHull(200)
template:setShields(450, 350, 150, 150, 350)
-- template:setSpeed(35, 6, 10)
-- CPU Ships always travel at warp 1
--template:setWarpDrive(false)
--template:setWarpSpeed(250/15 * 45) -- Should be about 40U/m
template:setSpeed(90/5.4 * 45, 60, 200)
template:setJumpDrive(false)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 60, -10, 2000.0, 8.0, 11)
template:setBeam(1, 60,  10, 2000.0, 8.0, 11)
template:setBeam(2, 60, -20, 1500.0, 8.0, 11)
template:setBeam(3, 60,  20, 1500.0, 8.0, 11)
template:setTubes(2, 10.0)
template:setWeaponStorage("HVLI", 20)
template:setWeaponStorage("Homing", 4)
template:setWeaponStorage("EMP", 2)
template:weaponTubeDisallowMissle(1, "EMP")

-- Transport Ship
-- template = ShipTemplate():setName("Flavia"):setClass("Frigate", "Light transport"):setModel("LightCorvetteGrey")
-- template:setRadarTrace("radar_tug.png")
-- template:setDescription([[Popular among traders and smugglers, the Flavia is a small cargo and passenger transport. It's cheaper than a freighter for small loads and short distances, and is often used to carry high-value cargo discreetly.]])
-- template:setHull(50)
-- template:setShields(50, 50)
-- template:setSpeed(30, 8, 10)

-- Possible replacement for transport ships
-- for cnt=1,5 do
--     template = ShipTemplate():setName("Personnel Freighter " .. cnt):setClass("Corvette", "Freighter"):setModel("transport_1_" .. cnt)
--     template:setDescription([[These freighters are designed to transport armed troops, military support personnel, and combat gear.]])
--     template:setHull(100)
--     template:setShields(50, 50)
--     template:setSpeed(60 - 5 * cnt, 6, 10)
--     template:setRadarTrace("radar_transport.png")
    
--     if cnt > 2 then
--         variation = template:copy("Personnel Jump Freighter " .. cnt)
--         variation:setJumpDrive(true)
--     end

--     template = ShipTemplate():setName("Goods Freighter " .. cnt):setClass("Corvette", "Freighter"):setModel("transport_2_" .. cnt)
--     template:setDescription([[Cargo freighters haul large loads of cargo across long distances on impulse power. Their cargo bays include climate control and stabilization systems that keep the cargo in good condition.]])
--     template:setHull(100)
--     template:setShields(50, 50)
--     template:setSpeed(60 - 5 * cnt, 6, 10)
--     template:setRadarTrace("radar_transport.png")
    
--     if cnt > 2 then
--         variation = template:copy("Goods Jump Freighter " .. cnt)
--         variation:setJumpDrive(true)
--     end
    
--     template = ShipTemplate():setName("Garbage Freighter " .. cnt):setClass("Corvette", "Freighter"):setModel("transport_3_" .. cnt)
--     template:setDescription([[These freighters are specially designed to haul garbage and waste. They are fitted with a trash compactor and fewer stabilzation systems than cargo freighters.]])
--     template:setHull(100)
--     template:setShields(50, 50)
--     template:setSpeed(60 - 5 * cnt, 6, 10)
--     template:setRadarTrace("radar_transport.png")
    
--     if cnt > 2 then
--         variation = template:copy("Garbage Jump Freighter " .. cnt)
--         variation:setJumpDrive(true)
--     end

--     template = ShipTemplate():setName("Equipment Freighter " .. cnt):setClass("Corvette", "Freighter"):setModel("transport_4_" .. cnt)
--     template:setDescription([[Equipment freighters have specialized environmental and stabilization systems to safely carry delicate machinery and complex instruments.]])
--     template:setHull(100)
--     template:setShields(50, 50)
--     template:setSpeed(60 - 5 * cnt, 6, 10)
--     template:setRadarTrace("radar_transport.png")
    
--     if cnt > 2 then
--         variation = template:copy("Equipment Jump Freighter " .. cnt)
--         variation:setJumpDrive(true)
--     end

--     template = ShipTemplate():setName("Fuel Freighter " .. cnt):setClass("Corvette", "Freighter"):setModel("transport_5_" .. cnt)
--     template:setDescription([[Fuel freighters have massive tanks for hauling fuel, and delicate internal sensors that watch for any changes to their cargo's potentially volatile state.]])
--     template:setHull(100)
--     template:setShields(50, 50)
--     template:setSpeed(60 - 5 * cnt, 6, 10)
--     template:setRadarTrace("radar_transport.png")
    
--     if cnt > 2 then
--         variation = template:copy("Fuel Jump Freighter " .. cnt)
--         variation:setJumpDrive(true)
--     end
-- end
