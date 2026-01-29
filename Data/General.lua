local _, ns = ...

-- Brand Colors
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
    ["Mana Gem"] = {macro = ns.L["MACRO_MGEM"], defaultID = 5514},
    ["Healthstone"] = {macro = ns.L["MACRO_HS"], defaultID = 5512},
    ["Bandage"] = {macro = ns.L["MACRO_BANDAGE"], defaultID = 1251}
}

-- Additional "Well Fed" Buff IDs
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

-- Mage and Warlock Spells
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
    MageGem = {
        {27101, 70, 5, 22044}, -- Rank 5 (Mana Emerald)
        {10054, 58, 4, 8008}, -- Rank 4 (Mana Ruby)
        {10053, 48, 3, 8007}, -- Rank 3 (Mana Citrine)
        {3552, 38, 2, 5513}, -- Rank 2 (Mana Jade)
        {759, 28, 1, 5514} -- Rank 1 (Mana Agate)
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