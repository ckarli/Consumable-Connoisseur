local _, ns = ...
local L = ns.L

-- [[ STATE VARIABLES ]] --
ns.BestFoodID = nil
ns.BestFoodLink = nil

local itemCache = {} 
local scannerTooltip = CreateFrame("GameTooltip", "CC_ScannerTooltip", UIParent, "GameTooltipTemplate")
scannerTooltip:SetOwner(UIParent, "ANCHOR_NONE")

-- [[ HELPER FUNCTIONS ]] --
local function ParseNumber(text)
    if not text then return 0 end
    local clean = text:gsub("%D", "")
    return tonumber(clean) or 0
end

local function StripCodes(text)
    if not text then return "" end
    text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    text = text:gsub("|T.-|t", "")
    return text
end

local function ExtractNameFromPattern(pattern)
    if not pattern then return nil end
    local namePart = pattern:match("^(.-)%.%*")
    return namePart
end

local function HasWellFedBuff()
    local TARGET_ICON_ID = 136000 
    for i = 1, 40 do
        local name, icon, _, _, _, _, _, _, _, spellID = UnitAura("player", i, "HELPFUL")
        if not name then break end
        if icon == TARGET_ICON_ID then
            return true
        end
        if ns.WellFedBuffIDs and ns.WellFedBuffIDs[spellID] then
            return true
        end
    end
    return false
end

local function CacheItemData(itemID)
    local name, _, _, _, _, classType, subType, _, _, _, iPrice, classID, subClassID = GetItemInfo(itemID)
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
        isConjured = false
    }

    local foundSeated = false
    local isStrictHealth, isStrictMana = false, false
    
    local txtLevel = L["SCAN_REQ_LEVEL"]
    local txtFA = L["SCAN_REQ_FA"]
    local txtSeated = L["SCAN_SEATED"]
    
    local patConjured = L["PATTERN_CONJURED"]

    for i = 1, scannerTooltip:NumLines() do
        local line = _G["CC_ScannerTooltipTextLeft"..i]
        local text = line and line:GetText()
        
        if text then
            if text == RETRIEVING_ITEM_INFO then return nil end
            
            text = StripCodes(text)
            text = text:lower()
            text = text:gsub("([%d])[,%.]", "%1")
            
            local combinedText = name:lower() .. " " .. text

            if txtLevel and text:match(txtLevel) then
                local lvl = text:match(txtLevel)
                if lvl then data.reqLvl = tonumber(lvl) end
            end

            if txtFA and text:match(txtFA) then
                local fa = text:match(txtFA)
                if fa then 
                    data.reqFA = tonumber(fa) 
                    local r, g, b = line:GetTextColor()
                    if g < 0.5 then
                        itemCache[itemID] = "IGNORE"
                        return "IGNORE"
                    end
                end
            end

            if txtSeated and text:find(txtSeated) then foundSeated = true end
            if patConjured and text:find(patConjured) then data.isConjured = true end
            
            if L["PATTERNS_BUFF"] then
                for _, pat in ipairs(L["PATTERNS_BUFF"]) do
                    if text:find(pat) then data.isBuffFood = true; break end
                end
            end
            
            -- [[ STRICT POTION REGEX ]] --
            if not isStrictHealth and not isStrictMana then
                local hMin = L["PATTERN_HPOT"] and text:match(L["PATTERN_HPOT"])
                if hMin then
                    data.valHealth = ParseNumber(hMin)
                    isStrictHealth = true
                    data.isPotion = true
                end

                local mMin = L["PATTERN_MPOT"] and text:match(L["PATTERN_MPOT"])
                if mMin then
                    data.valMana = ParseNumber(mMin)
                    isStrictMana = true
                    data.isPotion = true
                end
            end

            -- [[ FOOD / WATER ]] --
            if not isStrictHealth and not isStrictMana then
                if L["PATTERNS_FOOD"] then
                    for idx, pat in ipairs(L["PATTERNS_FOOD"]) do
                        local matchVal = text:match(pat)
                        if matchVal then
                            if idx == 1 then data.isPercent = true; data.valHealth = 99999
                            else data.valHealth = ParseNumber(matchVal) end
                            break
                        end
                    end
                end
                
                if L["PATTERNS_WATER"] then
                    for idx, pat in ipairs(L["PATTERNS_WATER"]) do
                        local matchVal = text:match(pat)
                        if matchVal then
                            if idx == 1 then data.isPercent = true; data.valMana = 99999
                            else data.valMana = ParseNumber(matchVal) end
                            break
                        end
                    end
                end
            end
            
            -- [[ HS / BANDAGE ]] --
            if L["PATTERN_HS"] then
                 local hsVal = combinedText:match(L["PATTERN_HS"])
                 if hsVal then
                     data.isHealthstone = true
                     data.valHealth = ParseNumber(hsVal)
                 end
            end
            
            if L["PATTERN_BANDAGE"] then
                 local bVal = combinedText:match(L["PATTERN_BANDAGE"])
                 if bVal then
                     data.isBandage = true
                     data.valHealth = ParseNumber(bVal)
                 end
            end
        end
    end

    if foundSeated then
        if data.valMana > 0 then data.isWater = true end
        if data.valHealth > 0 then data.isFood = true end
        if not data.isWater and not data.isFood then data.isFood = true end
    end
    
    if data.isPotion and data.valMana > 0 and data.isConjured then
        data.isPotion = false
    end

    local hasStats = (data.valHealth > 0 or data.valMana > 0)
    
    local nameLower = name:lower()
    local nameCheckHS = ExtractNameFromPattern(L["PATTERN_HS"])
    local nameCheckBandage = ExtractNameFromPattern(L["PATTERN_BANDAGE"])
    
    if (nameCheckHS and nameLower:find(nameCheckHS)) or 
       (nameCheckBandage and nameLower:find(nameCheckBandage)) then
        if not hasStats then return nil end
    end

    if not hasStats and not data.isBuffFood then
        return "IGNORE"
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

function ns.ScanBags()
    local playerLevel = UnitLevel("player")
    local currentMap = C_Map.GetBestMapForUnit("player")
    
    -- [[ UPDATED BUFF CHECK ]] --
    local hasWellFed = false
    
    if CC_Settings.UseBuffFood then
        hasWellFed = HasWellFedBuff()
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

    ns.BestFoodID = best["Food"].id
    ns.BestFoodLink = best["Food"].link
    
    return best, dataRetry
end
