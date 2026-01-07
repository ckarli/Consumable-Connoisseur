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

local currentMacroState = {}
local itemCache = {} 

local isUpdatePending = false
local updateTimer = 0
local UPDATE_THROTTLE = 0.5 

-- [[ INITIALIZATION ]] --
local function InitVars()
    if not CC_IgnoreList then CC_IgnoreList = {} end
    if not CC_Settings then CC_Settings = { UseBuffFood = false } end
    if not CC_Settings.Minimap then CC_Settings.Minimap = {} end

    ns.SpellCache = {}
    if ns.ConjureSpells then
        for _, spellList in pairs(ns.ConjureSpells) do
            for _, data in ipairs(spellList) do
                local id = data[1]
                local name = GetSpellInfo(id)
                if name then ns.SpellCache[id] = name end
            end
        end
    end

    local LDBIcon = LibStub("LibDBIcon-1.0", true)
    if LDBIcon and ns.LDBObj and not ns.IconRegistered then 
        LDBIcon:Register("Connoisseur", ns.LDBObj, CC_Settings.Minimap)
        ns.IconRegistered = true
    end

    if CC_Settings.UseBuffFood then
        frame:RegisterUnitEvent("UNIT_AURA", "player")
    else
        frame:UnregisterEvent("UNIT_AURA")
    end
    
    if ns.UpdateLDB then ns.UpdateLDB() end
end

function ns.ToggleBuffFood()
    CC_Settings.UseBuffFood = not CC_Settings.UseBuffFood
    if CC_Settings.UseBuffFood then
        frame:RegisterUnitEvent("UNIT_AURA", "player")
    else
        frame:UnregisterEvent("UNIT_AURA")
    end
    wipe(currentMacroState)
    ns.RequestUpdate()
end

-- [[ HELPER FUNCTIONS ]] --

local function ParseNumber(text)
    if not text then return 0 end
    local match = text:match("([%d,]+)")
    if not match then return 0 end
    return tonumber((string.gsub(match, ",", ""))) or 0
end

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
            local name, rank = GetSpellInfo(id) 
            if name then
                -- 1. Classic Check: If name has parens (e.g. "Create Healthstone (Minor)"), use it as-is.
                if name:find("%(") then
                    return name, id
                end

                if rank and rank ~= "" then 
                    if rank:find("%d") then
                         -- TBC: "Rank 1" -> "Create Healthstone(Rank 1)" (No Space)
                        return name .. "(" .. rank .. ")", id
                    else
                        -- Classic: "Minor" -> "Create Healthstone (Minor)" (Space)
                        return name .. " (" .. rank .. ")", id
                    end
                end
                
                if rankNum then
                    return name .. "(Rank " .. rankNum .. ")", id
                end

                return name, id
            end
        end
    end
    return nil, 0
end

-- [[ ITEM SCANNING ]] --

