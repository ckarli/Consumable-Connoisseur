local _, ns = ...
local L = {}
ns.L = L

-- Default English (enUS)
L["BRAND"] = "Connoisseur"
L["MACRO_FOOD"] = "- Food"
L["MACRO_WATER"] = "- Water"
L["MACRO_HPOT"] = "- Health Potion"
L["MACRO_MPOT"] = "- Mana Potion"
L["MACRO_HS"] = "- Healthstone"
L["MACRO_BANDAGE"] = "- Bandage"
L["MSG_NO_ITEM"] = "No suitable %s found in your bags."
L["ERR_ZONE"] = "You can't use that here."
L["RANK"] = "Rank"

-- Bug Report Format
L["MSG_BUG_REPORT"] = "Looks like you found a bug! %s (%s) can't be used in %s > %s (%s). Please report this so we can get it fixed. Thanks! https://discord.gg/eh8hKq992Q"

-- Minimap Menu
L["MENU_TITLE"] = "Consumables"
L["MENU_SCAN"] = "Force Scan"
L["MENU_IGNORE"] = "Ignore"
L["MENU_RESET"] = "Reset"
L["MENU_CLEAR_IGNORE"] = "Clear Ignore List"

L["MENU_BUFF_FOOD"] = "Prioritize Buff Food"
L["MENU_BUFF_FOOD_DESC"] = "Prioritizes food that grants the \"Well Fed\" buff, when the buff is missing."

-- Minimap Class Tips
L["PREFIX_MAGE"] = "Attention Mages"
L["PREFIX_WARLOCK"] = "Attention Warlocks"

-- Mages
L["TIP_MAGE_CONJURE"] = "Right-Click on your Food or Water macros to Create Food or Water."
L["TIP_MAGE_TABLE"] = "Middle-click to cast Ritual of Refreshment."

-- Warlocks
L["TIP_WARLOCK_CONJURE"] = "Right-Click on your Healthstone macro to create a Healthstone."
L["TIP_WARLOCK_SOUL"] = "Middle-click to cast Ritual of Souls."

-- General
L["TIP_DOWNRANK"] = "Targeting a lower-level player will cause the macro to conjure items appropriate for their level."

-- UI Elements
L["UI_ENABLED"] = "Enabled"
L["UI_DISABLED"] = "Disabled"
L["UI_TOGGLE"] = "Toggle"
L["UI_BEST_FOOD"] = "Current Best Food"
L["UI_LEFT_CLICK"] = "Left-Click"
L["UI_RIGHT_CLICK"] = "Right-Click"
L["UI_MIDDLE_CLICK"] = "Middle-Click"
L["UI_IGNORE_LIST"] = "Ignore List"

-- Scanning Patterns
L["SCAN_ALCOHOL"] = "alcoholic beverage"
L["SCAN_HEALS"] = "heals (%d+)" 
L["SCAN_HEALTH"] = "health"
L["SCAN_MANA"] = "mana"
L["SCAN_HYBRID"] = "mana and health"
L["SCAN_RESTORES"] = "restores (%d+)"
L["SCAN_PERCENT"] = "restores (%d+)%%"
L["SCAN_HPOT_STRICT"] = "restores ([%d,]+) to ([%d,]+) health"
L["SCAN_MPOT_STRICT"] = "restores ([%d,]+) to ([%d,]+) mana"
L["SCAN_REQ_FA"] = "requires first aid %((%d+)%)"
L["SCAN_REQ_LEVEL"] = "requires level (%d+)"
L["SCAN_SEATED"] = "must remain seated"
L["SCAN_USE"] = "use:"
L["SCAN_WELL_FED"] = "well fed"
