local _, ns = ...

ns.Colors = {
    TITLE = "|cffFFD100",
    INFO = "|cff00BBFF",
    DESC = "|cffCCCCCC",
    TEXT = "|cffFFFFFF",
    SUCCESS = "|cff33CC33",
    DISABLED = "|cffCC3333",
    MUTED = "|cff808080"
}

ns.Config = {
    ["Food"] = {macro = ns.L["MACRO_FOOD"], defaultID = 5349},
    ["Water"] = {macro = ns.L["MACRO_WATER"], defaultID = 5350},
    ["Health Potion"] = {macro = ns.L["MACRO_HPOT"], defaultID = 118},
    ["Mana Potion"] = {macro = ns.L["MACRO_MPOT"], defaultID = 2455},
    ["Healthstone"] = {macro = ns.L["MACRO_HS"], defaultID = 5512},
    ["Bandage"] = {macro = ns.L["MACRO_BANDAGE"], defaultID = 1251}
}

-- Items usable only in specific zones (Battlegrounds, Raids)
ns.ItemZoneRestrictions = {
    [19307] = {1459}, -- Alterac Heavy Runecloth Bandage
    [20062] = {1461}, -- Arathi Basin Enriched Ration
    [20063] = {1461}, -- Arathi Basin Field Ration
    [20064] = {1461}, -- Arathi Basin Iron Ration
    [20065] = {1461}, -- Arathi Basin Mageweave Bandage
    [20066] = {1461}, -- Arathi Basin Runecloth Bandage
    [20067] = {1461}, -- Arathi Basin Silk Bandage
    [32783] = {1949, 330}, -- Blue Ogre Brew
    [32909] = {1949, 330}, -- Blue Ogre Brew Special
    [32902] = {1555, 266, 267, 268, 269, 270, 271, 334}, -- Bottled Nethergon Energy
    [32905] = {1555, 266, 267, 268, 269, 270, 271, 334}, -- Bottled Nethergon Vapor
    [32904] = {332, 1554, 263, 264, 262, 265}, -- Cenarion Healing Salve
    [32903] = {332, 1554, 263, 264, 262, 265}, -- Cenarion Mana Salve
    [20222] = {1461}, -- Defiler's Enriched Ration
    [20223] = {1461}, -- Defiler's Field Ration
    [20224] = {1461}, -- Defiler's Iron Ration
    [20232] = {1461}, -- Defiler's Mageweave Bandage
    [20234] = {1461}, -- Defiler's Runecloth Bandage
    [20235] = {1461}, -- Defiler's Silk Bandage
    [20225] = {1461}, -- Highlander's Enriched Ration
    [20226] = {1461}, -- Highlander's Field Ration
    [20227] = {1461}, -- Highlander's Iron Ration
    [20237] = {1461}, -- Highlander's Mageweave Bandage
    [20243] = {1461}, -- Highlander's Runecloth Bandage
    [20244] = {1461}, -- Highlander's Silk Bandage
    [17348] = {1459, 1460, 1461, 1956}, -- Major Healing Draught
    [17351] = {1459, 1460, 1461, 1956}, -- Major Mana Draught
    [32784] = {1949, 330}, -- Red Ogre Brew
    [32910] = {1949, 330}, -- Red Ogre Brew Special
    [17349] = {1459, 1460, 1461, 1956}, -- Superior Healing Draught
    [17352] = {1459, 1460, 1461, 1956}, -- Superior Mana Draught
    [19060] = {1460}, -- Warsong Gulch Enriched Ration
    [19062] = {1460}, -- Warsong Gulch Field Ration
    [19061] = {1460}, -- Warsong Gulch Iron Ration
    [19067] = {1460}, -- Warsong Gulch Mageweave Bandage
    [19066] = {1460}, -- Warsong Gulch Runecloth Bandage
    [19068] = {1460}, -- Warsong Gulch Silk Bandage
}

-- Additional "Well Fed" Buff IDs.
ns.WellFedBuffIDs = {
    [18125] = true, -- blessed-sunfruit
    [18141] = true, -- blessed-sunfruit-juice
    [18191] = true, -- increased-stamina
    [18192] = true, -- increased-agility
    [18193] = true, -- increased-spirit
    [18194] = true, -- mana-regeneration
    [18222] = true, -- health-regeneration
    [22730] = true, -- increased-intellect
    [23697] = true, -- alterac-spring-water
}

-- Items to always ignore.
ns.Excludes = {
    [11951] = true, -- Whipper Root Tuber (Not a Potion)
    [13813] = true, -- Blessed Sunfruit Juice (Buff Water)
    [19318] = true, -- Bottled Alterac Spring Water (Buff Water)
    [23329] = true, -- Enriched Lasher Root (Not a Potion)
    [33825] = true, -- Skullfish Soup (Buff Water)
    [5473] = true,  -- Scorpid Surprise
}

-- Mage and Warlock Conjure Spells.
ns.ConjureSpells = {
    MageTable = {
        {43987, 70}
    },
    MageWater = {
        {27090, 70, 9}, -- Rank 9 (Conjured Glacier Cascade)
        {37420, 65, 8}, -- Rank 8 (Conjured Purified Draenic Water)
        {10140, 55, 7}, -- Rank 7 (Conjured Crystal Water)
        {10139, 45, 6}, -- Rank 6 (Conjured Sparkling Water)
        {10138, 35, 5}, -- Rank 5 (Conjured Mineral Water)
        {6127, 25, 4}, -- Rank 4 (Conjured Spring Water)
        {5506, 15, 3}, -- Rank 3 (Conjured Fresh Water)
        {5505, 5, 2}, -- Rank 2 (Conjured Water)
        {5504, 1, 1} -- Rank 1 (Conjured Purified Water)
    },
    MageFood = {
        {33717, 65, 8}, -- Rank 8 (Magical Croissant)
        {28612, 55, 7}, -- Rank 7 (Conjured Cinnamon Roll)
        {10145, 45, 6}, -- Rank 6 (Conjured Sweet Roll)
        {10144, 35, 5}, -- Rank 5 (Conjured Sourdough)
        {6129, 25, 4}, -- Rank 4 (Conjured Pumpernickel)
        {990, 15, 3}, -- Rank 3 (Conjured Rye)
        {597, 5, 2}, -- Rank 2 (Conjured Bread)
        {587, 1, 1} -- Rank 1 (Conjured Muffin)
    },
    WarlockSoul = {
        {29893, 68}
    },
    WarlockHS = {
        {27230, 60, 6}, -- Rank 6 (Master Healthstone)
        {11730, 48, 5}, -- Rank 5 (Major Healthstone)
        {11729, 36, 4}, -- Rank 4 (Greater Healthstone)
        {5699, 24, 3}, -- Rank 3 (Healthstone)
        {6202, 12, 2}, -- Rank 2 (Lesser Healthstone)
        {6201, 1, 1} -- Rank 1 (Minor Healthstone)
    }
}
