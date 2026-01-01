local addonName, ns = ...
local frame = CreateFrame("Frame")

-- MAPPING: Defines logic and FALLBACK icons (for when you have 0 items)
local categories = {
    ["- Food"] = { 
        type = "db", 
        key = "h", 
        fallback = 5349 -- Conjured Muffin
    },
    ["- Water"] = { 
        type = "db", 
        key = "m", 
        fallback = 5350 -- Conjured Water
    },
    ["- Health Potion"] = { type = "static", key = "- Health Potion" },
    ["- Mana Potion"] = { type = "static", key = "- Mana Potion" },
    ["- Healthstone"] = { type = "static", key = "- Healthstone" },
    ["- Bandage"] = { type = "static", key = "- Bandage" },
}

-- Branding Colors
local BRAND_COLOR = "|cff00BBFF" -- Cyan #00BBFF
local SEP_COLOR   = "|cffAAAAAA" -- Grey #AAAAAA
local TEXT_COLOR  = "|cffffffff" -- White #FFFFFF

-- State Variables
local hasPrintedLimitError = false

----------------------------------------------------------------------
-- Optimized Compatibility Layer (Retail / Classic Era / TBC)
----------------------------------------------------------------------
local GetBagNumSlots
local GetBagItemData

if C_Container and C_Container.GetContainerNumSlots then
    -- Modern API (Classic Era 1.15+)
    GetBagNumSlots = C_Container.GetContainerNumSlots
    GetBagItemData = function(bag, slot)
        local info = C_Container.GetContainerItemInfo(bag, slot)
        if info then
            return info.itemID, info.stackCount
        end
        return nil, 0
    end
else
    -- Legacy API (TBC 2.5 / Older Clients)
    GetBagNumSlots = GetContainerNumSlots
    GetBagItemData = function(bag, slot)
        local itemID = GetContainerItemID(bag, slot)
        local _, count = GetContainerItemInfo(bag, slot)
        return itemID, count
    end
end

-- Tooltip for scanning item requirements (Hidden)
local scanTooltip = CreateFrame("GameTooltip", "CCScannerTooltip", nil, "GameTooltipTemplate")
scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

local function IsItemUseful(itemID, playerLevel)
    if not itemID then return false end
    
    -- 1. Basic Usable Check (Class/Race)
    local isUsable, _ = IsUsableItem(itemID)
    if not isUsable then return false end

    -- 2. Level Requirement Check
    local _, _, _, _, itemMinLevel = GetItemInfo(itemID)
    if not itemMinLevel then return true end -- Assume usable if cache missing
    if playerLevel < itemMinLevel then return false end

    -- 3. Profession/Skill Requirement Check (via Tooltip)
    scanTooltip:ClearLines()
    scanTooltip:SetHyperlink("item:"..itemID)
    
    -- Scan lines 2 through 5 (usually where requirements are)
    for i = 2, scanTooltip:NumLines() do
        local line = _G["CCScannerTooltipTextLeft"..i]
        if line then
            local text = line:GetText()
            if text then
                -- Red text indicates an unmet requirement
                local r, g, b = line:GetTextColor()
                -- Check for red color (approximate, usually close to 1, 0.1, 0.1)
                if r > 0.9 and g < 0.2 and b < 0.2 then
                    return false
                end
            end
        end
    end
    
    return true
end

----------------------------------------------------------------------
-- Logic: Database Items (Food / Water)
----------------------------------------------------------------------
local function GetBestDatabaseItem(statKey)
    local candidates = {}
    local playerLevel = UnitLevel("player")
    local db = ns.FoodWaterDB

    for bag = 0, 4 do
        local numSlots = GetBagNumSlots(bag)
        for slot = 1, numSlots do
            local itemID, count = GetBagItemData(bag, slot)
            if itemID and db[itemID] then
                local info = db[itemID]
                -- Check if it restores the specific stat (Health vs Mana)
                if info[statKey] and info[statKey] > 0 then
                    if IsItemUseful(itemID, playerLevel) then
                        table.insert(candidates, {
                            bag = bag,
                            slot = slot,
                            id = itemID,
                            val = info[statKey],
                            totalStats = (info.h or 0) + (info.m or 0), -- Hybrid Power (Biscuits > Croissants)
                            price = info.v,
                            count = count
                        })
                    end
                end
            end
        end
    end

    if #candidates == 0 then return nil end

    -- Sort Priority: 
    -- 1. Highest Primary Restore (Health for Food)
    -- 2. Highest Total Stats (Tie-breaker for Hybrid items)
    -- 3. Lowest Vendor Price (Cheap/Conjured first)
    -- 4. Lowest Stack Size (Cleanup bags)
    table.sort(candidates, function(a, b)
        if a.val ~= b.val then return a.val > b.val end
        if a.totalStats ~= b.totalStats then return a.totalStats > b.totalStats end
        if a.price ~= b.price then return a.price < b.price end
        return a.count < b.count
    end)

    return candidates[1]
end

