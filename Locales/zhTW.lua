local _, ns = ...
local L = ns.L

-- [[ TRADITIONAL CHINESE (zhTW) ]] --
if GetLocale() == "zhTW" then
    L["MACRO_BANDAGE"] = "- 繃帶"
    L["MACRO_FOOD"] = "- 食物"
    L["MACRO_HPOT"] = "- 治療藥水"
    L["MACRO_HS"] = "- 治療石"
    L["MACRO_MPOT"] = "- 法力藥水"
    L["MACRO_MGEM"] = "- Mana Gem"
    L["MACRO_WATER"] = "- 水"

    L["ERR_ZONE"] = "你不能在這裡使用這個。"
    L["RANK"] = "等級"
    
    L["MSG_BUG_REPORT"] = "看來你發現了一個錯誤！ %s (%s) 無法在 %s > %s (%s) 使用。請回報此問題以便我們修正。謝謝！ https://discord.gg/eh8hKq992Q"
    L["MSG_NO_ITEM"] = "在你的背包中找不到合適的 %s。"

    L["MENU_BUFF_FOOD"] = "優先使用增益食物"
    L["MENU_BUFF_FOOD_DESC"] = "當缺少「進食充分」增益時，優先使用會給予該增益的食物。"
    L["MENU_CLEAR_IGNORE"] = "清除忽略清單"
    L["MENU_IGNORE"] = "忽略"
    L["MENU_RESET"] = "重置"
    L["MENU_SCAN"] = "強制掃描"
    L["MENU_TITLE"] = "消耗品"

    L["PREFIX_MAGE"] = "法師注意"
    L["PREFIX_WARLOCK"] = "術士注意"

    L["TIP_DOWNRANK"] = "選取低等級玩家為目標時，巨集會製造適合該等級的物品。"
    L["TIP_MAGE_CONJURE"] = "右鍵點擊你的食物或水巨集以製造食物或水。"
    L["TIP_MAGE_GEM"] = "右鍵點擊你的法力寶石巨集以製造法力寶石。"
    L["TIP_MAGE_TABLE"] = "中鍵點擊以施放召喚餐桌。"
    L["TIP_WARLOCK_CONJURE"] = "右鍵點擊你的治療石巨集以製造治療石。"
    L["TIP_WARLOCK_SOUL"] = "中鍵點擊以施放靈魂儀式。"

    L["UI_BEST_FOOD"] = "當前最佳食物"
    L["UI_DISABLED"] = "已停用"
    L["UI_ENABLED"] = "已啟用"
    L["UI_IGNORE_LIST"] = "忽略清單"
    L["UI_LEFT_CLICK"] = "左鍵點擊"
    L["UI_MIDDLE_CLICK"] = "中鍵點擊"
    L["UI_RIGHT_CLICK"] = "右鍵點擊"
    L["UI_TOGGLE"] = "切換"
end