local function CacheItemData(itemID)
    local name, _, _, _, _, classType, subType, _, _, _, iPrice, classID = GetItemInfo(itemID)
    if not name then return nil end 

    if classID ~= 0 then
        itemCache[itemID] = "IGNORE"
        return "IGNORE"
    end

    scannerTooltip:ClearLines()
    scannerTooltip:SetHyperlink("item:"..itemID)
    if scannerTooltip:NumLines() == 0 then return nil end 

    local data = {
        id = itemID, valHealth = 0, valMana = 0, reqLvl = 0, reqFA = 0, price = iPrice or 0,
        isFood = false, isWater = false, isBandage = false, 
        isPotion = false, isHealthstone = false, isBuffFood = false, isPercent = false,
        incomplete = false
    }

    local foundSeated = false
    local isStrictHealth, isStrictMana = false, false
    
    local txtAlcohol = L["SCAN_ALCOHOL"]
    local txtLevel = L["SCAN_REQ_LEVEL"]
    local txtFA = L["SCAN_REQ_FA"]
    local txtSeated = L["SCAN_SEATED"]
    local txtWellFed = L["SCAN_WELL_FED"]

    for i = 1, scannerTooltip:NumLines() do
        local line = _G["CC_ScannerTooltipTextLeft"..i]
        local text = line and line:GetText() and line:GetText():lower()
        if text then
            if text:find(txtAlcohol) then 
                itemCache[itemID] = "IGNORE"
                return "IGNORE" 
            end

            local lvl = text:match(txtLevel)
            if lvl then data.reqLvl = tonumber(lvl) end

            local fa = text:match(txtFA)
            if fa then 
                data.reqFA = tonumber(fa) 
                
                local r, g, b = line:GetTextColor()
                if g < 0.5 then
                    itemCache[itemID] = "IGNORE"
                    return "IGNORE"
                end
            end

            if text:find(txtSeated) then foundSeated = true end
            if text:find(txtWellFed) then data.isBuffFood = true end
            
            if not isStrictHealth and not isStrictMana then
                local hMin = text:match(L["SCAN_HPOT_STRICT"])
                if hMin then
                    data.valHealth = ParseNumber(hMin)
                    isStrictHealth = true
                    data.isPotion = true
                end

                local mMin = text:match(L["SCAN_MPOT_STRICT"])
                if mMin and not text:find(L["SCAN_HYBRID"]) then
                    data.valMana = ParseNumber(mMin)
                    isStrictMana = true
                    data.isPotion = true
                end
            end

            if not isStrictHealth and not isStrictMana then
                local pVal = ParseNumber(text:match(L["SCAN_PERCENT"]))
                if pVal > 0 then
                    data.isPercent = true
                    if text:find(L["SCAN_MANA"]) then data.valMana = 999999 end
                    if text:find(L["SCAN_HEALTH"]) or (not text:find(L["SCAN_MANA"])) then data.valHealth = 999999 end
                else
                    local rVal = ParseNumber(text:match(L["SCAN_RESTORES"]))
                    local hVal = ParseNumber(text:match(L["SCAN_HEALS"]))
                    if rVal > 0 or hVal > 0 then
                        local val = (rVal > hVal) and rVal or hVal
                        if text:find(L["SCAN_MANA"]) then data.valMana = val end
                        if text:find(L["SCAN_HEALTH"]) or text:find(L["SCAN_HEALS"]) then data.valHealth = val end
                    end
                end
            end
        end
    end

    local nameLower = name:lower()
    if foundSeated then
        if data.valMana > 0 then data.isWater = true end
        if data.valHealth > 0 then data.isFood = true end
        if not data.isWater and not data.isFood then data.isFood = true end
    elseif (subType == "Bandage" or nameLower:find("bandage")) and data.valHealth > 0 then
        data.isBandage = true
    elseif nameLower:find("healthstone") and data.valHealth > 0 then
        data.isHealthstone = true
    end

    -- [[ CACHE LOGIC UPDATE ]] --
    if data.valHealth == 0 and data.valMana == 0 and not data.isBuffFood then
        data.incomplete = true
        return data
    end

    itemCache[itemID] = data
    return data
end

local function IsBetter(itemData, itemStack, itemPrice, best)
    if not best.id then return true end
    if ns.AllowBuffFood then
        if itemData.isBuffFood ~= best.isBuffFood then return itemData.isBuffFood end
    end
    if itemData.isPercent ~= best.isPercent then return itemData.isPercent end
    local iVal = itemData.valHealth + itemData.valMana
    local bVal = best.val
    if iVal ~= bVal then return iVal > bVal end
    if itemPrice ~= best.price then return itemPrice < best.price end
    local iHyb = (itemData.valHealth > 0 and itemData.valMana > 0)
    local bHyb = best.isHybrid
    if iHyb ~= bHyb then return iHyb end
    return itemStack < best.stack
end

-- [[ MACRO MANAGEMENT ]] --

