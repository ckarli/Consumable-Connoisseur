local _, ns = ...
local L = ns.L
local C = ns.Colors
local Config = ns.Config

-- [[ FRAME & TOOLTIP SETUP ]] --
local frame = CreateFrame("Frame")
local scannerTooltip = CreateFrame("GameTooltip", "CC_ScannerTooltip", UIParent, "GameTooltipTemplate")
scannerTooltip:SetOwner(UIParent, "ANCHOR_NONE")

-- [[ STATE VARIABLES ]] --
ns.BestFoodID = nil
ns.BestFoodLink = nil
local updateQueued = false
local updateTimer = 0
local buffScanTimer = 0
local currentMacroState = {}
local itemCache = {} -- Caches static item data (stats, type) to reduce tooltip scanning
local scanLines = {} 

local function InitVars()
    if not CC_IgnoreList then CC_IgnoreList = {} end
    if not CC_Settings then CC_Settings = { UseBuffFood = false } end
    wipe(itemCache)

    -- Only listen for buffs if we care about "Well Fed" status
    if CC_Settings.UseBuffFood then
        frame:RegisterUnitEvent("UNIT_AURA", "player")
    else
        frame:UnregisterEvent("UNIT_AURA")
    end
end

-- Toggles the "Well Fed" prioritization setting
function ns.ToggleBuffFood()
    CC_Settings.UseBuffFood = not CC_Settings.UseBuffFood
    if CC_Settings.UseBuffFood then
        frame:RegisterUnitEvent("UNIT_AURA", "player")
    else
        frame:UnregisterEvent("UNIT_AURA")
    end
    ns.UpdateMacros(true)
end

-- [[ HELPER FUNCTIONS ]] --

-- Extracts the first number found in a string (removes commas)
local function ParseNumber(text)
    if not text then return 0 end
    local match = text:match("([%d,]+)")
    if not match then return 0 end
    return tonumber((string.gsub(match, ",", ""))) or 0
end

local function PlayerHasBuff(buffName)
    for i = 1, 40 do
        local name = UnitAura("player", i, "HELPFUL")
        if not name then return false end
        if name == buffName then return true end
    end
    return false
end

-- Logic for Mages/Warlocks to downrank spells if targeting low level players
local function GetSmartSpell(spellList)
    if not spellList then return nil, 0 end
    local levelCap = UnitLevel("player")
    
    if UnitExists("target") and UnitIsFriend("player", "target") and UnitIsPlayer("target") then
        local tLvl = UnitLevel("target")
        if tLvl > 0 then levelCap = tLvl end
    end

    local knownHighest = false
    for _, data in ipairs(spellList) do
        local id, req, rankNum = data[1], data[2], data[3]
        if IsSpellKnown(id) then knownHighest = true end
        if knownHighest and req <= levelCap then
            local name = GetSpellInfo(id)
            if name then
                if rankNum then return name .. "(" .. L["RANK"] .. " " .. rankNum .. ")", id end
                return name, id
            end
        end
    end
    return nil, 0
end

-- Checks if an item is restricted to specific zones (Battlegrounds, etc.)
local function IsInAllowedZone(itemID)
    local allowedZones = ns.ItemZoneRestrictions[itemID]
    if not allowedZones then return true end
    local currentMap = C_Map.GetBestMapForUnit("player")
    if not currentMap then return false end 
    
    for _, mapID in ipairs(allowedZones) do
        if mapID == currentMap then return true end
    end
    return false
end

-- [[ SCANNING LOGIC ]] --

