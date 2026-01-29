local _, ns = ...
local L = ns.L

ns.BestFoodID = nil
ns.BestFoodLink = nil

local currentFASkill = 0

ns.RawData = ns.RawData or {}
ns.RawData.FoodAndWater = ns.RawData.FoodAndWater or {}
ns.RawData.Potions = ns.RawData.Potions or {}
ns.RawData.ManaGem = ns.RawData.ManaGem or {}
ns.RawData.Healthstone = ns.RawData.Healthstone or {}
ns.RawData.Bandage = ns.RawData.Bandage or {}

local itemCache = {}

local itemCounts = {}
local checked = {}

local best = {
    ["Food"] = {
        id = nil,
        val = 0,
        price = 0,
        isBuffFood = false,
        isPercent = false,
        isHybrid = false,
        count = 0,
        link = nil
    },
    ["Water"] = {id = nil, val = 0, price = 0, isBuffFood = false, isPercent = false, isHybrid = false, count = 0},
    ["Health Potion"] = {
        id = nil,
        val = 0,
        price = 0,
        isBuffFood = false,
        isPercent = false,
        isHybrid = false,
        count = 0
    },
    ["Mana Potion"] = {id = nil, val = 0, price = 0, isBuffFood = false, isPercent = false, isHybrid = false, count = 0},
    ["Mana Gem"] = {id = nil, val = 0, price = 0, isBuffFood = false, isPercent = false, isHybrid = false, count = 0},
    ["Mana Gem 2"] = {id = nil, val = 0, price = 0, isBuffFood = false, isPercent = false, isHybrid = false, count = 0},
    ["Healthstone"] = {id = nil, val = 0, price = 0, isBuffFood = false, isPercent = false, isHybrid = false, count = 0},
    ["Bandage"] = {id = nil, val = 0, price = 0, isBuffFood = false, isPercent = false, isHybrid = false, count = 0}
}

local function ResetBest(t)
    t.id = nil
    t.val = 0
    t.price = 0
    t.isBuffFood = false
    t.isPercent = false
    t.isHybrid = false
    t.count = 0
    t.link = nil
end

function ns.HasWellFedBuff()
    local TARGET_ICON_ID = 136000
    for i = 1, 40 do
        local name, icon, _, _, _, _, _, _, _, spellID = UnitAura("player", i, "HELPFUL")
        if not name then
            break
        end
        if icon == TARGET_ICON_ID then
            return true
        end
        if ns.WellFedBuffIDs and ns.WellFedBuffIDs[spellID] then
            return true
        end
    end
    return false
end

function ns.UpdateFASkill()
    local faName = GetSpellInfo(3273)
    if not faName then
        currentFASkill = 0
        return
    end

    for i = 1, GetNumSkillLines() do
        local skillName, isHeader, _, skillRank = GetSkillLineInfo(i)
        if not isHeader and skillName == faName then
            currentFASkill = skillRank
            return
        end
    end

    currentFASkill = 0
end

