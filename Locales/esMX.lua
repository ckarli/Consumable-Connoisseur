local _, ns = ...
local L = ns.L

-- [[ SPANISH (esMX) ]] --
if GetLocale() == "esMX" then
    L["MACRO_BANDAGE"] = "- Venda"
    L["MACRO_FOOD"] = "- Comida"
    L["MACRO_HPOT"] = "- Poc. Salud"
    L["MACRO_HS"] = "- Piedra"
    L["MACRO_MPOT"] = "- Poc. Maná"
    L["MACRO_MGEM"] = "- Mana Gem"
    L["MACRO_WATER"] = "- Agua"

    L["ERR_ZONE"] = "No puedes usar eso aquí."
    L["RANK"] = "Rango"
    
    L["MSG_BUG_REPORT"] = "¡Parece que encontraste un error! %s (%s) no se puede usar en %s > %s (%s). Por favor repórtalo para que podamos arreglarlo. ¡Gracias! https://discord.gg/eh8hKq992Q"
    L["MSG_NO_ITEM"] = "No se encontró ningún %s adecuado en tus bolsas."

    L["MENU_BUFF_FOOD"] = "Priorizar comida con beneficios"
    L["MENU_BUFF_FOOD_DESC"] = "Prioriza la comida que otorga el beneficio \"Bien alimentado\" cuando te falta."
    L["MENU_CLEAR_IGNORE"] = "Borrar lista de ignorados"
    L["MENU_IGNORE"] = "Ignorar"
    L["MENU_RESET"] = "Reiniciar"
    L["MENU_SCAN"] = "Forzar escaneo"
    L["MENU_TITLE"] = "Consumibles"

    L["PREFIX_MAGE"] = "Atención Magos"
    L["PREFIX_WARLOCK"] = "Atención Brujos"

    L["TIP_DOWNRANK"] = "Seleccionar a un jugador de menor nivel hará que la macro conjure objetos apropiados para su nivel."
    L["TIP_MAGE_CONJURE"] = "Clic derecho en tus macros de Comida o Agua para crear Comida o Agua."
    L["TIP_MAGE_GEM"] = "Clic derecho en tu macro de Gema de maná para crear una Gema de maná."
    L["TIP_MAGE_TABLE"] = "Clic central para lanzar Ritual de refrigerio."
    L["TIP_WARLOCK_CONJURE"] = "Clic derecho en tu macro de Piedra de salud para crear una Piedra de salud."
    L["TIP_WARLOCK_SOUL"] = "Clic central para lanzar Ritual de almas."

    L["UI_BEST_FOOD"] = "Mejor comida actual"
    L["UI_DISABLED"] = "Desactivado"
    L["UI_ENABLED"] = "Activado"
    L["UI_IGNORE_LIST"] = "Lista de ignorados"
    L["UI_LEFT_CLICK"] = "Clic izquierdo"
    L["UI_MIDDLE_CLICK"] = "Clic central"
    L["UI_RIGHT_CLICK"] = "Clic derecho"
    L["UI_TOGGLE"] = "Alternar"
end