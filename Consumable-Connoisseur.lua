local addonName, addon = ...
local frame = CreateFrame("Frame")

----------------------------------------------------------------------
-- Consumable Items
----------------------------------------------------------------------

local itemCategories = {
    -- Only including food sold by Inn Keepers for now.
    -- Inn Keepers
    -- https://www.wowhead.com/tbc/npc=16618/innkeeper-velandra
    -- https://www.wowhead.com/tbc/npc=16739/caregiver-breel
    -- https://www.wowhead.com/tbc/npc=17630/innkeeper-jovia
    -- https://www.wowhead.com/tbc/npc=19232/innkeeper-haelthol
    -- https://www.wowhead.com/tbc/npc=5111/innkeeper-firebrew
    -- https://www.wowhead.com/tbc/npc=6736/innkeeper-keldamyr
    -- https://www.wowhead.com/tbc/npc=6740/innkeeper-allison
    -- https://www.wowhead.com/tbc/npc=6741/innkeeper-norman
    -- https://www.wowhead.com/tbc/npc=6746/innkeeper-pala
    -- https://www.wowhead.com/tbc/npc=6929/innkeeper-gryshka

    ["- Food"] = {
        34062, -- (7500+) Conjured Manna Biscuit
        22019, -- (7500) Conjured Croissant
        22895, -- (4320) Conjured Cinnamon Roll
        27859, -- (4320) Mag'har Grainbread
        27855, -- (4320) Telaari Grapes
        27854, -- (4320) Smoked Talbuk Venison
        8076, -- (2148) Conjured Sweet Roll
        27858, -- (2148) Crusty Flatbread
        27857, -- (2148) Skethyl Berries
        8952, -- (2148) Roasted Quail
        8075, -- (1392) Conjured Sourdough
        8950, -- (1344) Homemade Cherry Pie
        8953, -- (1344) Deep Fried Plantains
        4599, -- (1344) Cured Ham Steak
        1487, -- (874) Conjured Pumpernickel
        4601, -- (874) Soft Banana Bread
        4602, -- (874) Moon Harvest Pumpkin
        4593, -- (874) Wild Hog Shank
        1114, -- (552) Conjured Rye
        4608, -- (552) Moist Cornbread
        4544, -- (552) Shiny Red Apple
        4594, -- (552) Mutton Chop
        1113, -- (243) Conjured Bread
        4541, -- (243) Freshly Baked Bread
        4542, -- (243) Tel'Abim Banana
        2287, -- (243) Haunch of Meat
        5349, -- (61) Conjured Muffin
        4540, -- (61) Tough Hunk of Bread
        4539, -- (61) Goldenbark Apple
        117, -- (61) Tough Jerky
    },
    ["- Water"] = {
        34062, -- (7200+) Conjured Manna Biscuit
        22018, -- (7200) Conjured Glacier Water
        30703, -- (5100) Conjured Mountain Spring Water
        27860, -- (5100) Purified Draenic Water
        8079, -- (4200) Conjured Crystal Water
        28399, -- (4200) Filtered Draenic Water
        8078, -- (2934) Conjured Sparkling Water
        8766, -- (2934) Morning Glory Dew
        29395, -- (2934) Sparkling Oasis Water
        8077, -- (1992) Conjured Mineral Water
        1645, -- (1992) Moonberry Juice
        3772, -- (1345) Conjured Spring Water
        1708, -- (1344) Sweet Nectar
        2136, -- (835) Conjured Purified Water
        1205, -- (835) Melon Juice
        2288, -- (437) Conjured Fresh Water
        1179, -- (436) Ice Cold Milk
        5350, -- (151) Conjured Water
        159, -- (151) Refreshing Spring Water
    },
    ["- Health Potion"] = {
        -- https://www.wowhead.com/tbc/item=929/healing-potion#shared-cooldown;q=heal
        33092, -- (2500) Healing Potion Injector
        31838, -- (2500) Major Combat Healing Potion
        32948, -- (2500) Major Healing Draught
        32947, -- (2500) Auchenai Healing Potion
        32909, -- (2500) Crystal Healing Potion
        32904, -- (2500) Cenarion Healing Salve
        32905, -- (2500) Bottled Nethergon Vapor
        22829, -- (2500) Super Healing Potion
        17351, -- (1750) Superior Healing Draught
        18839, -- (1500) Combat Healing Potion
        13446, -- (1750) Major Healing Potion
        3928, -- (900) Superior Healing Potion
        1710, -- (585) Greater Healing Potion
        929, -- (360) Healing Potion
        858, -- (180) Lesser Healing Potion
        118, -- (90) Minor Healing Potion
    },
    ["- Mana Potion"] = {
        -- https://www.wowhead.com/tbc/item=929/healing-potion#shared-cooldown;q=mana
        33093, -- (3000) Mana Potion Injector
        32902, -- (3000) Bottled Nethergon Energy
        32903, -- (3000) Cenarion Mana Salve
        32904, -- (3000) Auchenai Mana Potion
        32905, -- (3000) Crystal Mana Potion
        22832, -- (3000) Super Mana Potion
        32948, -- (2250) Major Mana Draught
        31840, -- (2250) Major Combat Mana Potion
        32906, -- (2250) Unstable Mana Potion
        13444, -- (2250) Major Mana Potion
        18841, -- (1500) Combat Mana Potion
        17352, -- (1500) Superior Mana Draught
        13443, -- (1500) Superior Mana Potion
        6149, -- (900) Greater Mana Potion
        3827, -- (585) Mana Potion
        3385, -- (360) Lesser Mana Potion
        2455, -- (180) Minor Mana Potion
    },
    ["- Healthstone"] = {
        -- https://www.wowhead.com/tbc/item=5509/healthstone#shared-cooldown;q=healthstone
        22105, -- (2496) Master Healthstone
        22104, -- (2288) Master Healthstone
        22103, -- (2080) Master Healthstone
        19013, -- (1440) Major Healthstone
        19012, -- (1320) Major Healthstone
        9421, -- (1200) Major Healthstone
        19009, -- (960) Greater Healthstone
        19008, -- (880) Greater Healthstone
        5512, -- (800) Greater Healthstone
        19007, -- (600) Healthstone
        19006, -- (550) Healthstone
        5511, -- (500) Healthstone
        19005, -- (300) Lesser Healthstone
        19004, -- (275) Lesser Healthstone
        5510, -- (250) Lesser Healthstone
        19003, -- (120) Minor Healthstone
        19002, -- (110) Minor Healthstone
        5509, -- (100) Minor Healthstone
    },
    ["- Bandage"] = {
        -- https://www.wowhead.com/tbc/item=14530/heavy-runecloth-bandage#shared-cooldown;0-3+1-2;q=bandage
        21991, -- (2800) Heavy Netherweave Bandage
        21990, -- (2000) Netherweave Bandage
        19060, -- (2000) Alterac Heavy Runecloth Bandage
        20066, -- (2000) Arathi Basin Runecloth Bandage
        20232, -- (2000) Warsong Gulch Runecloth Bandage
        14530, -- (2000) Heavy Runecloth Bandage
        19061, -- (1360) Alterac Runecloth Bandage
        14529, -- (1360) Runecloth Bandage
        19062, -- (1104) Alterac Heavy Mageweave Bandage
        20067, -- (1104) Arathi Basin Mageweave Bandage
        20234, -- (1104) Warsong Gulch Mageweave Bandage
        8545, -- (1104) Heavy Mageweave Bandage
        19063, -- (800) Alterac Mageweave Bandage
        8544, -- (800) Mageweave Bandage
        19064, -- (640) Alterac Heavy Silk Bandage
        20068, -- (640) Arathi Basin Silk Bandage
        20236, -- (640) Warsong Gulch Silk Bandage
        6451, -- (640) Heavy Silk Bandage
        6450, -- (400) Silk Bandage
        3531, -- (301) Heavy Wool Bandage
        3530, -- (161) Wool Bandage
        2581, -- (114) Heavy Linen Bandage
        1251, -- (66) Linen Bandage
    }
}

