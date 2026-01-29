local _, ns = ...
local L = ns.L

-- [[ KOREAN (koKR) ]] --
if GetLocale() == "koKR" then
    L["MACRO_BANDAGE"] = "- 붕대"
    L["MACRO_FOOD"] = "- 음식"
    L["MACRO_HPOT"] = "- 치유 물약"
    L["MACRO_HS"] = "- 생명석"
    L["MACRO_MPOT"] = "- 마나 물약"
    L["MACRO_MGEM"] = "- Mana Gem"
    L["MACRO_WATER"] = "- 물"

    L["ERR_ZONE"] = "여기선 사용할 수 없습니다."
    L["RANK"] = "레벨"
    
    L["MSG_BUG_REPORT"] = "버그를 발견한 것 같습니다! %s (%s) 아이템은 %s > %s (%s)에서 사용할 수 없습니다. 수정할 수 있도록 제보해 주세요. 감사합니다! https://discord.gg/eh8hKq992Q"
    L["MSG_NO_ITEM"] = "가방에 적합한 %s(이)가 없습니다."

    L["MENU_BUFF_FOOD"] = "버프 음식 우선"
    L["MENU_BUFF_FOOD_DESC"] = "\"포만감\" 버프가 없을 때 해당 버프를 주는 음식을 우선 사용합니다."
    L["MENU_CLEAR_IGNORE"] = "차단 목록 초기화"
    L["MENU_IGNORE"] = "차단"
    L["MENU_RESET"] = "초기화"
    L["MENU_SCAN"] = "강제 스캔"
    L["MENU_TITLE"] = "소모품"

    L["PREFIX_MAGE"] = "마법사 주의"
    L["PREFIX_WARLOCK"] = "흑마법사 주의"

    L["TIP_DOWNRANK"] = "자신보다 레벨이 낮은 플레이어를 대상으로 하면 해당 레벨에 맞는 아이템을 창조합니다."
    L["TIP_MAGE_CONJURE"] = "음식 또는 물 매크로를 우클릭하면 음식 또는 물을 창조합니다."
    L["TIP_MAGE_GEM"] = "마나 보석 매크로를 우클릭하면 마나 보석을 창조합니다."
    L["TIP_MAGE_TABLE"] = "마우스 휠(가운데) 클릭 시 식탁을 깝니다."
    L["TIP_WARLOCK_CONJURE"] = "생명석 매크로를 우클릭하면 생명석을 창조합니다."
    L["TIP_WARLOCK_SOUL"] = "마우스 휠(가운데) 클릭 시 영혼의 의식을 시전합니다."

    L["UI_BEST_FOOD"] = "현재 최고 음식"
    L["UI_DISABLED"] = "비활성화됨"
    L["UI_ENABLED"] = "활성화됨"
    L["UI_IGNORE_LIST"] = "차단 목록"
    L["UI_LEFT_CLICK"] = "좌클릭"
    L["UI_MIDDLE_CLICK"] = "휠클릭"
    L["UI_RIGHT_CLICK"] = "우클릭"
    L["UI_TOGGLE"] = "토글"
end