function ns.UpdateMacros(forced)
    if InCombatLockdown() then 
        isUpdatePending = true 
        return 
    end
    
    local playerLevel = UnitLevel("player")
    local currentMap = C_Map.GetBestMapForUnit("player")
    local wellFedName = GetSpellInfo(19705)
    local hasWellFed = false
    
    if CC_Settings.UseBuffFood and wellFedName then
        for i = 1, 40 do
            local name = UnitAura("player", i, "HELPFUL")
            if not name then break end
            if name == wellFedName then hasWellFed = true; break end
        end
    end

    ns.AllowBuffFood = CC_Settings.UseBuffFood and not hasWellFed

    local best = {
        ["Food"] =          { id = nil, val = 0, price = 0, isBuffFood = false, isPercent = false, isHybrid = false, stack = 0, link = nil },
        ["Water"] =         { id = nil, val = 0, price = 0, isBuffFood = false, isPercent = false, isHybrid = false, stack = 0 },
        ["Health Potion"] = { id = nil, val = 0, price = 0, isBuffFood = false, isPercent = false, isHybrid = false, stack = 0 },
        ["Mana Potion"] =   { id = nil, val = 0, price = 0, isBuffFood = false, isPercent = false, isHybrid = false, stack = 0 },
        ["Healthstone"] =   { id = nil, val = 0, price = 0, isBuffFood = false, isPercent = false, isHybrid = false, stack = 0 },
        ["Bandage"] =       { id = nil, val = 0, price = 0, isBuffFood = false, isPercent = false, isHybrid = false, stack = 0 }
    }
    
    local dataRetry = false
    
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.itemID then
                local id = info.itemID
                
                if CC_IgnoreList[id] or ns.Excludes[id] then
                else
                    local data = itemCache[id]
                    if not data then data = CacheItemData(id) end

                    if not data then
                        GetItemInfo(id) 
                        dataRetry = true
                    elseif data == "IGNORE" then
                    else
                        if data.incomplete then
                            dataRetry = true
                        end

                        local usable = true
                        if data.reqLvl > playerLevel then usable = false end
                        
                        if usable and ns.ItemZoneRestrictions[id] then
                            usable = false
                            if currentMap then
                                for _, mapID in ipairs(ns.ItemZoneRestrictions[id]) do
                                    if mapID == currentMap then usable = true; break end
                                end
                            end
                        end

                        if usable then
                            local typeToUpdate = nil
                            if data.isBandage then typeToUpdate = "Bandage"
                            elseif data.isHealthstone then typeToUpdate = "Healthstone"
                            elseif data.isPotion then
                                if data.valHealth > 0 and IsBetter(data, info.stackCount, data.price, best["Health Potion"]) then
                                    best["Health Potion"].id = id
                                    best["Health Potion"].val = data.valHealth + data.valMana
                                    best["Health Potion"].price = data.price
                                    best["Health Potion"].stack = info.stackCount
                                end
                                if data.valMana > 0 and IsBetter(data, info.stackCount, data.price, best["Mana Potion"]) then
                                    best["Mana Potion"].id = id
                                    best["Mana Potion"].val = data.valHealth + data.valMana
                                    best["Mana Potion"].price = data.price
                                    best["Mana Potion"].stack = info.stackCount
                                end
                            elseif data.isFood or data.isWater then
                                if not (data.isBuffFood and not ns.AllowBuffFood) then
                                    if data.isFood then typeToUpdate = "Food" end
                                    if data.isWater and typeToUpdate == "Food" then
                                        if IsBetter(data, info.stackCount, data.price, best["Water"]) then
                                            best["Water"].id = id
                                            best["Water"].val = data.valHealth + data.valMana
                                            best["Water"].price = data.price
                                            best["Water"].stack = info.stackCount
                                            best["Water"].isBuffFood = data.isBuffFood
                                            best["Water"].isPercent = data.isPercent
                                            best["Water"].isHybrid = (data.valHealth > 0 and data.valMana > 0)
                                        end
                                    elseif data.isWater then
                                        typeToUpdate = "Water"
                                    end
                                end
                            end

                            if typeToUpdate then
                                local b = best[typeToUpdate]
                                if IsBetter(data, info.stackCount, data.price, b) then
                                    b.id = id
                                    b.val = data.valHealth + data.valMana
                                    b.price = data.price
                                    b.stack = info.stackCount
                                    b.isBuffFood = data.isBuffFood
                                    b.isPercent = data.isPercent
                                    b.isHybrid = (data.valHealth > 0 and data.valMana > 0)
                                    if typeToUpdate == "Food" then b.link = info.hyperlink end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if dataRetry then
        frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
        C_Timer.After(2, function() ns.RequestUpdate() end)
    else
        frame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
    end

    ns.BestFoodID = best["Food"].id
    ns.BestFoodLink = best["Food"].link

    for typeName, cfg in pairs(Config) do
        local itemID = best[typeName].id
        local tooltipLine, actionBlock, stateID, icon
        
        if itemID then
            tooltipLine = "#showtooltip item:"..itemID.."\n"
            actionBlock = "/run CC_LastID="..itemID..";CC_LastTime=GetTime()\n/use item:"..itemID
            stateID = tostring(itemID)
            icon = GetItemIcon(itemID)
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
            stateID = stateID .. "_C" 

            if midSpellName then
                castLine = castLine .. "[btn:3] " .. midSpellName .. "; "
                stopConditions = stopConditions .. "[btn:3]"
                stateID = stateID .. "_M:" .. midSpellID
            end
            if rightSpellName then
                castLine = castLine .. "[btn:2] " .. rightSpellName .. "; "
                stopConditions = stopConditions .. "[btn:2]"
                stateID = stateID .. "_R:" .. rightSpellID
            end

            if castLine ~= "" then
                conjureBlock = "/cast " .. castLine .. "\n/stopmacro " .. stopConditions .. "\n"
            end
        end

        local body = tooltipLine .. conjureBlock .. actionBlock

        if currentMacroState[typeName] ~= stateID or forced then
            local index = GetMacroIndexByName(cfg.macro)
            if index == 0 then 
                CreateMacro(cfg.macro, icon, body, 1) 
            else 
                EditMacro(index, cfg.macro, icon, body) 
            end
            currentMacroState[typeName] = stateID
        end
    end

    if ns.UpdateLDB then ns.UpdateLDB() end
