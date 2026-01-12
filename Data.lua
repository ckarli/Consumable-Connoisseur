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
    [20066] = {1461}, -- Arathi Basin Runecloth Bandage
    [20067] = {1461}, -- Arathi Basin Silk Bandage
    [32783] = {1949, 330}, -- Blue Ogre Brew
    [32909] = {1949, 330}, -- Blue Ogre Brew Special
    [32902] = {1555, 266, 267, 268, 269, 270, 271, 334}, -- Bottled Nethergon Energy
    [32905] = {1555, 266, 267, 268, 269, 270, 271, 334}, -- Bottled Nethergon Vapor
    [32904] = {332, 1554, 263, 264, 262, 265}, -- Cenarion Healing Salve
    [32903] = {332, 1554, 263, 264, 262, 265}, -- Cenarion Mana Salve
    [20232] = {1461}, -- Defiler's Mageweave Bandage
    [20234] = {1461}, -- Defiler's Runecloth Bandage
    [17348] = {1459, 1460, 1461, 1956}, -- Major Healing Draught
    [17351] = {1459, 1460, 1461, 1956}, -- Major Mana Draught
    [32784] = {1949, 330}, -- Red Ogre Brew
    [32910] = {1949, 330}, -- Red Ogre Brew Special
    [17349] = {1459, 1460, 1461, 1956}, -- Superior Healing Draught
    [17352] = {1459, 1460, 1461, 1956}, -- Superior Mana Draught
    [19060] = {1460}, -- Warsong Gulch Enriched Ration
    [19062] = {1460}, -- Warsong Gulch Field Ration
    [19061] = {1460}, -- Warsong Gulch Iron Ration
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
        {27090, 70, 9}, -- Rank 9
        {37420, 65, 8}, -- Rank 8
        {10140, 55, 7}, -- Rank 7
        {10139, 45, 6}, -- Rank 6
        {10138, 35, 5}, -- Rank 5
        {6127, 25, 4}, -- Rank 4
        {5506, 15, 3}, -- Rank 3
        {5505, 5, 2}, -- Rank 2
        {5504, 1, 1} -- Rank 1
    },
    MageFood = {
        {33717, 65, 8}, -- Rank 8
        {28612, 55, 7}, -- Rank 7
        {10145, 45, 6}, -- Rank 6
        {10144, 35, 5}, -- Rank 5
        {6129, 25, 4}, -- Rank 4
        {990, 15, 3}, -- Rank 3
        {597, 5, 2}, -- Rank 2
        {587, 1, 1} -- Rank 1
    },
    WarlockSoul = {
        {29893, 68}
    },
    WarlockHS = {
        {27230, 60, 6}, -- Rank 6
        {11730, 48, 5}, -- Rank 5
        {11729, 36, 4}, -- Rank 4
        {5699, 24, 3}, -- Rank 3
        {6202, 12, 2}, -- Rank 2
        {6201, 1, 1} -- Rank 1
    }
}