local function CacheItemData(itemID)
    local name, link, rarity, iLevel, minLevel, class, subclass, stackCount, equipLoc, icon, iPrice =
        GetItemInfo(itemID)
    if not name then
        return nil
    end

    local rawFood = ns.RawData.FoodAndWater[itemID]
    local rawPotion = ns.RawData.Potions[itemID]
    local rawGem = ns.RawData.ManaGem[itemID]
    local rawHS = ns.RawData.Healthstone[itemID]
    local rawBandage = ns.RawData.Bandage[itemID]

    if not (rawFood or rawPotion or rawGem or rawHS or rawBandage) then
        itemCache[itemID] = "IGNORE"
        return "IGNORE"
    end

    local data = {
        id = itemID,
        valHealth = 0,
        valMana = 0,
        reqLvl = minLevel or 0,
        reqFA = 0,
        price = iPrice or 0,
        isFood = false,
        isWater = false,
        isBandage = false,
        isPotion = false,
        isManaGem = false,
        isHealthstone = false,
        isBuffFood = false,
        isPercent = false,
        zones = nil
    }

    if rawFood then
        local isBuff = (rawFood[1] == 1)
        data.isBuffFood = isBuff
        data.zones = rawFood[6]
        if rawFood[2] > 0 then
            data.isFood = true
            data.valHealth = 99999
            data.isPercent = true
        elseif rawFood[3] > 0 then
            data.isFood = true
            data.valHealth = rawFood[3]
        end

        if rawFood[4] > 0 then
            data.isWater = true
            data.valMana = 99999
            data.isPercent = true
        elseif rawFood[5] > 0 then
            data.isWater = true
            data.valMana = rawFood[5]
        end

        if isBuff and not data.isFood and not data.isWater then
            data.isFood = true
        end
    elseif rawPotion then
        data.isPotion = true
        data.valHealth = rawPotion[1]
        data.valMana = rawPotion[2]
        data.zones = rawPotion[3]
    elseif rawGem then
        data.isManaGem = true
        data.valMana = rawGem[1]
    elseif rawHS then
        data.isHealthstone = true
        data.valHealth = rawHS[1]
        data.zones = rawHS[2]
    elseif rawBandage then
        data.isBandage = true
        data.valHealth = rawBandage[1]
        data.reqFA = rawBandage[2]
        data.zones = rawBandage[3]
    end

    itemCache[itemID] = data
    return data
end

local function IsBetter(itemData, itemCount, itemPrice, currentBest, score)
    if not currentBest.id then
        return true
    end

    if ns.AllowBuffFood and itemData.isBuffFood ~= currentBest.isBuffFood then
        return itemData.isBuffFood
    end
    if itemData.isPercent ~= currentBest.isPercent then
        return itemData.isPercent
    end

    local bVal = currentBest.val
    if score ~= bVal then
        return score > bVal
    end
    if itemPrice ~= currentBest.price then
        return itemPrice < currentBest.price
    end

    local iHyb = (itemData.valHealth > 0 and itemData.valMana > 0)
    if iHyb ~= currentBest.isHybrid then
        return iHyb
    end

    return itemCount < currentBest.count
end

local function IsSpellKnownSafe(spellID)
    local known = IsSpellKnown(spellID)
    if not known and IsPlayerSpell then
        known = IsPlayerSpell(spellID)
    end
    return known
end

function ns.GetKnownManaGemData()
    if not ns.ConjureSpells or not ns.ConjureSpells.MageGem then
        return nil, nil
    end

    local bestGem, secondGem
    for _, data in ipairs(ns.ConjureSpells.MageGem) do
        if IsSpellKnownSafe(data[1]) then
            if not bestGem then
                bestGem = data
            elseif not secondGem then
                secondGem = data
                break
            end
        end
    end

    return bestGem, secondGem
end

local function UpdateTopTwo(bestEntry, secondEntry, data, totalCount, score)
    if IsBetter(data, totalCount, data.price, bestEntry, score) then
        if bestEntry.id then
            secondEntry.id = bestEntry.id
            secondEntry.val = bestEntry.val
            secondEntry.price = bestEntry.price
            secondEntry.count = bestEntry.count
        end
        bestEntry.id = data.id
        bestEntry.val = score
        bestEntry.price = data.price
        bestEntry.count = totalCount
        return
    end

    if data.id ~= bestEntry.id and IsBetter(data, totalCount, data.price, secondEntry, score) then
        secondEntry.id = data.id
        secondEntry.val = score
        secondEntry.price = data.price
        secondEntry.count = totalCount
    end
end

