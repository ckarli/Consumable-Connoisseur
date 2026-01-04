local addonName, ns = ...
local C = ns.Colors
local L = ns.L
local LDB = LibStub and LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub and LibStub("LibDBIcon-1.0", true)

local function GetFallbackIcon()
    return (ns.Config["Food"] and GetItemIcon(ns.Config["Food"].defaultID)) or "Interface\\Icons\\INV_Misc_Food_02"
end

-- Helper to check if player knows any spell in a list
local function KnowsAny(spellList)
    if not spellList then return false end
    for _, data in ipairs(spellList) do
        -- data[1] is the Spell ID in the new array format
        if IsSpellKnown(data[1]) then return true end
    end
    return false
end

local function OnEnter(anchor)
    if not CC_Settings then return end
    local tooltip = GameTooltip
    tooltip:SetOwner(anchor, "ANCHOR_BOTTOMLEFT")
    tooltip:ClearLines()

    local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or ""
    
    tooltip:AddDoubleLine(C.TITLE..L["BRAND"].."|r", C.MUTED..version.."|r")
    tooltip:AddLine(" ")    

    -- CLASS SPECIFIC TIPS
    local _, class = UnitClass("player")
    local descColor = C.DESC
    
    if class == "MAGE" and ns.ConjureSpells then
        local cColor = "|cff3FC7EB" -- Mage Blue
        local knowsTable = KnowsAny(ns.ConjureSpells.MageTable)
        local knowsFood  = KnowsAny(ns.ConjureSpells.MageFood)
        local knowsWater = KnowsAny(ns.ConjureSpells.MageWater)
        
        if knowsFood or knowsWater or knowsTable then
            tooltip:AddLine(" ")
            tooltip:AddLine(cColor .. L["PREFIX_MAGE"] .. "|r")
            
            -- Line 1: Right Click (Conjure)
            if knowsFood or knowsWater then
                tooltip:AddLine(descColor .. L["TIP_MAGE_CONJURE"] .. "|r", 1, 1, 1, true)
            end

            -- Line 2: Middle Click (Table) - Only if learned
            if knowsTable then
                tooltip:AddLine(" ") -- Spacing
                tooltip:AddLine(descColor .. L["TIP_MAGE_TABLE"] .. "|r", 1, 1, 1, true)
            end
            
            -- Footer: Downranking
            tooltip:AddLine(" ")
            tooltip:AddLine(descColor .. L["TIP_DOWNRANK"] .. "|r", 1, 1, 1, true)
        end

    elseif class == "WARLOCK" and ns.ConjureSpells then
        local cColor = "|cff8787ED" -- Warlock Purple
        local knowsSoul = KnowsAny(ns.ConjureSpells.WarlockSoul)
        local knowsHS   = KnowsAny(ns.ConjureSpells.WarlockHS)

        if knowsHS or knowsSoul then
            tooltip:AddLine(" ")
            tooltip:AddLine(cColor .. L["PREFIX_WARLOCK"] .. "|r")
            
            -- Line 1: Right Click (Healthstone)
            if knowsHS then
                tooltip:AddLine(descColor .. L["TIP_WARLOCK_CONJURE"] .. "|r", 1, 1, 1, true)
            end
            
            -- Line 2: Middle Click (Soulwell) - Only if learned
            if knowsSoul then
                tooltip:AddLine(" ") -- Spacing
                tooltip:AddLine(descColor .. L["TIP_WARLOCK_SOUL"] .. "|r", 1, 1, 1, true)
            end
            
            -- Footer: Downranking
            tooltip:AddLine(" ")
            tooltip:AddLine(descColor .. L["TIP_DOWNRANK"] .. "|r", 1, 1, 1, true)
        end
    end

    tooltip:AddLine(" ")
    local buffState = CC_Settings.UseBuffFood and (C.SUCCESS..L["UI_ENABLED"].."|r") or (C.DISABLED..L["UI_DISABLED"].."|r")
    tooltip:AddDoubleLine(C.TITLE..L["MENU_BUFF_FOOD"].."|r", buffState)
    tooltip:AddLine(C.DESC..L["MENU_BUFF_FOOD_DESC"].."|r", 1, 1, 1, true)
    tooltip:AddDoubleLine(C.INFO..L["UI_RIGHT_CLICK"].."|r", C.INFO..L["UI_TOGGLE"].."|r")
    tooltip:AddLine(" ")    
    if ns.BestFoodID and ns.BestFoodLink then
        tooltip:AddDoubleLine(C.TITLE..L["UI_BEST_FOOD"].."|r", ns.BestFoodLink.." |T"..GetItemIcon(ns.BestFoodID)..":14:14|t")
        tooltip:AddDoubleLine(C.INFO..L["UI_LEFT_CLICK"].."|r", C.INFO..L["MENU_IGNORE"].."|r")
    end

    local hasIgnored = next(CC_IgnoreList) ~= nil
    if hasIgnored then
        tooltip:AddLine(C.TITLE..L["UI_IGNORE_LIST"].."|r")
        for itemID in pairs(CC_IgnoreList) do
            local name, _, quality, _, _, _, _, _, _, tex = GetItemInfo(itemID)
            if name then
                local _, _, _, hex = GetItemQualityColor(quality)
                tooltip:AddDoubleLine(" ", format("|c%s[%s]|r |T%s:14:14|t", hex, name, tex))
            else
                tooltip:AddDoubleLine(" ", C.MUTED.."ID: "..itemID.."|r")
            end
        end
        tooltip:AddDoubleLine(C.INFO..L["UI_MIDDLE_CLICK"].."|r", C.INFO..L["MENU_CLEAR_IGNORE"].."|r")
    end

    tooltip:Show()
end

if LDB then
    ns.LDBObj = LDB:NewDataObject(addonName, {
        type = "data source", text = L["BRAND"], icon = GetFallbackIcon(),
        OnClick = function(_, button)
            if button == "LeftButton" and ns.BestFoodID then
                CC_IgnoreList[ns.BestFoodID] = true
                ns.UpdateMacros(true)
            elseif button == "RightButton" then
                if ns.ToggleBuffFood then
                    ns.ToggleBuffFood()
                else
                    CC_Settings.UseBuffFood = not CC_Settings.UseBuffFood
                    ns.UpdateMacros(true)
                end
            elseif button == "MiddleButton" then
                wipe(CC_IgnoreList)
                ns.UpdateMacros(true)
            end
            if LDBIcon then 
                local btn = LDBIcon:GetMinimapButton(addonName)
                if btn and GameTooltip:GetOwner() == btn then OnEnter(btn) end
            end
        end,
        OnEnter = function(self) OnEnter(self) end,
        OnLeave = function() GameTooltip:Hide() end
    })
end