-- Scans a specific bag slot to determine if it is a valid consumable
local function ScanBagItem(bag, slot)
    local info = C_Container.GetContainerItemInfo(bag, slot)
    if not info or not info.itemID then return nil end
    local itemID = info.itemID

    if CC_IgnoreList[itemID] or ns.Excludes[itemID] then return nil end

    -- Optimization: Quick Class Check (Consumable = 0)
    local _, _, _, _, _, classID = GetItemInfoInstant(itemID)
    if classID ~= 0 then return nil end

    -- Check Cache first to avoid expensive Tooltip scanning
    local staticData = itemCache[itemID]
    if not staticData then
        local name, _, _, _, _, _, subType, _, _, _, iPrice = GetItemInfo(itemID)
        if not name then return nil end 

        -- Load item into invisible tooltip to scrape text
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
            valHealth = 0, valMana = 0, reqLvl = 0, price = iPrice or 0,
            isFood = false, isWater = false, isBandage = false, 
            isPotion = false, isHealthstone = false, isBuffFood = false,
            isPercent = false
        }

        local foundSeated, foundMana, foundHealth, foundWellFed = false, false, false, false
        local foundAlcohol = false

        -- Regex Parsing Loop
        for _, text in ipairs(scanLines) do
            
            if text:find(L["SCAN_ALCOHOL"]) then foundAlcohol = true end

            local lvl = text:match(L["SCAN_REQ_LEVEL"])
            if lvl then staticData.reqLvl = tonumber(lvl) end

            if text:find(L["SCAN_SEATED"]) then foundSeated = true end
            if text:find(L["SCAN_WELL_FED"]) then foundWellFed = true end
            if text:find(L["SCAN_MANA"]) then foundMana = true end
            if text:find(L["SCAN_HEALTH"]) then foundHealth = true end

            -- Priority 1: Percentage based food (Holiday items)
            local pVal = ParseNumber(text:match(L["SCAN_PERCENT"]))
            if pVal > 0 then
                staticData.isPercent = true
                -- Assign arbitrary high value to ensure it beats flat food
                if foundHealth then staticData.valHealth = 999999 end
                if foundMana then staticData.valMana = 999999 end
            else
                -- Priority 2: Flat value food
                local rVal = ParseNumber(text:match(L["SCAN_RESTORES"]))
                local hVal = ParseNumber(text:match(L["SCAN_HEALS"]))
                
                local val = (rVal > 0 and rVal) or (hVal > 0 and hVal) or 0
                
                if val > 0 then
                    if text:find(L["SCAN_MANA"]) then staticData.valMana = val end
                    if text:find(L["SCAN_HEALTH"]) or text:find(L["SCAN_HEALS"]) then staticData.valHealth = val end
                    
                    -- Catch-all for implicit stats
                    if not text:find(L["SCAN_MANA"]) and not text:find(L["SCAN_HEALTH"]) then
                         if staticData.valHealth == 0 and staticData.valMana == 0 then
                             staticData.valHealth = val 
                         end
                    end
                end
            end
        end

        if foundAlcohol then 
            itemCache[itemID] = "IGNORE" 
            return nil 
        end

        local nameLower = name:lower()
        local isBandageByName = (subType == "Bandage" or nameLower:find("bandage"))

        -- Categorize item based on flags
        if foundSeated then
            if foundMana then staticData.isWater = true end
            if foundHealth then staticData.isFood = true end
            if foundWellFed then staticData.isBuffFood = true end
            
            -- Fallback for weirdly formatted food items
            if not foundMana and not foundHealth then
                staticData.isFood = true 
            end
        
        elseif isBandageByName and (staticData.valHealth > 0) then
            staticData.isBandage = true

        elseif staticData.valHealth > 0 or staticData.valMana > 0 then
            if foundMana and not foundHealth then
                staticData.isPotion = true
            elseif foundHealth or staticData.valHealth > 0 then 
                if nameLower:find("healthstone") then
                    staticData.isHealthstone = true
                else
                    staticData.isPotion = true
                end
            end
        end
        itemCache[itemID] = staticData
    end

    if staticData == "IGNORE" then return nil end

    if not IsInAllowedZone(itemID) then return nil end
    
    if staticData.reqLvl > UnitLevel("player") then return nil end

    return {
        id = staticData.id, 
        valHealth = staticData.valHealth, 
        valMana = staticData.valMana,
        price = staticData.price, 
        isFood = staticData.isFood, 
        isWater = staticData.isWater,
        isBandage = staticData.isBandage, 
        isPotion = staticData.isPotion,
        isHealthstone = staticData.isHealthstone, 
        isBuffFood = staticData.isBuffFood,
        isPercent = staticData.isPercent,
        bag = bag, slot = slot, stack = info.stackCount, link = info.hyperlink
    }
end

-- Comparison logic for sorting
local function IsBetter(item, best)
    if not best then return true end
    
    -- 1. Percentage (Holiday) Food beats everything
    if item.isPercent ~= best.isPercent then return item.isPercent end
    
    -- 2. Raw Total Value (Health + Mana)
    local iVal, bVal = item.valHealth + item.valMana, best.valHealth + best.valMana
    if iVal ~= bVal then return iVal > bVal end
    
    -- 3. Cheapest Vendor Price (Save money)
    if item.price ~= best.price then return item.price < best.price end
    
    -- 4. Hybrid Efficiency (Restores both > Restores one)
    local iHyb = (item.valHealth > 0 and item.valMana > 0)
    local bHyb = (best.valHealth > 0 and best.valMana > 0)
    if iHyb ~= bHyb then return iHyb end
    
    -- 5. Smallest Stack Size (Clear bag space)
    return item.stack < best.stack
end

-- [[ MACRO MANAGEMENT ]] --

