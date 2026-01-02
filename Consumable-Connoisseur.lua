local addonName, ns = ...
local frame = CreateFrame("Frame")

--[[ CONSTANTS ]]
local BRAND_COLOR = "|cff00BBFF"
local SEP_COLOR = "|cffAAAAAA"
local TEXT_COLOR = "|cffffffff"

-- Localize for performance
local GetContainerNumSlots = C_Container.GetContainerNumSlots
local GetContainerItemInfo = C_Container.GetContainerItemInfo
local InCombatLockdown = InCombatLockdown
local GetItemInfo = GetItemInfo
local IsUsableItem = IsUsableItem

local categories = {
    ["- Food"] = {type = "db", index = 1, fallback = 5349},
    ["- Water"] = {type = "db", index = 2, fallback = 5350},
    ["- Health Potion"] = {type = "static", key = "- Health Potion"},
    ["- Mana Potion"] = {type = "static", key = "- Mana Potion"},
    ["- Healthstone"] = {type = "static", key = "- Healthstone"},
    ["- Bandage"] = {type = "static", key = "- Bandage"}
}

local usableCache = {}
local currentMacroState = {}

--[[ UTILS ]]
local function IsItemUseful(itemID, playerLevel)
    if not itemID then
        return false
    end
    if usableCache[itemID] ~= nil then
        return usableCache[itemID]
    end

    -- IsUsableItem covers Level, Class, and Profession requirements efficiently
    local isUsable, noMana = IsUsableItem(itemID)

    if not isUsable and not noMana then
        usableCache[itemID] = false
        return false
    end

    local _, _, _, _, itemMinLevel = GetItemInfo(itemID)
    if itemMinLevel and playerLevel < itemMinLevel then
        usableCache[itemID] = false
        return false
    end

    usableCache[itemID] = true
    return true
end

--[[ SCANNING ]]
local function ScanBagsForBestItems()
    local playerLevel = UnitLevel("player")
    local db = ns.FoodWaterDB

    local bestDB = {
        [1] = {val = -1, tot = -1, price = math.huge, count = math.huge},
        [2] = {val = -1, tot = -1, price = math.huge, count = math.huge}
    }

    local bestStatic = {
        ["- Health Potion"] = {rank = 999},
        ["- Mana Potion"] = {rank = 999},
        ["- Healthstone"] = {rank = 999},
        ["- Bandage"] = {rank = 999}
    }

    if not ns.StaticLookup then
        ns.StaticLookup = {}
        for key, list in pairs(ns.PriorityLists) do
            ns.StaticLookup[key] = {}
            for i, id in ipairs(list) do
                ns.StaticLookup[key][id] = i
            end
        end
    end

    for bag = 0, 4 do
        local numSlots = GetContainerNumSlots(bag)
        for slot = 1, numSlots do
            local info = GetContainerItemInfo(bag, slot)

            if info then
                local itemID = info.itemID
                local count = info.stackCount

                -- Dynamic Items (Food/Water)
                local dbInfo = db[itemID]
                if dbInfo and IsItemUseful(itemID, playerLevel) then
                    for i = 1, 2 do
                        local val = dbInfo[i] or 0
                        if val > 0 then
                            local current = bestDB[i]
                            local totalStats = (dbInfo[1] or 0) + (dbInfo[2] or 0)
                            local price = dbInfo[3] or 0

                            local isBetter = false
                            if val > current.val then
                                isBetter = true
                            elseif val == current.val then
                                if totalStats > current.tot then
                                    isBetter = true
                                elseif totalStats == current.tot then
                                    if price < current.price then
                                        isBetter = true
                                    elseif price == current.price and count < current.count then
                                        isBetter = true
                                    end
                                end
                            end

                            if isBetter then
                                current.val, current.tot, current.price, current.count = val, totalStats, price, count
                                current.bag, current.slot, current.id = bag, slot, itemID
                            end
                        end
                    end
                end

                -- Static Items (Potions/Healthstones)
                for key, lookupTable in pairs(ns.StaticLookup) do
                    local rank = lookupTable[itemID]
                    if rank and rank < bestStatic[key].rank then
                        if IsItemUseful(itemID, playerLevel) then
                            bestStatic[key].rank = rank
                            bestStatic[key].bag = bag
                            bestStatic[key].slot = slot
                            bestStatic[key].id = itemID
                        end
                    end
                end
            end
        end
    end

    return bestDB, bestStatic
