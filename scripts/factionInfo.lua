neutral = FactionInfo():setName("neutral")
neutral:setGMColor(128, 128, 128)
neutral:setDescription([[Inanimate things]])


independentFaction = FactionInfo():setName("Independent")
independentFaction:setGMColor(128, 128, 128)
independentFaction:setDescription([[Despite appearing as a faction, independents are distinguished primarily by having no strong affiliation with any  at all. Most traders consider themselves independent, though certain voices have started to speak up about creating a merchant faction.]])

browncoatFaction = FactionInfo():setName("Browncoats")
browncoatFaction:setGMColor(255, 255, 255)
browncoatFaction:setDescription([[The confederacy of planets and moons that formed the Independent Faction was doomed from the start.
Each of the outer worlds had its own form of government.
They'd never really worked together except to do one thing - deliver the mail.
Out on the frontier, folk liked to keep to themselves, dealing with their own trouble in their own way.
On the Border planets, it could be dangerous to stick a gun barrel in someone's face because often as not 3 more could be pointing back at you.]])

allianceFaction = FactionInfo():setName("Alliance Navy")
allianceFaction:setGMColor(0, 128, 255)
-- allianceFaction:setEnemy(human)
allianceFaction:setDescription([[The strength of the Alliance military ensures that the Alliance remains in control.
Alliance ships have the registry prefix I.A.V. (Interstellar Alliance Vessel).
Though currently stretched quite thin, the military is still impressive.
Massive cruisers - the size of small cities - patrol space, keeping a watch for smugglers, illegal salvage operations, and pirates.
No one in the system is willing to take on an Alliance cruiser, which has enough firepower to atomize most other spacecraft.]])

reaverFaction = FactionInfo():setName("Reavers")
reaverFaction:setGMColor(255, 0, 0)
reaverFaction:setDescription([[To the people of the Core Worlds, Reavers are a campfire tale and bedtime story; to the people of the Border Worlds and Colonies, Reavers are very real.
Reavers are believed by most of the 'verse to be men that went insane at the edge of space and became savage.
They stared into the void beyond and became what they saw: nothing.
They gave into their primal nature and all that was civilized was discarded.]])
reaverFaction:setEnemy(independentFaction)
reaverFaction:setEnemy(browncoatFaction)
reaverFaction:setEnemy(allianceFaction)
