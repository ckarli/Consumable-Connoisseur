local addonName, ns = ...
local C = ns.Colors
local L = ns.L
local LDB = LibStub and LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub and LibStub("LibDBIcon-1.0", true)

local function GetFallbackIcon()
    return (ns.Config["Food"] and GetItemIcon(ns.Config["Food"].defaultID)) or "Interface\\Icons\\INV_Misc_Food_02"
end

local function OnEnter(anchor)
    if not CC_Settings then return end
    local tooltip = GameTooltip
    tooltip:SetOwner(anchor, "ANCHOR_BOTTOMLEFT")
    tooltip:ClearLines()

    local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or ""
    
    tooltip:AddDoubleLine(C.TITLE..L["BRAND"].."|r", C.MUTED..version.."|r")
    tooltip:AddLine(" ")
    tooltip:AddLine(" ")
    local buffState = CC_Settings.UseBuffFood and (C.SUCCESS..L["UI_ENABLED"].."|r") or (C.DISABLED..L["UI_DISABLED"].."|r")
    tooltip:AddDoubleLine(C.TITLE..L["MENU_BUFF_FOOD"].."|r", buffState)
    tooltip:AddLine(C.DESC..L["MENU_BUFF_FOOD_DESC"].."|r", 1, 1, 1, true)
    tooltip:AddDoubleLine(C.INFO..L["UI_RIGHT_CLICK"].."|r", C.INFO..L["UI_TOGGLE"].."|r")
    
    if ns.BestFoodID and ns.BestFoodLink then
        tooltip:AddLine(" ")
        tooltip:AddDoubleLine(C.TITLE..L["UI_BEST_FOOD"].."|r", "|T"..GetItemIcon(ns.BestFoodID)..":14:14|t "..ns.BestFoodLink)
        tooltip:AddDoubleLine(C.INFO..L["UI_LEFT_CLICK"].."|r", C.INFO..L["MENU_IGNORE"].."|r")
    end

    local hasIgnored = next(CC_IgnoreList) ~= nil
    if hasIgnored then
        tooltip:AddLine(" ")
        tooltip:AddLine(C.TITLE..L["UI_IGNORE_LIST"].."|r")
        for itemID in pairs(CC_IgnoreList) do
            local name, _, quality, _, _, _, _, _, _, tex = GetItemInfo(itemID)
            if name then
                local _, _, _, hex = GetItemQualityColor(quality)
                tooltip:AddLine(format("|T%s:14:14|t |c%s[%s]|r", tex, hex, name))
            else
                tooltip:AddLine(C.MUTED.."ID: "..itemID.."|r")
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

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    if not CC_Settings then CC_Settings = {} end
    if not CC_Settings.Minimap then CC_Settings.Minimap = {} end
    if LDBIcon and ns.LDBObj then LDBIcon:Register(addonName, ns.LDBObj, CC_Settings.Minimap) end
end)