end

--[[ MACRO UPDATER ]]
local updateFrame = CreateFrame("Frame")
updateFrame:Hide()

local function UpdateMacros()
    if InCombatLockdown() then
        return
    end

    local bestDB, bestStatic = ScanBagsForBestItems()

    local numAccount, numChar = GetNumMacros()
    local limitAccount = MAX_ACCOUNT_MACROS or 120
    local limitChar = MAX_CHARACTER_MACROS or 18

    for macroName, config in pairs(categories) do
        local bag, slot, id

        if config.type == "db" then
            local result = bestDB[config.index]
            if result and result.id then
                bag, slot, id = result.bag, result.slot, result.id
            end
        elseif config.type == "static" then
            local result = bestStatic[config.key]
            if result and result.id then
                bag, slot, id = result.bag, result.slot, result.id
            end
        end

        local lastState = currentMacroState[macroName]

        -- Only hit the Macro API if data changed
        if not (lastState and lastState.id == id and lastState.bag == bag and lastState.slot == slot) then
            currentMacroState[macroName] = {id = id, bag = bag, slot = slot}

            local newBody = ""
            local icon = "INV_Misc_QuestionMark"

            if id then
                newBody = "#showtooltip item:" .. id .. "\n/use " .. bag .. " " .. slot
            else
                local fallbackID = 0
                if config.fallback then
                    fallbackID = config.fallback
                elseif config.type == "static" and ns.PriorityLists[config.key] then
                    local list = ns.PriorityLists[config.key]
                    fallbackID = list[#list]
                end

                local typeName = macroName:gsub("^- ", "")
                local errorMsg =
                    BRAND_COLOR .. "CC|r " .. SEP_COLOR .. "//|r " .. TEXT_COLOR .. "No " .. typeName .. " found.|r"

                if fallbackID and fallbackID > 0 then
                    newBody = "#showtooltip item:" .. fallbackID .. "\n/run print('" .. errorMsg .. "')"
                else
                    newBody = "#showtooltip INV_Misc_QuestionMark\n/run print('" .. errorMsg .. "')"
                end
            end

            local macId = GetMacroIndexByName(macroName)
            if macId == 0 then
                if numChar < limitChar then
                    CreateMacro(macroName, icon, newBody, 1)
                    numChar = numChar + 1
                elseif numAccount < limitAccount then
                    CreateMacro(macroName, icon, newBody, nil)
                    numAccount = numAccount + 1
                end
            else
                local _, _, currentBody = GetMacroInfo(macId)
                if currentBody ~= newBody then
                    EditMacro(macId, macroName, icon, newBody)
                end
            end
        end
    end

    updateFrame:Hide()
end

--[[ EVENTS & THROTTLE ]]
local DEBOUNCE_WAIT = 1.0
local targetUpdate = 0

updateFrame:SetScript(
    "OnUpdate",
    function(self, elapsed)
        if GetTime() < targetUpdate then
            return
        end

        if InCombatLockdown() then
            self:Hide()
            frame:RegisterEvent("PLAYER_REGEN_ENABLED")
            return
        end

        self:Hide()
        UpdateMacros()
    end
)

local function RequestUpdate()
    if updateFrame:IsShown() then
        return
    end
    targetUpdate = GetTime() + DEBOUNCE_WAIT
    updateFrame:Show()
end

frame:SetScript(
    "OnEvent",
    function(self, event, ...)
        if event == "PLAYER_REGEN_ENABLED" then
            self:UnregisterEvent("PLAYER_REGEN_ENABLED")
            targetUpdate = GetTime() + 0.1
            updateFrame:Show()
        elseif event == "PLAYER_LEVEL_UP" then
            wipe(usableCache)
            RequestUpdate()
        else
            RequestUpdate()
        end
    end
)

frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
