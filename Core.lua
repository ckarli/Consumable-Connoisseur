local _, ns = ...
local L = ns.L
local C = ns.Colors
local Config = ns.Config

local frame = CreateFrame("Frame")
local scannerTooltip = CreateFrame("GameTooltip", "CC_ScannerTooltip", UIParent, "GameTooltipTemplate")
scannerTooltip:SetOwner(UIParent, "ANCHOR_NONE")

ns.BestFoodID = nil
ns.BestFoodLink = nil
local updateQueued = false
local updateTimer = 0
local buffScanTimer = 0
local currentMacroState = {}
local itemCache = {}
local scanLines = {} 

local function InitVars()
    if not CC_IgnoreList then CC_IgnoreList = {} end
    if not CC_Settings then CC_Settings = { UseBuffFood = false } end
    
    wipe(itemCache)

    if CC_Settings.UseBuffFood then
        frame:RegisterUnitEvent("UNIT_AURA", "player")
    else
        frame:UnregisterEvent("UNIT_AURA")
    end
end

function ns.ToggleBuffFood()
    CC_Settings.UseBuffFood = not CC_Settings.UseBuffFood
    if CC_Settings.UseBuffFood then
        frame:RegisterUnitEvent("UNIT_AURA", "player")
    else
        frame:UnregisterEvent("UNIT_AURA")
    end
    ns.UpdateMacros(true)
end

local function ParseNumber(text)
    if not text then return 0 end
    local match = text:match("([%d,]+)")
    if not match then return 0 end
    local val = string.gsub(match, ",", "")
    return tonumber(val) or 0
end

local function GetFirstAidRank()
    local profs = {GetProfessions()}
    for _, index in ipairs(profs) do
        local name, _, rank = GetProfessionInfo(index)
        if name == "First Aid" then return rank end
    end
    return 0
end

local function PlayerHasBuff(buffName)
    for i = 1, 40 do
        local name = UnitAura("player", i, "HELPFUL")
        if not name then return false end
        if name == buffName then return true end
    end
    return false
end

local function IsInAllowedZone(itemID)
    local allowedZones = ns.ItemZoneRestrictions[itemID]
    if not allowedZones then return true end
    local currentMap = C_Map.GetBestMapForUnit("player")
    for _, mapID in ipairs(allowedZones) do
        if mapID == currentMap then return true end
    end
    return false
end

