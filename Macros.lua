local _, ns = ...
local L = ns.L
local C = ns.Colors
local Config = ns.Config

local currentMacroState = {}

local function GetSmartSpell(spellList)
    if not spellList then
        return nil, 0
    end
    local levelCap = UnitLevel("player")

    if UnitExists("target") and UnitIsFriend("player", "target") and UnitIsPlayer("target") then
        local tLvl = UnitLevel("target")
        if tLvl > 0 then
            levelCap = tLvl
        end
    end

    for _, data in ipairs(spellList) do
        local id, req, rankNum = data[1], data[2], data[3]
        local known = IsSpellKnown(id)
        if not known and IsPlayerSpell then
            known = IsPlayerSpell(id)
        end

        if known and req <= levelCap then
            local name = GetSpellInfo(id)
            if name then
                if name:find("%(") then
                    return name, id
                end
                if rankNum then
                    return name .. "(" .. L["RANK"] .. " " .. rankNum .. ")", id
                end
                return name, id
            end
        end
    end
    return nil, 0
end

local function GetSpellNameWithRank(spellID, rankNum)
    local name = GetSpellInfo(spellID)
    if not name then
        return nil
    end
    if name:find("%(") then
        return name
    end
    if rankNum then
        return name .. "(" .. L["RANK"] .. " " .. rankNum .. ")"
    end
    return name
end

function ns.UpdateMacros(forced)
    if InCombatLockdown() then
        ns.RequestUpdate()
        return
    end
    if not ns.ConjureSpells then
        return
    end

    local best, dataRetry = ns.ScanBags()

    if dataRetry then
        ns.RegisterDataRetry()
    else
        ns.UnregisterDataRetry()
    end

    for typeName, cfg in pairs(Config) do
        local itemID = best[typeName].id
        local secondaryItemID
        local stateID = itemID and tostring(itemID) or "none"

        local rightSpellName, rightSpellID, midSpellName, midSpellID

        if typeName == "Water" and ns.ConjureSpells.MageWater then
            rightSpellName, rightSpellID = GetSmartSpell(ns.ConjureSpells.MageWater)
            midSpellName, midSpellID = GetSmartSpell(ns.ConjureSpells.MageTable)
        elseif typeName == "Food" and ns.ConjureSpells.MageFood then
            rightSpellName, rightSpellID = GetSmartSpell(ns.ConjureSpells.MageFood)
            midSpellName, midSpellID = GetSmartSpell(ns.ConjureSpells.MageTable)
        elseif typeName == "Healthstone" and ns.ConjureSpells.WarlockHS then
            rightSpellName, rightSpellID = GetSmartSpell(ns.ConjureSpells.WarlockHS)
            midSpellName, midSpellID = GetSmartSpell(ns.ConjureSpells.WarlockSoul)
        elseif typeName == "Mana Gem" and ns.ConjureSpells.MageGem and ns.GetKnownManaGemData then
            local bestGem, secondGem = ns.GetKnownManaGemData()
            if bestGem then
                rightSpellID = bestGem[1]
                rightSpellName = GetSpellNameWithRank(bestGem[1], bestGem[3])
            end
            if secondGem then
                midSpellID = secondGem[1]
                midSpellName = GetSpellNameWithRank(secondGem[1], secondGem[3])
            end
            if best["Mana Gem 2"] then
                secondaryItemID = best["Mana Gem 2"].id
            end
        end

        if secondaryItemID and secondaryItemID ~= itemID then
            stateID = stateID .. "_S:" .. secondaryItemID
        end

        if rightSpellName or midSpellName then
            stateID = stateID .. "_C"
            if midSpellName then
                stateID = stateID .. "_M:" .. midSpellID
            end
            if rightSpellName then
                stateID = stateID .. "_R:" .. rightSpellID
            end
        end

        if currentMacroState[typeName] ~= stateID or forced then
            local tooltipLine, actionBlock, icon

            if itemID then
                tooltipLine = "#showtooltip item:" .. itemID .. "\n"
                local useLines = "/use item:" .. itemID
                if typeName == "Mana Gem" and secondaryItemID and secondaryItemID ~= itemID then
                    useLines = useLines .. "\n/use item:" .. secondaryItemID
                end
                actionBlock = "/run CC_LastID=" .. itemID .. ";CC_LastTime=GetTime()\n" .. useLines
                icon = GetItemIcon(itemID)
            else
                local msg = string.format(L["MSG_NO_ITEM"], typeName)
                tooltipLine = "#showtooltip item:" .. cfg.defaultID .. "\n"
                actionBlock = string.format("/run print('%s%s%s // %s%s')", C.INFO, L["BRAND"], C.MUTED, C.TEXT, msg)
                icon = GetItemIcon(cfg.defaultID)
            end

            local conjureBlock = ""
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
                end
            end

            local body = tooltipLine .. conjureBlock .. actionBlock

            local index = GetMacroIndexByName(cfg.macro)
            if index == 0 then
                CreateMacro(cfg.macro, icon, body, 1)
            else
                EditMacro(index, cfg.macro, icon, body)
            end
            currentMacroState[typeName] = stateID
        end
    end

    if forced then
        wipe(currentMacroState)
    end
    if ns.UpdateLDB then
        ns.UpdateLDB()
    end
end

function ns.ResetMacroState()
    wipe(currentMacroState)
end