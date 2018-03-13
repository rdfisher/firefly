neutral = FactionInfo():setName("Independent")
neutral:setGMColor(128, 128, 128)
neutral:setDescription([[Despite appearing as a faction, independents are distinguished primarily by having no strong affiliation with any faction at all. Most traders consider themselves independent, though certain voices have started to speak up about creating a merchant faction.]])

human = FactionInfo():setName("Browncoats")
human:setGMColor(255, 255, 255)
human:setDescription([[Browncoats Description]])

kraylor = FactionInfo():setName("Allience")
kraylor:setGMColor(0, 128, 255)
kraylor:setEnemy(human)
kraylor:setDescription([[Allience Description]])

Hive = FactionInfo():setName("Reevers")
Hive:setGMColor(255, 0, 0)
Hive:setDescription([[Reevers Description]])
Hive:setEnemy(human)
Hive:setEnemy(neutral)
Hive:setEnemy(kraylor)