----------------------------------------------------------------------
-- Logic: Static Lists (Potions / Bandages)
----------------------------------------------------------------------
local function GetBestPriorityItem(listKey)
    local idList = ns.PriorityLists[listKey]
    if not idList then return nil end

    local playerLevel = UnitLevel("player")

    -- Iterate purely by order in the list (Top = Best)
    for _, targetID in ipairs(idList) do
        for bag = 0, 4 do
            local numSlots = GetBagNumSlots(bag)
            for slot = 1, numSlots do
                local itemID = GetBagItemData(bag, slot)
                if itemID == targetID then
                    if IsItemUseful(itemID, playerLevel) then
                        return { bag = bag, slot = slot, id = itemID }
                    end
                end
            end
        end
    end
    return nil
end

----------------------------------------------------------------------
-- Macro Updates
----------------------------------------------------------------------
local updateFrame = CreateFrame("Frame")
updateFrame:Hide()

local function UpdateMacros()
    if InCombatLockdown() then return end

    local numAccount, numChar = GetNumMacros()
    local limitAccount = MAX_ACCOUNT_MACROS or 120
    local limitChar = MAX_CHARACTER_MACROS or 18

    for macroName, config in pairs(categories) do
        local bestItem = nil

        if config.type == "db" then
            bestItem = GetBestDatabaseItem(config.key)
        elseif config.type == "static" then
            bestItem = GetBestPriorityItem(config.key)
        end

        local newBody = ""
        local icon = "INV_Misc_QuestionMark" 

        if bestItem then
            -- Item Found: Point directly to Bag/Slot
            newBody = "#showtooltip item:" .. bestItem.id .. "\n/use " .. bestItem.bag .. " " .. bestItem.slot
        else
            -- No Item Found: Fallback Icon + Error Message
            local fallbackID = 0
            
            if config.fallback then
                fallbackID = config.fallback
            elseif config.type == "static" and ns.PriorityLists[config.key] then
                local list = ns.PriorityLists[config.key]
                fallbackID = list[#list]
            end

            local typeName = macroName:gsub("^- ", "")
            local errorMsg = BRAND_COLOR .. "Consumable Connoisseur|r " .. 
                             SEP_COLOR .. "//|r " .. 
                             TEXT_COLOR .. "No suitable " .. typeName .. " was found in your bags.|r"

            if fallbackID and fallbackID > 0 then
                newBody = "#showtooltip item:" .. fallbackID .. "\n/run print('" .. errorMsg .. "')"
            else
                newBody = "#showtooltip INV_Misc_QuestionMark\n/run print('" .. errorMsg .. "')"
            end
        end

        local macId = GetMacroIndexByName(macroName)

        if macId == 0 then
            -- Create Macro
            if numChar < limitChar then
                CreateMacro(macroName, icon, newBody, 1) -- Character
                numChar = numChar + 1
            elseif numAccount < limitAccount then
                CreateMacro(macroName, icon, newBody, nil) -- Account
                numAccount = numAccount + 1
            else
                if not hasPrintedLimitError then
                    print(BRAND_COLOR .. "Consumable Connoisseur|r " .. SEP_COLOR .. "//|r " .. TEXT_COLOR .. "Error: Macro limit reached. Could not create '" .. macroName .. "'.|r")
                    hasPrintedLimitError = true
                end
            end
        else
            -- Update Macro
            -- Fix: Use GetMacroInfo instead of GetMacroBody for better Classic compatibility
            local _, _, currentBody = GetMacroInfo(macId)
            if currentBody ~= newBody then
                EditMacro(macId, macroName, icon, newBody)
            end
        end
    end

    updateFrame:Hide()
end

local THROTTLE_TIME = 0.5
local timeSinceLast = 0

updateFrame:SetScript("OnUpdate", function(self, elapsed)
    timeSinceLast = timeSinceLast + elapsed
    if timeSinceLast >= THROTTLE_TIME then
        if InCombatLockdown() then
            self:Hide()
            timeSinceLast = 0
            return
        end
        
        UpdateMacros()
        timeSinceLast = 0
    end
end)

local function RequestUpdate()
    if InCombatLockdown() then return else updateFrame:Show() end
end

----------------------------------------------------------------------
-- Events
----------------------------------------------------------------------

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_REGEN_ENABLED" then
        UpdateMacros()
    else
        RequestUpdate()
    end
end)

-- Core Events
frame:RegisterEvent("PLAYER_REGEN_ENABLED")   -- Combat end
frame:RegisterEvent("BAG_UPDATE_DELAYED")     -- Inventory change
frame:RegisterEvent("GET_ITEM_INFO_RECEIVED") -- Item data loaded

-- State Change Events (Unlock items)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")  -- Login/Zone in
frame:RegisterEvent("PLAYER_LEVEL_UP")        -- Level requirement check
frame:RegisterEvent("SKILL_LINES_CHANGED")    -- Profession requirement check (First Aid)
frame:RegisterEvent("ZONE_CHANGED")           -- BG Zone Check
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")  -- BG Zone Check