local function ScanBagItem(bag, slot)
    local info = C_Container.GetContainerItemInfo(bag, slot)
    if not info or not info.itemID then return nil end
    local itemID = info.itemID

    if CC_IgnoreList[itemID] or ns.Excludes[itemID] then return nil end

    local staticData = itemCache[itemID]
    if not staticData then
        scannerTooltip:ClearLines()
        scannerTooltip:SetHyperlink(info.hyperlink)
        
        wipe(scanLines)
        for i = 1, scannerTooltip:NumLines() do
            local line = _G["CC_ScannerTooltipTextLeft"..i]
            if line then 
                local text = line:GetText()
                if text then table.insert(scanLines, text:lower()) end
            end
        end

        staticData = {
            id = itemID,
            valHealth = 0, valMana = 0, reqLvl = 0, reqFA = 0, price = 0,
            isFood = false, isWater = false, isBandage = false, 
            isPotion = false, isHealthstone = false, isBuffFood = false
        }

        local _, _, _, _, _, _, _, _, _, _, iPrice = GetItemInfo(itemID)
        staticData.price = iPrice or 0

        local foundSeated = false
        local foundMana = false
        local foundHealth = false
        local foundWellFed = false
        local foundRestoresVal = 0
        local foundHealsVal = 0

        for _, text in ipairs(scanLines) do
            local lvl = text:match(L["SCAN_REQ_LEVEL"])
            if lvl then staticData.reqLvl = tonumber(lvl) end

            local fa = text:match(L["SCAN_REQ_FA"])
            if fa then staticData.reqFA = tonumber(fa) end

            if text:find(L["SCAN_SEATED"]) then foundSeated = true end
            if text:find(L["SCAN_MANA"]) then foundMana = true end
            if text:find(L["SCAN_HEALTH"]) then foundHealth = true end
            if text:find(L["SCAN_WELL_FED"]) then foundWellFed = true end

            local rVal = ParseNumber(text:match(L["SCAN_RESTORES"]))
            if rVal > 0 then foundRestoresVal = rVal end
            
            local hVal = ParseNumber(text:match(L["SCAN_HEALS"]))
            if hVal > 0 then foundHealsVal = hVal end
            
            if text:find(L["SCAN_USE"]) and foundRestoresVal == 0 then
                 local uVal = ParseNumber(text)
                 if uVal > 0 then foundRestoresVal = uVal end
            end
        end

        if foundSeated then
            if foundMana then 
                staticData.isWater = true 
                staticData.valMana = foundRestoresVal
            end
            if foundHealth then 
                staticData.isFood = true 
                staticData.valHealth = foundRestoresVal
            end
            if foundWellFed then staticData.isBuffFood = true end
        
        elseif foundHealsVal > 0 and foundHealth then
            staticData.isBandage = true
            staticData.valHealth = foundHealsVal

        elseif foundRestoresVal > 0 then
            if foundMana then
                staticData.isPotion = true
                staticData.valMana = foundRestoresVal
            elseif foundHealth then
                local n = GetItemInfo(itemID)
                if n and n:find("Healthstone") then
                    staticData.isHealthstone = true
                else
                    staticData.isPotion = true
                end
                staticData.valHealth = foundRestoresVal
            end
        end
        
        itemCache[itemID] = staticData
    end

    if not IsInAllowedZone(itemID) then return nil end
    if staticData.reqLvl > UnitLevel("player") then return nil end
    if staticData.reqFA > GetFirstAidRank() then return nil end

    return {
        id = staticData.id, valHealth = staticData.valHealth, valMana = staticData.valMana,
        price = staticData.price, isFood = staticData.isFood, isWater = staticData.isWater,
        isBandage = staticData.isBandage, isPotion = staticData.isPotion,
        isHealthstone = staticData.isHealthstone, isBuffFood = staticData.isBuffFood,
        bag = bag, slot = slot, stack = info.stackCount, link = info.hyperlink
    }
end

local function IsBetter(item, best)
    if not best then return true end
    local iVal, bVal = item.valHealth + item.valMana, best.valHealth + best.valMana
    if iVal ~= bVal then return iVal > bVal end
    if item.price ~= best.price then return item.price < best.price end
    local iHyb, bHyb = (item.valHealth > 0 and item.valMana > 0), (best.valHealth > 0 and best.valMana > 0)
    if iHyb ~= bHyb then return iHyb end
    return item.stack < best.stack
end

