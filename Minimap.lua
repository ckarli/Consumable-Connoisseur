local addonName, ns = ...
local C = ns.Colors
local L = ns.L

local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub("LibDBIcon-1.0", true)

local UpdateTooltip

function ns.UpdateLDB()
    if not ns.LDBObj then
        return
    end

    local iconID = ns.BestFoodID or ns.Config["Food"].defaultID

    local newIcon = C_Item.GetItemIconByID(iconID) or "Interface\\Icons\\INV_Misc_Food_02"

    ns.LDBObj.icon = newIcon

    if LDBIcon then
        local button = LDBIcon:GetMinimapButton("Connoisseur")
        if button then
            if button.icon then
                button.icon:SetTexture(newIcon)
            end

            if GameTooltip:GetOwner() == button then
                UpdateTooltip(button)
            end
        end
    end
end

local function KnowsAny(spellList)
    if not spellList then
        return false
    end
    for _, data in ipairs(spellList) do
        if IsSpellKnown(data[1]) then
            return true
        end
    end
    return false
end

UpdateTooltip = function(anchor)
    if not CC_Settings then
        return
    end
    local tooltip = GameTooltip

    tooltip:SetOwner(anchor, "ANCHOR_BOTTOMLEFT")
    tooltip:ClearLines()

    local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or ""
    tooltip:AddDoubleLine(C.TITLE .. L["BRAND"] .. "|r", C.MUTED .. version .. "|r")
    tooltip:AddLine(" ")

    local _, class = UnitClass("player")
    local descColor = C.DESC

    if class == "MAGE" and ns.ConjureSpells then
        local cColor = "|cff3FC7EB"
        local knowsTable = ns.ConjureSpells.MageTable and KnowsAny(ns.ConjureSpells.MageTable)
        local knowsFood = ns.ConjureSpells.MageFood and KnowsAny(ns.ConjureSpells.MageFood)
        local knowsWater = ns.ConjureSpells.MageWater and KnowsAny(ns.ConjureSpells.MageWater)
        local knowsGem = ns.ConjureSpells.MageGem and KnowsAny(ns.ConjureSpells.MageGem)

        if knowsFood or knowsWater or knowsTable or knowsGem then
            tooltip:AddLine(" ")
            tooltip:AddLine(cColor .. L["PREFIX_MAGE"] .. "|r")
            if knowsFood or knowsWater then
                tooltip:AddLine(descColor .. L["TIP_MAGE_CONJURE"] .. "|r", 1, 1, 1, true)
            end
            if knowsGem then
                tooltip:AddLine(descColor .. L["TIP_MAGE_GEM"] .. "|r", 1, 1, 1, true)
            end
            if knowsTable then
                tooltip:AddLine(" ")
                tooltip:AddLine(descColor .. L["TIP_MAGE_TABLE"] .. "|r", 1, 1, 1, true)
            end
            tooltip:AddLine(" ")
            tooltip:AddLine(descColor .. L["TIP_DOWNRANK"] .. "|r", 1, 1, 1, true)
        end
    elseif class == "WARLOCK" and ns.ConjureSpells then
        local cColor = "|cff8787ED"
        local knowsSoul = ns.ConjureSpells.WarlockSoul and KnowsAny(ns.ConjureSpells.WarlockSoul)
        local knowsHS = ns.ConjureSpells.WarlockHS and KnowsAny(ns.ConjureSpells.WarlockHS)

        if knowsHS or knowsSoul then
            tooltip:AddLine(" ")
            tooltip:AddLine(cColor .. L["PREFIX_WARLOCK"] .. "|r")
            if knowsHS then
                tooltip:AddLine(descColor .. L["TIP_WARLOCK_CONJURE"] .. "|r", 1, 1, 1, true)
            end
            if knowsSoul then
                tooltip:AddLine(" ")
                tooltip:AddLine(descColor .. L["TIP_WARLOCK_SOUL"] .. "|r", 1, 1, 1, true)
            end
            tooltip:AddLine(" ")
            tooltip:AddLine(descColor .. L["TIP_DOWNRANK"] .. "|r", 1, 1, 1, true)
        end
    end

    tooltip:AddLine(" ")
    local buffState =
        CC_Settings.UseBuffFood and (C.SUCCESS .. L["UI_ENABLED"] .. "|r") or (C.DISABLED .. L["UI_DISABLED"] .. "|r")
    tooltip:AddDoubleLine(C.TITLE .. L["MENU_BUFF_FOOD"] .. "|r", buffState)
    tooltip:AddLine(C.DESC .. L["MENU_BUFF_FOOD_DESC"] .. "|r", 1, 1, 1, true)
    tooltip:AddDoubleLine(C.INFO .. L["UI_LEFT_CLICK"] .. "|r", C.INFO .. L["UI_TOGGLE"] .. "|r")

    if ns.BestFoodID and ns.BestFoodLink then
        tooltip:AddLine(" ")
        tooltip:AddLine(C.TITLE .. L["UI_BEST_FOOD"] .. "|r")

        local icon = C_Item.GetItemIconByID(ns.BestFoodID)
        tooltip:AddLine(format("|T%s:14:14|t %s", icon, ns.BestFoodLink))

        tooltip:AddDoubleLine(C.INFO .. L["UI_RIGHT_CLICK"] .. "|r", C.INFO .. L["MENU_IGNORE"] .. "|r")
    end

    local hasIgnored = next(CC_IgnoreList) ~= nil
    if hasIgnored then
        tooltip:AddLine(" ")
        tooltip:AddLine(C.TITLE .. L["UI_IGNORE_LIST"] .. "|r")

        local sortedList = {}
        for itemID in pairs(CC_IgnoreList) do
            local name, _, quality, _, _, _, _, _, _, tex = GetItemInfo(itemID)
            if name then
                tinsert(sortedList, {id = itemID, name = name, quality = quality, tex = tex})
            else
                tinsert(sortedList, {id = itemID, name = "ZZZ_Unknown", quality = 0, tex = nil})
            end
        end

        table.sort(
            sortedList,
            function(a, b)
                return a.name < b.name
            end
        )

        for _, item in ipairs(sortedList) do
            if item.tex then
                local _, _, _, hex = GetItemQualityColor(item.quality)
                tooltip:AddLine(format("|T%s:14:14|t |c%s[%s]|r", item.tex, hex, item.name))
            else
                tooltip:AddLine(C.MUTED .. "ID: " .. item.id .. "|r")
            end
        end

        tooltip:AddDoubleLine(C.INFO .. L["UI_MIDDLE_CLICK"] .. "|r", C.INFO .. L["MENU_CLEAR_IGNORE"] .. "|r")
    end

    tooltip:Show()
end

if LDB then
    ns.LDBObj =
        LDB:NewDataObject(
        "Connoisseur",
        {
            type = "data source",
            text = L["BRAND"],
            icon = "Interface\\Icons\\INV_Misc_Food_02",
            OnClick = function(self, button)
                if button == "RightButton" and ns.BestFoodID then
                    CC_IgnoreList[ns.BestFoodID] = true
                    if ns.UpdateMacros then
                        ns.UpdateMacros(true)
                    end
                elseif button == "LeftButton" then
                    if ns.ToggleBuffFood then
                        ns.ToggleBuffFood()
                    else
                        CC_Settings.UseBuffFood = not CC_Settings.UseBuffFood
                        if ns.UpdateMacros then
                            ns.UpdateMacros(true)
                        end
                    end
                elseif button == "MiddleButton" then
                    wipe(CC_IgnoreList)
                    if ns.UpdateMacros then
                        ns.UpdateMacros(true)
                    end
                end

                ns.UpdateLDB()
            end,
            OnEnter = function(self)
                UpdateTooltip(self)
            end,
            OnLeave = function()
                GameTooltip:Hide()
            end
        }
    )
end