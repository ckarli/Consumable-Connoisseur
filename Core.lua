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
local currentMacroState = {}
local itemCache = {} 
local scanLines = {} 

local function InitVars()
    if not CC_IgnoreList then CC_IgnoreList = {} end
    if not CC_Settings then CC_Settings = { UseBuffFood = false } end
    if not CC_Settings.Minimap then CC_Settings.Minimap = {} end

    -- [[ NEW: Spell Name Caching ]] --
    ns.SpellCache = {}
    if ns.ConjureSpells then
        for _, spellList in pairs(ns.ConjureSpells) do
            for _, data in ipairs(spellList) do
                local id = data[1]
                local name = GetSpellInfo(id) --
                if name then
                    ns.SpellCache[id] = name
                end
            end
        end
    end

    local LDBIcon = LibStub("LibDBIcon-1.0", true)
    if LDBIcon and ns.LDBObj and not ns.IconRegistered then 
        LDBIcon:Register("Connoisseur", ns.LDBObj, CC_Settings.Minimap)
        ns.IconRegistered = true
    end

    wipe(itemCache)

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
    ns.UpdateMacros(true)
end

-- [[ HELPER FUNCTIONS ]] --

local function ParseNumber(text)
    if not text then return 0 end
    local match = text:match("([%d,]+)")
    if not match then return 0 end
    return tonumber((string.gsub(match, ",", ""))) or 0
end

local function PlayerHasBuff(buffName)
    if not buffName then return false end
    for i = 1, 40 do
        local name = UnitAura("player", i, "HELPFUL")
        if not name then return false end
        if name == buffName then return true end
    end
    return false
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
            local name = ns.SpellCache[id] 
            if name then
                if rankNum then 
                    return name .. "(" .. L["RANK"] .. " " .. rankNum .. ")", id --
                end
                return name, id
            end
        end
    end
    return nil, 0
end

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
local function ScanBagItem(bag, slot)
    local info = C_Container.GetContainerItemInfo(bag, slot)
    if not info or not info.itemID then return nil end
    local itemID = info.itemID

    if CC_IgnoreList[itemID] or ns.Excludes[itemID] then return nil end

    local _, _, _, _, _, classID = GetItemInfoInstant(itemID)
    if classID ~= 0 then return nil end

    local staticData = itemCache[itemID]
    if not staticData then
        local name, _, _, _, _, _, subType, _, _, _, iPrice = GetItemInfo(itemID)
        if not name then return nil end 

        scannerTooltip:ClearLines()
        scannerTooltip:SetHyperlink(info.hyperlink)
        if scannerTooltip:NumLines() == 0 then return nil end

        staticData = {
            id = itemID, valHealth = 0, valMana = 0, reqLvl = 0, reqFA = 0, price = iPrice or 0,
            isFood = false, isWater = false, isBandage = false, 
            isPotion = false, isHealthstone = false, isBuffFood = false, isPercent = false
        }

        local foundSeated = false
        local isStrictHealth, isStrictMana = false, false

        for i = 1, scannerTooltip:NumLines() do
            local line = _G["CC_ScannerTooltipTextLeft"..i]
            local text = line and line:GetText() and line:GetText():lower()
            if text then
                if text:find(L["SCAN_ALCOHOL"]) then 
                    itemCache[itemID] = "IGNORE"
                    return nil 
                end

                local lvl = text:match(L["SCAN_REQ_LEVEL"])
                if lvl then staticData.reqLvl = tonumber(lvl) end

                local fa = text:match(L["SCAN_REQ_FA"])
                if fa then staticData.reqFA = tonumber(fa) end

                if text:find(L["SCAN_SEATED"]) then foundSeated = true end
                if text:find(L["SCAN_WELL_FED"]) then staticData.isBuffFood = true end
                
                if not isStrictHealth and not isStrictMana then
                    local hMin = text:match(L["SCAN_HPOT_STRICT"])
                    if hMin then
                        staticData.valHealth = ParseNumber(hMin)
                        isStrictHealth = true
                        staticData.isPotion = true
                    end

                    local mMin = text:match(L["SCAN_MPOT_STRICT"])
                    if mMin and not text:find(L["SCAN_HYBRID"]) then
                        staticData.valMana = ParseNumber(mMin)
                        isStrictMana = true
                        staticData.isPotion = true
                    end
                end

                if not isStrictHealth and not isStrictMana then
                    local pVal = ParseNumber(text:match(L["SCAN_PERCENT"]))
                    if pVal > 0 then
                        staticData.isPercent = true
                        if text:find(L["SCAN_MANA"]) then staticData.valMana = 999999 end
                        if text:find(L["SCAN_HEALTH"]) or (not text:find(L["SCAN_MANA"])) then staticData.valHealth = 999999 end
                    else
                        local rVal = ParseNumber(text:match(L["SCAN_RESTORES"]))
                        local hVal = ParseNumber(text:match(L["SCAN_HEALS"]))
                        if rVal > 0 or hVal > 0 then
                            local val = (rVal > hVal) and rVal or hVal
                            if text:find(L["SCAN_MANA"]) then staticData.valMana = val end
                            if text:find(L["SCAN_HEALTH"]) or text:find(L["SCAN_HEALS"]) then staticData.valHealth = val end
                        end
                    end
                end
            end
        end

        local nameLower = name:lower()
        if foundSeated then
            if staticData.valMana > 0 then staticData.isWater = true end
            if staticData.valHealth > 0 then staticData.isFood = true end
            if not staticData.isWater and not staticData.isFood then staticData.isFood = true end
        elseif (subType == "Bandage" or nameLower:find("bandage")) and staticData.valHealth > 0 then
            staticData.isBandage = true
        elseif nameLower:find("healthstone") and staticData.valHealth > 0 then
            staticData.isHealthstone = true
        end
        itemCache[itemID] = staticData
    end

    if staticData == "IGNORE" then return nil end
    
    if staticData.reqLvl > UnitLevel("player") then return nil end
    
    if staticData.isBandage and staticData.reqFA > 0 then
        local hasSkill = false
        for i = 1, GetNumSkillLines() do
            local name, _, _, rank = GetSkillLineInfo(i)
            if name == GetSpellInfo(129) then
                if rank >= staticData.reqFA then hasSkill = true end
                break
            end
        end
        if not hasSkill then return nil end
    end

    if not IsInAllowedZone(itemID) then return nil end

    return {
        id = staticData.id, valHealth = staticData.valHealth, valMana = staticData.valMana,
        price = staticData.price, isFood = staticData.isFood, isWater = staticData.isWater,
        isBandage = staticData.isBandage, isPotion = staticData.isPotion,
        isHealthstone = staticData.isHealthstone, isBuffFood = staticData.isBuffFood,
        isPercent = staticData.isPercent, bag = bag, slot = slot, stack = info.stackCount, link = info.hyperlink
    }
