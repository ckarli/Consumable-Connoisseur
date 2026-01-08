local _, ns = ...
local L = {}
ns.L = L

-- [[ DEFAULT ENGLISH (enUS) ]] --
local default_enUS = {
    ["BRAND"] = "Connoisseur",
    ["MACRO_FOOD"] = "- Food",
    ["MACRO_WATER"] = "- Water",
    ["MACRO_HPOT"] = "- Health Potion",
    ["MACRO_MPOT"] = "- Mana Potion",
    ["MACRO_HS"] = "- Healthstone",
    ["MACRO_BANDAGE"] = "- Bandage",
    ["MSG_NO_ITEM"] = "No suitable %s found in your bags.",
    ["ERR_ZONE"] = "You can't use that here.",
    ["RANK"] = "Rank",

    ["MSG_BUG_REPORT"] = "Looks like you found a bug! %s (%s) can't be used in %s > %s (%s). Please report this so we can get it fixed. Thanks! https://discord.gg/eh8hKq992Q",

    ["MENU_TITLE"] = "Consumables",
    ["MENU_SCAN"] = "Force Scan",
    ["MENU_IGNORE"] = "Ignore",
    ["MENU_RESET"] = "Reset",
    ["MENU_CLEAR_IGNORE"] = "Clear Ignore List",

    ["MENU_BUFF_FOOD"] = "Prioritize Buff Food",
    ["MENU_BUFF_FOOD_DESC"] = "Prioritizes food that grants the \"Well Fed\" buff, when the buff is missing.",

    ["PREFIX_MAGE"] = "Attention Mages",
    ["PREFIX_WARLOCK"] = "Attention Warlocks",

    ["TIP_MAGE_CONJURE"] = "Right-Click on your Food or Water macros to Create Food or Water.",
    ["TIP_MAGE_TABLE"] = "Middle-click to cast Ritual of Refreshment.",

    ["TIP_WARLOCK_CONJURE"] = "Right-Click on your Healthstone macro to create a Healthstone.",
    ["TIP_WARLOCK_SOUL"] = "Middle-click to cast Ritual of Souls.",

    ["TIP_DOWNRANK"] = "Targeting a lower-level player will cause the macro to conjure items appropriate for their level.",

    ["UI_ENABLED"] = "Enabled",
    ["UI_DISABLED"] = "Disabled",
    ["UI_TOGGLE"] = "Toggle",
    ["UI_BEST_FOOD"] = "Current Best Food",
    ["UI_LEFT_CLICK"] = "Left-Click",
    ["UI_RIGHT_CLICK"] = "Right-Click",
    ["UI_MIDDLE_CLICK"] = "Middle-Click",
    ["UI_IGNORE_LIST"] = "Ignore List",

    ["SCAN_ALCOHOL"] = "alcoholic beverage",
    ["SCAN_HEALS"] = "heals (%d+)",
    ["SCAN_HEALTH"] = "health",
    ["SCAN_MANA"] = "mana",
    ["SCAN_HYBRID"] = "mana and health",
    ["SCAN_RESTORES"] = "restores (%d+)",
    ["SCAN_PERCENT"] = "restores (%d+)%%",
    ["SCAN_HPOT_STRICT"] = "restores ([%d,]+) to ([%d,]+) health",
    ["SCAN_MPOT_STRICT"] = "restores ([%d,]+) to ([%d,]+) mana",
    ["SCAN_REQ_FA"] = "requires first aid %((%d+)%)",
    ["SCAN_REQ_LEVEL"] = "requires level (%d+)",
    ["SCAN_SEATED"] = "must remain seated",
    ["SCAN_USE"] = "use:",
    ["SCAN_WELL_FED"] = "well fed"
}

-- Load Default
for k, v in pairs(default_enUS) do L[k] = v end

