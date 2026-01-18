local _, ns = ...
local L = ns.L
local C = ns.Colors
local Config = ns.Config

local frame = CreateFrame("Frame")
local isUpdatePending = false
local updateTimer = 0
local UPDATE_THROTTLE = 0.5

local lastBuffState = false

local function InitVars()
    if not CC_IgnoreList then
        CC_IgnoreList = {}
    end
    if not CC_Settings then
        CC_Settings = {UseBuffFood = false}
    end
    if not CC_Settings.Minimap then
        CC_Settings.Minimap = {}
    end

    ns.SpellCache = {}
    if ns.ConjureSpells then
        for _, spellList in pairs(ns.ConjureSpells) do
            for _, data in ipairs(spellList) do
                local id = data[1]
                local name = GetSpellInfo(id)
                if name then
                    ns.SpellCache[id] = name
                end
            end
        end
    end

    if ns.UpdateFASkill then
        ns.UpdateFASkill()
    end

    local LDBIcon = LibStub("LibDBIcon-1.0", true)
    if LDBIcon and ns.LDBObj and not ns.IconRegistered then
        LDBIcon:Register("Connoisseur", ns.LDBObj, CC_Settings.Minimap)
        ns.IconRegistered = true
    end

    if CC_Settings.UseBuffFood then
        frame:RegisterUnitEvent("UNIT_AURA", "player")

        if ns.HasWellFedBuff then
            lastBuffState = ns.HasWellFedBuff()
        end
    else
        frame:UnregisterEvent("UNIT_AURA")
    end
end

function ns.ToggleBuffFood()
    CC_Settings.UseBuffFood = not CC_Settings.UseBuffFood
    if CC_Settings.UseBuffFood then
        frame:RegisterUnitEvent("UNIT_AURA", "player")
        if ns.HasWellFedBuff then
            lastBuffState = ns.HasWellFedBuff()
        end
    else
        frame:UnregisterEvent("UNIT_AURA")
    end
    if ns.ResetMacroState then
        ns.ResetMacroState()
    end
    ns.RequestUpdate()
end

function ns.RegisterDataRetry()
    frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    C_Timer.After(
        2,
        function()
            ns.RequestUpdate()
        end
    )
end

function ns.UnregisterDataRetry()
    frame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
end

function ns.RequestUpdate()
    if not isUpdatePending then
        isUpdatePending = true
        updateTimer = 0
    end
end

frame:SetScript(
    "OnUpdate",
    function(self, elapsed)
        if isUpdatePending then
            updateTimer = updateTimer + elapsed
            if updateTimer > UPDATE_THROTTLE then
                isUpdatePending = false
                ns.UpdateMacros()
            end
        end
    end
)

frame:SetScript(
    "OnEvent",
    function(self, event, ...)
        if InCombatLockdown() then
            if event == "PLAYER_REGEN_ENABLED" then
                if isUpdatePending then
                    ns.RequestUpdate()
                end
            else
                isUpdatePending = true
            end
            return
        end

        if
            event == "BAG_UPDATE_DELAYED" or event == "PLAYER_TARGET_CHANGED" or event == "GET_ITEM_INFO_RECEIVED" or
                event == "ZONE_CHANGED_NEW_AREA" or
                event == "PLAYER_LEVEL_UP" or
                event == "PLAYER_ALIVE" or
                event == "PLAYER_UNGHOST"
         then
            ns.RequestUpdate()
        elseif event == "PLAYER_ENTERING_WORLD" then
            InitVars()
            ns.RequestUpdate()
            C_Timer.After(
                3,
                function()
                    ns.RequestUpdate()
                end
            )
        elseif event == "SKILL_LINES_CHANGED" then
            if ns.UpdateFASkill then
                ns.UpdateFASkill()
            end
            ns.RequestUpdate()
        elseif event == "UNIT_AURA" then
            if ns.HasWellFedBuff then
                local currentState = ns.HasWellFedBuff()

                if currentState ~= lastBuffState then
                    lastBuffState = currentState
                    ns.RequestUpdate()
                end
            end
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            local unit, _, spellID = ...
            if ns.SpellCache and ns.SpellCache[spellID] then
                ns.RequestUpdate()
            end
        elseif event == "UI_ERROR_MESSAGE" then
            if CC_LastTime and (GetTime() - CC_LastTime) < 1.0 then
                local messageID, msg = ...

                if msg == ERR_ITEM_WRONG_ZONE then
                    local mapID = C_Map.GetBestMapForUnit("player") or "0"
                    local zone = GetZoneText() or "?"
                    local subzone = GetSubZoneText() or ""
                    if subzone == "" then
                        subzone = zone
                    end
                    local itemID = CC_LastID or 0
                    local link = "Item #" .. itemID
                    if itemID ~= 0 then
                        local _, l = GetItemInfo(itemID)
                        if l then
                            link = l
                        end
                    end
                    print(
                        C.INFO ..
                            L["BRAND"] ..
                                C.MUTED ..
                                    " // " ..
                                        C.TEXT .. string.format(L["MSG_BUG_REPORT"], link, itemID, zone, subzone, mapID)
                    )
                    CC_LastTime = 0
                end
            end
        end
    end
)

frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:RegisterEvent("PLAYER_ALIVE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("PLAYER_UNGHOST")
frame:RegisterEvent("UI_ERROR_MESSAGE")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("SKILL_LINES_CHANGED")
frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")