end

local function IsBetter(item, best)
    if not best then return true end
    if ns.AllowBuffFood then
        if item.isBuffFood ~= best.isBuffFood then return item.isBuffFood end
    end
    if item.isPercent ~= best.isPercent then return item.isPercent end
    local iVal, bVal = item.valHealth + item.valMana, best.valHealth + best.valMana
    if iVal ~= bVal then return iVal > bVal end
    if item.price ~= best.price then return item.price < best.price end
    local iHyb = (item.valHealth > 0 and item.valMana > 0)
    local bHyb = (best.valHealth > 0 and best.valMana > 0)
    if iHyb ~= bHyb then return iHyb end
    return item.stack < best.stack
end

-- [[ MACRO MANAGEMENT ]] --

function ns.UpdateMacros(forced)
    if InCombatLockdown() then return end
    
    local wellFedName = GetSpellInfo(19705)
    local hasWellFed = wellFedName and PlayerHasBuff(wellFedName)
    ns.AllowBuffFood = CC_Settings.UseBuffFood and not hasWellFed

    local best = { ["Food"] = nil, ["Water"] = nil, ["Health Potion"] = nil, ["Mana Potion"] = nil, ["Healthstone"] = nil, ["Bandage"] = nil }
    
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local item = ScanBagItem(bag, slot)
            if item then
                local skipBuffFood = false
                if item.isBuffFood and not ns.AllowBuffFood then skipBuffFood = true end

                if item.isBandage then
                    if IsBetter(item, best["Bandage"]) then best["Bandage"] = item end
                elseif item.isHealthstone then
                    if IsBetter(item, best["Healthstone"]) then best["Healthstone"] = item end
                elseif item.isPotion then
                    if item.valHealth > 0 and IsBetter(item, best["Health Potion"]) then best["Health Potion"] = item end
                    if item.valMana > 0 and IsBetter(item, best["Mana Potion"]) then best["Mana Potion"] = item end
                elseif item.isFood then
                    if not skipBuffFood then
                        if IsBetter(item, best["Food"]) then best["Food"] = item end
                    end
                elseif item.isWater then
                    if not skipBuffFood then
                        if IsBetter(item, best["Water"]) then best["Water"] = item end
                    end
                end
            end
        end
    end

    ns.BestFoodID = best["Food"] and best["Food"].id or nil
    ns.BestFoodLink = best["Food"] and best["Food"].link or nil

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

    if ns.UpdateLDB then
        ns.UpdateLDB()
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

frame:SetScript("OnUpdate", function(self, elapsed)
    if updateQueued then
        updateTimer = updateTimer + elapsed
        if updateTimer > 0.1 then 
            ns.UpdateMacros()
            updateQueued, updateTimer = false, 0
        end
    end
end)

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == "Consumable-Connoisseur" then
        InitVars()
        frame:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_ENTERING_WORLD" then
        InitVars()
        C_Timer.After(5, function() QueueUpdate() end)
    elseif event == "BAG_UPDATE" or event == "BAG_UPDATE_DELAYED" then
        QueueUpdate()
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, _, spellID = ...
        if unit == "player" then
            if ns.SpellCache and ns.SpellCache[spellID] then
                QueueUpdate()
            end
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
        QueueUpdate()
    elseif event == "UNIT_AURA" or event == "GET_ITEM_INFO_RECEIVED" or event == "PLAYER_TARGET_CHANGED" then
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
                print(C.INFO..L["BRAND"]..C.MUTED.." // "..C.TEXT..
                    string.format(L["MSG_BUG_REPORT"], link, itemID, zone, subzone, mapID))
                CC_LastTime = 0
            end
        end
    end
end)

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("BAG_UPDATE")
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
