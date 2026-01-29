local _, ns = ...
local L = ns.L

-- [[ SIMPLIFIED CHINESE (zhCN) ]] --
if GetLocale() == "zhCN" then
    L["MACRO_BANDAGE"] = "- 绷带"
    L["MACRO_FOOD"] = "- 食物"
    L["MACRO_HPOT"] = "- 治疗药水"
    L["MACRO_HS"] = "- 治疗石"
    L["MACRO_MPOT"] = "- 法力药水"
    L["MACRO_MGEM"] = "- Mana Gem"
    L["MACRO_WATER"] = "- 水"

    L["ERR_ZONE"] = "你不能在这里使用该物品。"
    L["RANK"] = "等级"
    
    L["MSG_BUG_REPORT"] = "看来你发现了一个BUG！%s (%s) 无法在 %s > %s (%s) 使用。请报告给我们以便修复。谢谢！ https://discord.gg/eh8hKq992Q"
    L["MSG_NO_ITEM"] = "背包中未找到合适的 %s。"

    L["MENU_BUFF_FOOD"] = "优先增益食物"
    L["MENU_BUFF_FOOD_DESC"] = "当缺少“进食充分”BUFF时，优先使用提供该BUFF的食物。"
    L["MENU_CLEAR_IGNORE"] = "清除忽略列表"
    L["MENU_IGNORE"] = "忽略"
    L["MENU_RESET"] = "重置"
    L["MENU_SCAN"] = "强制扫描"
    L["MENU_TITLE"] = "消耗品"

    L["PREFIX_MAGE"] = "法师请注意"
    L["PREFIX_WARLOCK"] = "术士请注意"

    L["TIP_DOWNRANK"] = "选中低等级玩家时，宏将制造适合其等级的物品。"
    L["TIP_MAGE_CONJURE"] = "右键点击食物或水宏以制造食物或水。"
    L["TIP_MAGE_GEM"] = "右键点击你的法力宝石宏来制造法力宝石。"
    L["TIP_MAGE_TABLE"] = "中键点击以施放召唤餐桌。"
    L["TIP_WARLOCK_CONJURE"] = "右键点击治疗石宏以制造治疗石。"
    L["TIP_WARLOCK_SOUL"] = "中键点击以施放灵魂仪式。"

    L["UI_BEST_FOOD"] = "当前最佳食物"
    L["UI_DISABLED"] = "已禁用"
    L["UI_ENABLED"] = "已启用"
    L["UI_IGNORE_LIST"] = "忽略列表"
    L["UI_LEFT_CLICK"] = "左键点击"
    L["UI_MIDDLE_CLICK"] = "中键点击"
    L["UI_RIGHT_CLICK"] = "右键点击"
    L["UI_TOGGLE"] = "切换"
end