end

-- [[ EVENT HANDLING ]] --

function ns.RequestUpdate()
    isUpdatePending = true
    updateTimer = 0 
end

frame:SetScript("OnUpdate", function(self, elapsed)
    if isUpdatePending then
        updateTimer = updateTimer + elapsed
        if updateTimer > UPDATE_THROTTLE then 
            isUpdatePending = false
            ns.UpdateMacros()
        end
    end
end)

frame:SetScript("OnEvent", function(self, event, ...)
    if InCombatLockdown() then
        if event == "PLAYER_REGEN_ENABLED" then
            if isUpdatePending then ns.RequestUpdate() end
        else
            isUpdatePending = true
        end
        return
    end

    if event == "BAG_UPDATE_DELAYED" then
        ns.RequestUpdate()
        
    elseif event == "PLAYER_ENTERING_WORLD" then
        InitVars()
        ns.RequestUpdate()
        C_Timer.After(3, function() ns.RequestUpdate() end) 
        
    elseif event == "GET_ITEM_INFO_RECEIVED" then
        ns.RequestUpdate()

    elseif event == "PLAYER_TARGET_CHANGED" then
        ns.RequestUpdate()

    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, _, spellID = ...
        if ns.SpellCache and ns.SpellCache[spellID] then
            ns.RequestUpdate()
        end
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
                print(C.INFO..L["BRAND"]..C.MUTED.." // "..C.TEXT..
                    string.format(L["MSG_BUG_REPORT"], link, itemID, zone, subzone, mapID))
                CC_LastTime = 0
            end
        end
    end
end)

frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("UI_ERROR_MESSAGE")
frame:RegisterEvent("PLAYER_UNGHOST")
frame:RegisterEvent("PLAYER_ALIVE")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