function ns.UpdateMacros(forced)
    if InCombatLockdown() then return end
    
    local needWellFed = CC_Settings.UseBuffFood and not PlayerHasBuff(L["BUFF_WELL_FED"])
    local best = { ["Food"] = nil, ["Water"] = nil, ["Health Potion"] = nil, ["Mana Potion"] = nil, ["Healthstone"] = nil, ["Bandage"] = nil }
    local bestRegularFood, bestBuffFood = nil, nil

    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local item = ScanBagItem(bag, slot)
            if item then
                if item.isBandage then
                    if IsBetter(item, best["Bandage"]) then best["Bandage"] = item end
                elseif item.isHealthstone then
                    if IsBetter(item, best["Healthstone"]) then best["Healthstone"] = item end
                elseif item.isPotion then
                    if item.valHealth > 0 and IsBetter(item, best["Health Potion"]) then best["Health Potion"] = item end
                    if item.valMana > 0 and IsBetter(item, best["Mana Potion"]) then best["Mana Potion"] = item end
                elseif item.isFood then
                    if item.isBuffFood then
                        if IsBetter(item, bestBuffFood) then bestBuffFood = item end
                    else
                        if IsBetter(item, bestRegularFood) then bestRegularFood = item end
                    end
                elseif item.isWater then
                    if IsBetter(item, best["Water"]) then best["Water"] = item end
                end
            end
        end
    end

    best["Food"] = (CC_Settings.UseBuffFood and needWellFed) and (bestBuffFood or bestRegularFood) or bestRegularFood

    if ns.BestFoodID ~= (best["Food"] and best["Food"].id or nil) then
        ns.BestFoodID = best["Food"] and best["Food"].id or nil
        ns.BestFoodLink = best["Food"] and best["Food"].link or nil
        if ns.LDBObj then ns.LDBObj.icon = best["Food"] and GetItemIcon(ns.BestFoodID) or GetItemIcon(5349) end
    end

    for typeName, cfg in pairs(Config) do
        local item = best[typeName]
        local body, icon, stateID
        
        if item then
            body = "#showtooltip item:"..item.id.."\n/run CC_LastID="..item.id..";CC_LastTime=GetTime()\n/use item:"..item.id
            icon = GetItemIcon(item.id)
            stateID = tostring(item.id)
        else
            local msg = string.format(L["MSG_NO_ITEM"], typeName)
            body = string.format("#showtooltip item:%d\n/run print('%s%s%s // %s%s')", cfg.defaultID, C.BLUE, L["BRAND"], C.GRAY, C.WHITE, msg)
            icon = GetItemIcon(cfg.defaultID)
            stateID = "none"
        end

        if currentMacroState[typeName] ~= stateID or forced then
            local index = GetMacroIndexByName(cfg.macro)
            if index == 0 then CreateMacro(cfg.macro, icon, body, 1) else EditMacro(index, cfg.macro, icon, body) end
            currentMacroState[typeName] = stateID
        end
    end
end

local function QueueUpdate()
    if InCombatLockdown() then 
        frame:RegisterEvent("PLAYER_REGEN_ENABLED") 
        return 
    end
    updateQueued = true
end

frame:SetScript("OnUpdate", function(self, elapsed)
    if updateQueued then
        updateTimer = updateTimer + elapsed
        if updateTimer > 1.0 then 
            ns.UpdateMacros()
            updateQueued, updateTimer = false, 0
        end
    end
    if not InCombatLockdown() then
        buffScanTimer = buffScanTimer + elapsed
        if buffScanTimer > 10.0 then
            ns.UpdateMacros()
            buffScanTimer = 0
        end
    end
end)

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == "Consumable-Connoisseur" then
        InitVars()
        frame:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_ENTERING_WORLD" then
        InitVars()
        QueueUpdate()
    elseif event == "PLAYER_REGEN_ENABLED" then
        frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
        QueueUpdate()
    elseif event == "UI_ERROR_MESSAGE" then
        if CC_LastTime and (GetTime() - CC_LastTime) < 1.0 then
            local _, msg = ...
            if msg == L["ERR_ZONE"] then
                local mapID = C_Map.GetBestMapForUnit("player") or "0"
                local zone = GetZoneText() or "?"
                local subzone = GetSubZoneText() or ""
                if subzone == "" then subzone = zone end 
                
                local itemID = CC_LastID or 0
                local link = "Item #"..itemID
                if itemID ~= 0 then 
                    local _, l = GetItemInfo(itemID)
                    if l then link = l end
                end
                
                print(C.BLUE..L["BRAND"]..C.GRAY.." // "..C.WHITE..
                    string.format(L["MSG_BUG_REPORT"], link, itemID, zone, subzone, mapID))
                
                CC_LastTime = 0
            end
        end
    else
        QueueUpdate()
    end
end)

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("UI_ERROR_MESSAGE")
frame:RegisterEvent("PLAYER_UNGHOST")
frame:RegisterEvent("PLAYER_ALIVE")