function ns.UpdateMacros(forced)
    if InCombatLockdown() then return end
    
    local needWellFed = CC_Settings.UseBuffFood and not PlayerHasBuff(L["BUFF_WELL_FED"])
    local best = { ["Food"] = nil, ["Water"] = nil, ["Health Potion"] = nil, ["Mana Potion"] = nil, ["Healthstone"] = nil, ["Bandage"] = nil }
    local bestBuffFood = nil

    -- Loop through all bags/slots to find best items
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
                    -- 1. Unified Logic: Always track the absolute best food found so far (Mirrors Water logic)
                    if IsBetter(item, best["Food"]) then best["Food"] = item end

                    -- 2. Separately track best "Well Fed" food for the specific override condition
                    if item.isBuffFood then
                        if IsBetter(item, bestBuffFood) then bestBuffFood = item end
                    end
                elseif item.isWater then
                    if IsBetter(item, best["Water"]) then best["Water"] = item end
                end
            end
        end
    end

    -- Override: If user needs "Well Fed" and we found buff food, force that to be the best.
    if needWellFed and bestBuffFood then
        best["Food"] = bestBuffFood
    end

    -- Update LDB/Minimap icon
    if ns.BestFoodID ~= (best["Food"] and best["Food"].id or nil) then
        ns.BestFoodID = best["Food"] and best["Food"].id or nil
        ns.BestFoodLink = best["Food"] and best["Food"].link or nil
        if ns.LDBObj then ns.LDBObj.icon = best["Food"] and GetItemIcon(ns.BestFoodID) or GetItemIcon(5349) end
    end

    -- Write macros
    for typeName, cfg in pairs(Config) do
        local item = best[typeName]
        local tooltipLine, actionBlock, stateID, icon
        
        if item then
            tooltipLine = "#showtooltip item:"..item.id.."\n"
            actionBlock = "/run CC_LastID="..item.id..";CC_LastTime=GetTime()\n/use item:"..item.id
            stateID = tostring(item.id)
            icon = GetItemIcon(item.id)
        else
            local msg = string.format(L["MSG_NO_ITEM"], typeName)
            tooltipLine = "#showtooltip item:"..cfg.defaultID.."\n"
            actionBlock = string.format("/run print('%s%s%s // %s%s')", C.INFO, L["BRAND"], C.MUTED, C.TEXT, msg)
            stateID = "none"
            icon = GetItemIcon(cfg.defaultID)
        end

        local conjureBlock = ""
        local rightSpellName, rightSpellID, midSpellName, midSpellID

        if typeName == "Water" then
            rightSpellName, rightSpellID = GetSmartSpell(ns.ConjureSpells.MageWater)
            midSpellName, midSpellID     = GetSmartSpell(ns.ConjureSpells.MageTable)
        elseif typeName == "Food" then
            rightSpellName, rightSpellID = GetSmartSpell(ns.ConjureSpells.MageFood)
            midSpellName, midSpellID     = GetSmartSpell(ns.ConjureSpells.MageTable)
        elseif typeName == "Healthstone" then
            rightSpellName, rightSpellID = GetSmartSpell(ns.ConjureSpells.WarlockHS)
            midSpellName, midSpellID     = GetSmartSpell(ns.ConjureSpells.WarlockSoul)
        end

        if rightSpellName or midSpellName then
            local castLine = ""
            local stopConditions = ""

            if midSpellName then
                castLine = castLine .. "[btn:3] " .. midSpellName .. "; "
                stopConditions = stopConditions .. "[btn:3]"
            end
            
            if rightSpellName then
                castLine = castLine .. "[btn:2] " .. rightSpellName .. "; "
                stopConditions = stopConditions .. "[btn:2]"
            end

            if castLine ~= "" then
                conjureBlock = "/cast " .. castLine .. "\n/stopmacro " .. stopConditions .. "\n"
                stateID = stateID .. "_R:" .. rightSpellID .. "_M:" .. midSpellID
            end
        end

        local body = tooltipLine .. conjureBlock .. actionBlock

        if currentMacroState[typeName] ~= stateID or forced then
            local index = GetMacroIndexByName(cfg.macro)
            if index == 0 then CreateMacro(cfg.macro, icon, body, 1) else EditMacro(index, cfg.macro, icon, body) end
            currentMacroState[typeName] = stateID
        end
    end
end

-- [[ EVENT HANDLING ]] --

local function QueueUpdate()
    if InCombatLockdown() then 
        frame:RegisterEvent("PLAYER_REGEN_ENABLED") 
        return 
    end
    updateQueued = true
end

-- Throttled Updates
frame:SetScript("OnUpdate", function(self, elapsed)
    if updateQueued then
        updateTimer = updateTimer + elapsed
        if updateTimer > 0.5 then 
            ns.UpdateMacros()
            updateQueued, updateTimer = false, 0
        end
    end
    -- Periodic scan for Buff changes (if enabled)
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
    elseif event == "GET_ITEM_INFO_RECEIVED" then
        QueueUpdate()
    elseif event == "UI_ERROR_MESSAGE" then
        -- Error handling for zone restrictions
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
                
                print(C.INFO..L["BRAND"]..C.MUTED.." // "..C.TEXT..
                    string.format(L["MSG_BUG_REPORT"], link, itemID, zone, subzone, mapID))
                
                CC_LastTime = 0
            end
        end
    elseif event == "PLAYER_TARGET_CHANGED" then
        QueueUpdate()
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        QueueUpdate()
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
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
