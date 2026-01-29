local _, ns = ...
local L = ns.L

-- [[ RUSSIAN (ruRU) ]] --
if GetLocale() == "ruRU" then
    L["MACRO_BANDAGE"] = "- Бинты"
    L["MACRO_FOOD"] = "- Еда"
    L["MACRO_HPOT"] = "- Леч. зелье"
    L["MACRO_HS"] = "- Кам. здоровья"
    L["MACRO_MPOT"] = "- Зелье маны"
    L["MACRO_MGEM"] = "- Mana Gem"
    L["MACRO_WATER"] = "- Вода"

    L["ERR_ZONE"] = "Вы не можете использовать это здесь."
    L["RANK"] = "Уровень"
    
    L["MSG_BUG_REPORT"] = "Похоже, вы нашли ошибку! %s (%s) нельзя использовать в %s > %s (%s). Пожалуйста, сообщите об этом, чтобы мы могли исправить. Спасибо! https://discord.gg/eh8hKq992Q"
    L["MSG_NO_ITEM"] = "Подходящий %s не найден в сумках."

    L["MENU_BUFF_FOOD"] = "Еда с баффами"
    L["MENU_BUFF_FOOD_DESC"] = "Приоритет еды, дающей эффект \"Сытость\", если он отсутствует."
    L["MENU_CLEAR_IGNORE"] = "Очистить игнор-лист"
    L["MENU_IGNORE"] = "Игнорировать"
    L["MENU_RESET"] = "Сброс"
    L["MENU_SCAN"] = "Сканировать"
    L["MENU_TITLE"] = "Расходники"

    L["PREFIX_MAGE"] = "Внимание Маги"
    L["PREFIX_WARLOCK"] = "Внимание Чернокнижники"

    L["TIP_DOWNRANK"] = "Выбор игрока низкого уровня создаст предметы, подходящие для его уровня."
    L["TIP_MAGE_CONJURE"] = "Правый клик по макросу Еды или Воды для сотворения."
    L["TIP_MAGE_GEM"] = "Правый клик по макросу Камня маны для сотворения."
    L["TIP_MAGE_TABLE"] = "Средний клик для сотворения Ритуала подкрепления."
    L["TIP_WARLOCK_CONJURE"] = "Правый клик по макросу Камня здоровья для сотворения."
    L["TIP_WARLOCK_SOUL"] = "Средний клик для сотворения Ритуала душ."

    L["UI_BEST_FOOD"] = "Лучшая еда"
    L["UI_DISABLED"] = "Отключено"
    L["UI_ENABLED"] = "Включено"
    L["UI_IGNORE_LIST"] = "Список игнорирования"
    L["UI_LEFT_CLICK"] = "ЛКМ"
    L["UI_MIDDLE_CLICK"] = "СКМ"
    L["UI_RIGHT_CLICK"] = "ПКМ"
    L["UI_TOGGLE"] = "Переключить"
end