function ns.ScanBags()
    local playerLevel = UnitLevel("player")
    local currentMap = C_Map.GetBestMapForUnit("player")
    local allowedManaGemIDs

    if ns.GetKnownManaGemData then
        local bestGem, secondGem = ns.GetKnownManaGemData()
        if bestGem and bestGem[4] then
            allowedManaGemIDs = {}
            allowedManaGemIDs[bestGem[4]] = true
            if secondGem and secondGem[4] then
                allowedManaGemIDs[secondGem[4]] = true
            end
        end
    end

    local hasWellFed = false
    if CC_Settings.UseBuffFood then
        if ns.HasWellFedBuff then
            hasWellFed = ns.HasWellFedBuff()
        end
    end
    ns.AllowBuffFood = CC_Settings.UseBuffFood and not hasWellFed

    wipe(itemCounts)
    wipe(checked)
    for _, t in pairs(best) do
        ResetBest(t)
    end

    local dataRetry = false

    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemID = C_Container.GetContainerItemID(bag, slot)
            if itemID then
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if info then
                    itemCounts[itemID] = (itemCounts[itemID] or 0) + info.stackCount
                end
            end
        end
    end

    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.itemID then
                local id = info.itemID

                if not checked[id] then
                    checked[id] = true

                    if not CC_IgnoreList[id] then
                        local data = itemCache[id]
                        if not data then
                            data = CacheItemData(id)
                        end

                        if not data then
                            dataRetry = true
                        elseif data ~= "IGNORE" then
                            local usable = true
                            if data.reqLvl > playerLevel then
                                usable = false
                            end
                            if data.reqFA > 0 and data.reqFA > currentFASkill then
                                usable = false
                            end
                            if usable and data.zones then
                                usable = false
                                if currentMap then
                                    for _, mapID in ipairs(data.zones) do
                                        if mapID == currentMap then
                                            usable = true
                                            break
                                        end
                                    end
                                end
                            end

                            if usable then
                                local totalCount = itemCounts[id]
                                if data.isBandage then
                                    if IsBetter(data, totalCount, data.price, best["Bandage"], data.valHealth) then
                                        local b = best["Bandage"]
                                        b.id = id
                                        b.val = data.valHealth
                                        b.price = data.price
                                        b.count = totalCount
                                    end
                                elseif data.isHealthstone then
                                    if IsBetter(data, totalCount, data.price, best["Healthstone"], data.valHealth) then
                                        local b = best["Healthstone"]
                                        b.id = id
                                        b.val = data.valHealth
                                        b.price = data.price
                                        b.count = totalCount
                                    end
                                elseif data.isPotion then
                                    if
                                        data.valHealth > 0 and
                                            IsBetter(
                                                data,
                                                totalCount,
                                                data.price,
                                                best["Health Potion"],
                                                data.valHealth
                                            )
                                     then
                                        local b = best["Health Potion"]
                                        b.id = id
                                        b.val = data.valHealth
                                        b.price = data.price
                                        b.count = totalCount
                                    end
                                    if
                                        data.valMana > 0 and
                                            IsBetter(data, totalCount, data.price, best["Mana Potion"], data.valMana)
                                     then
                                        local b = best["Mana Potion"]
                                        b.id = id
                                        b.val = data.valMana
                                        b.price = data.price
                                        b.count = totalCount
                                    end
                                elseif data.isManaGem then
                                    if not allowedManaGemIDs or allowedManaGemIDs[id] then
                                        UpdateTopTwo(
                                            best["Mana Gem"],
                                            best["Mana Gem 2"],
                                            data,
                                            totalCount,
                                            data.valMana
                                        )
                                    end
                                elseif data.isFood or data.isWater then
                                    if not (data.isBuffFood and not ns.AllowBuffFood) then
                                        if data.isFood then
                                            if IsBetter(data, totalCount, data.price, best["Food"], data.valHealth) then
                                                local b = best["Food"]
                                                b.id = id
                                                b.val = data.valHealth
                                                b.price = data.price
                                                b.count = totalCount
                                                b.isBuffFood = data.isBuffFood
                                                b.isPercent = data.isPercent
                                                b.link = info.hyperlink
                                                b.isHybrid = (data.valHealth > 0 and data.valMana > 0)
                                            end
                                        end
                                        if data.isWater then
                                            if IsBetter(data, totalCount, data.price, best["Water"], data.valMana) then
                                                local b = best["Water"]
                                                b.id = id
                                                b.val = data.valMana
                                                b.price = data.price
                                                b.count = totalCount
                                                b.isBuffFood = data.isBuffFood
                                                b.isPercent = data.isPercent
                                                b.isHybrid = (data.valHealth > 0 and data.valMana > 0)
                                            end
                                        end
                                    end
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