-- [[ GERMAN (deDE) ]] --
if GetLocale() == "deDE" then
    L["MACRO_FOOD"] = "- Food" -- Intentionally keeping macro names in English for now.
    L["MACRO_WATER"] = "- Water" -- Intentionally keeping macro names in English for now.
    L["MACRO_HPOT"] = "- Health Potion" -- Intentionally keeping macro names in English for now.
    L["MACRO_MPOT"] = "- Mana Potion" -- Intentionally keeping macro names in English for now.
    L["MACRO_HS"] = "- Healthstone" -- Intentionally keeping macro names in English for now.
    L["MACRO_BANDAGE"] = "- Bandage" -- Intentionally keeping macro names in English for now.
    L["MSG_NO_ITEM"] = "Kein geeignetes %s in deinen Taschen gefunden."
    L["ERR_ZONE"] = "Das kannst du hier nicht benutzen."
    L["RANK"] = "Rang"

    L["MSG_BUG_REPORT"] = "Du hast einen Bug gefunden! %s (%s) kann nicht in %s > %s (%s) benutzt werden. Bitte melde dies, damit wir es beheben können. Danke! https://discord.gg/eh8hKq992Q"

    L["MENU_TITLE"] = "Verbrauchsgüter"
    L["MENU_SCAN"] = "Scan erzwingen"
    L["MENU_IGNORE"] = "Ignorieren"
    L["MENU_RESET"] = "Zurücksetzen"
    L["MENU_CLEAR_IGNORE"] = "Ignorierliste löschen"

    L["MENU_BUFF_FOOD"] = "Buff-Essen bevorzugen"
    L["MENU_BUFF_FOOD_DESC"] = "Bevorzugt Essen, das den \"Satt\"-Buff gewährt, wenn der Buff fehlt."

    L["PREFIX_MAGE"] = "Achtung Magier"
    L["PREFIX_WARLOCK"] = "Achtung Hexenmeister"

    L["TIP_MAGE_CONJURE"] = "Rechtsklick auf dein Essen- oder Wasser-Makro, um Essen oder Wasser herbeizuzaubern."
    L["TIP_MAGE_TABLE"] = "Mittelklick, um Tischlein deck dich zu wirken."

    L["TIP_WARLOCK_CONJURE"] = "Rechtsklick auf dein Gesundheitsstein-Makro, um einen Gesundheitsstein herzustellen."
    L["TIP_WARLOCK_SOUL"] = "Mittelklick, um Ritual der Seelen zu wirken."

    L["TIP_DOWNRANK"] = "Wenn du einen Spieler mit niedrigerer Stufe anvisierst, wird das Makro Gegenstände herbeizaubern, die für dessen Stufe angemessen sind."

    L["UI_ENABLED"] = "Aktiviert"
    L["UI_DISABLED"] = "Deaktiviert"
    L["UI_TOGGLE"] = "Umschalten"
    L["UI_BEST_FOOD"] = "Aktuelles bestes Essen"
    L["UI_LEFT_CLICK"] = "Linksklick"
    L["UI_RIGHT_CLICK"] = "Rechtsklick"
    L["UI_MIDDLE_CLICK"] = "Mittelklick"
    L["UI_IGNORE_LIST"] = "Ignorierliste"

    -- Regex Scanning for German Tooltips
    L["SCAN_ALCOHOL"] = "alkoholisches getränk"
    -- Matches "Heilt X Sek. lang Y Punkt(e)". Skips the seconds (first digit) by anchoring to 'punkt'.
    L["SCAN_HEALS"] = "heilt.- (%d+) punkt" 
    L["SCAN_HEALTH"] = "gesundheit"
    L["SCAN_MANA"] = "mana"
    L["SCAN_HYBRID"] = "mana und gesundheit"
    -- Matches "Stellt ... 4410 Punkt(e)" or "Stellt ... 4410 Mana". [pmg] matches P(unkt), M(ana) or G(esundheit) to skip seconds (S).
    L["SCAN_RESTORES"] = "stellt.- (%d+) [pmg]" 
    L["SCAN_PERCENT"] = "stellt.- (%d+)%%"
    -- Strict matching for potions. Note: dot matches (e) in Punkt(e)
    L["SCAN_HPOT_STRICT"] = "stellt (%d+) bis (%d+) punkt.- gesundheit"
    L["SCAN_MPOT_STRICT"] = "stellt (%d+) bis (%d+) punkt.- mana"
    L["SCAN_REQ_FA"] = "benötigt erste hilfe %((%d+)%)"
    L["SCAN_REQ_LEVEL"] = "benötigt stufe (%d+)"
    L["SCAN_SEATED"] = "sitzen bleiben"
    L["SCAN_USE"] = "benutzen:"
    L["SCAN_WELL_FED"] = "satt"
end
