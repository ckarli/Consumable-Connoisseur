local _, ns = ...

ns.Colors = {
    TITLE    = "|cffFFD100",
    INFO     = "|cff00BBFF",
    DESC     = "|cffCCCCCC",
    TEXT     = "|cffFFFFFF",
    SUCCESS  = "|cff33CC33",
    DISABLED = "|cffCC3333",
    SEP      = "|cffAAAAAA",
    MUTED    = "|cff808080",
    BLUE     = "|cff00BBFF",
    GRAY     = "|cffAAAAAA",
    WHITE    = "|cffFFFFFF"
}

ns.Config = {
    ["Food"]          = { macro = ns.L["MACRO_FOOD"],    defaultID = 5349 },
    ["Water"]         = { macro = ns.L["MACRO_WATER"],   defaultID = 5350 },
    ["Health Potion"] = { macro = ns.L["MACRO_HPOT"],    defaultID = 118 },
    ["Mana Potion"]   = { macro = ns.L["MACRO_MPOT"],    defaultID = 2455 },
    ["Healthstone"]   = { macro = ns.L["MACRO_HS"],      defaultID = 5512 },
    ["Bandage"]       = { macro = ns.L["MACRO_BANDAGE"], defaultID = 1251 }
}

ns.ItemZoneRestrictions = {
    [32902] = {1555, 266, 267, 268, 269, 270, 271, 334}, -- Bottled Nethergon Energy
    [32905] = {1555, 266, 267, 268, 269, 270, 271, 334}, -- Bottled Nethergon Vapor
    [17349] = {1459, 1460, 1461, 1956}, -- Superior Healing Draught
    [17352] = {1459, 1460, 1461, 1956}, -- Superior Mana Draught
    [17348] = {1459, 1460, 1461, 1956}, -- Major Healing Draught
    [17351] = {1459, 1460, 1461, 1956}, -- Major Mana Draught
    [19062] = {1460}, -- Warsong Gulch Field Ration
    [19061] = {1460}, -- Warsong Gulch Iron Ration
    [19060] = {1460}, -- Warsong Gulch Enriched Ration
    [20232] = {1461}, -- Defiler's Mageweave Bandage
    [20066] = {1461}, -- Arathi Basin Runecloth Bandage
    [20234] = {1461}, -- Defiler's Runecloth Bandage
    [20067] = {1461}, -- Arathi Basin Silk Bandage
    [32904] = {332, 1554, 263, 264, 262, 265}, -- Cenarion Healing Salve
    [32903] = {332, 1554, 263, 264, 262, 265}, -- Cenarion Mana Salve
    [32784] = {1949, 330}, -- Red Ogre Brew
    [32910] = {1949, 330}, -- Red Ogre Brew Special
    [32783] = {1949, 330}, -- Blue Ogre Brew
    [32909] = {1949, 330}, -- Blue Ogre Brew Special
}

ns.Excludes = {}