----------------------------------------------------------------------
-- Logic
----------------------------------------------------------------------

local updateFrame = CreateFrame("Frame")
updateFrame:Hide()

local function FindBestItemInBag(idList)
    local playerLevel = UnitLevel("player")

    for _, targetID in ipairs(idList) do
        local count = GetItemCount(targetID)
        if count > 0 then

            local isUsable, _ = IsUsableItem(targetID)
            
            if isUsable then
                local _, _, _, _, itemMinLevel = GetItemInfo(targetID)
                
                if itemMinLevel then
                    if playerLevel >= itemMinLevel then
                        return targetID
                    end
                end
            end
        end
    end
    return nil
end

local function UpdateMacros()
    if InCombatLockdown() then return end

    for macroName, idList in pairs(itemCategories) do
        local bestID = FindBestItemInBag(idList)
        local newBody = ""
        local icon = "INV_Misc_QuestionMark" 

        if bestID then
            newBody = "#showtooltip item:" .. bestID .. "\n/use item:" .. bestID
        else
            local defaultID = idList[#idList] 
            newBody = "#showtooltip item:" .. defaultID .. "\n/run print('"..macroName.." not found!')"
        end

        local macId = GetMacroIndexByName(macroName)
        
        if macId == 0 then

            local numAccount, numChar = GetNumMacros()
            if numChar < 18 then
                CreateMacro(macroName, icon, newBody, 1)
            end
        else
            local _, _, currentBody = GetMacroBody(macId)
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
    if InCombatLockdown() then
        return 
    else
        updateFrame:Show()
    end
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

frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("ZONE_CHANGED")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
