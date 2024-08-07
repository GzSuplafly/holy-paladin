local addonName, _A = ...

local GUI = {
    {
        key = 'autoDisease',
        name = 'AUTO DISPEL DISEASE/TOXIN IN PARTY',
        text = 'Dispel specific diseases/toxins in Dragonflight dungeons',
        icon = 'Interface\\Icons\\Spell_holy_renew.png'
    },
    {
        key = 'autoHeal',
        name = 'AUTO HEAL LOW HP IN PARTY',
        text = 'Automatically heal party members with low HP',
        icon = 'Interface\\Icons\\Spell_holy_holyshock.png'
    },
    {
        key = 'autoCooldowns',
        name = 'AUTO USE COOLDOWNS',
        text = 'Automatically use cooldowns like Divine Shield and Avenging Wrath',
        icon = 'Interface\\Icons\\Spell_holy_divineprotection.png'
    },
    {
        key = 'healFlashOfLight',
        name = 'AUTO USE FLASH OF LIGHT',
        text = 'Automatically use Flash of Light to heal yourself or party members',
        icon = 'Interface\\Icons\\Spell_holy_flashheal.png'
    },
    {
        key = 'healHolyLight',
        name = 'AUTO USE HOLY LIGHT',
        text = 'Automatically use Holy Light to heal yourself or party members',
        icon = 'Interface\\Icons\\Spell_holy_holyfire.png'
    },
    {
        key = 'healHolyShock',
        name = 'AUTO USE HOLY SHOCK',
        text = 'Automatically use Holy Shock to heal yourself or party members',
        icon = 'Interface\\Icons\\Spell_holy_holyshock.png'
    },
    {
        key = 'healWordOfGlory',
        name = 'AUTO USE WORD OF GLORY',
        text = 'Automatically use Word of Glory to heal yourself or party members',
        icon = 'Interface\\Icons\\Spell_holy_wordofglory.png'
    }
}

local exeOnLoad = function()
    _A.Interface:ShowToggle("cooldowns", false)
    _A.Interface:ShowToggle("interrupts", false)
    _A.Interface:ShowToggle("aoe", false)

    -- Add GUI settings
    for _, setting in ipairs(GUI) do
        _A.Interface:AddToggle(setting)
    end
end

local exeOnUnload = function()
    -- Cleanup or unload settings if needed
end

local inCombat = function()
    local player = Object("player")
    if not player then return end
    local target = Object("target")
    local lowest = Object("lowest")

    -- Pause if CC locked
    if player:State("stun || fear || sleep || disorient || incapacitate") then
        return 
    end

    -- Pause if keybind is pressed
    if player:keybind("lalt") then
        return
    end

    -- Cancel protection if mounted
    if IsMounted() then
        return
    end

    -- Lay on Hands
    if player:CanCast("Lay on Hands") and player:health() < 20 and not player:debuff("Forbearance") then
        return player:Cast("Lay on Hands")
    end

    if player:CanCast("Lay on Hands") and lowest and lowest:health() < 40 and lowest:distance() < 35 and lowest:los() and player:health() > 70 and not lowest:debuff("Forbearance") then
        return lowest:Cast("Lay on Hands")
    end

    -- Auto Dispel in Dungeon
    if IsInGroup() and IsInInstance() then
        if player:toggle('autoDisease') and player:CanCast("Cleanse Toxins") and player:mana() > 11 then
            if player:debuffCountAny("Creeping Mold") > 2 then
                return player:Cast("Cleanse Toxins")
            end

            if lowest and lowest:los() and IsSpellInRange("Flash of Light", lowest.key) == 1 then
                if lowest:debuffCountAny("Decaying Spores") > 2 then
                    return lowest:Cast("Cleanse Toxins")
                end
            end
        end
    end

    -- Use Cooldowns
    if player:toggle('autoCooldowns') then
        if player:CanCast("Avenging Wrath") and player:health() > 50 then
            return player:Cast("Avenging Wrath")
        end

        if player:CanCast("Divine Shield") and player:health() < 30 then
            return player:Cast("Divine Shield")
        end
    end

    -- Healing
    if player:toggle('healFlashOfLight') and player:CanCast("Flash of Light") then
        if player:health() < 80 then
            return player:Cast("Flash of Light")
        end

        if lowest and lowest:health() < 80 and lowest:distance() < 35 and lowest:los() then
            return lowest:Cast("Flash of Light")
        end
    end

    if player:toggle('healHolyLight') and player:CanCast("Holy Light") then
        if player:health() < 80 then
            return player:Cast("Holy Light")
        end

        if lowest and lowest:health() < 80 and lowest:distance() < 35 and lowest:los() then
            return lowest:Cast("Holy Light")
        end
    end

    if player:toggle('healHolyShock') and player:CanCast("Holy Shock") then
        if player:health() < 60 then
            return player:Cast("Holy Shock")
        end

        if lowest and lowest:health() < 60 and lowest:distance() < 35 and lowest:los() then
            return lowest:Cast("Holy Shock")
        end
    end

    if player:toggle('healWordOfGlory') and player:CanCast("Word of Glory") then
        local hpToHeal = player:health() < 50 and 50 or 80  -- Adjust the HP threshold as needed
        if player:holyPower() >= 3 and player:health() < hpToHeal then
            return player:Cast("Word of Glory")
        end

        if lowest and lowest:holyPower() >= 3 and lowest:health() < hpToHeal and lowest:distance() < 35 and lowest:los() then
            return lowest:Cast("Word of Glory")
        end
    end

    -- Interrupt
    if target and player:CanCast("Rebuke") and target:enemy() and IsSpellInRange("Rebuke", target) == 1 and target:combat() and target:alive() and target:infront() and target:interruptAt(40) then
        return target:Cast("Rebuke")
    end

    -- DPS on target
    if target and target:enemy() and target:alive() and target:infront() then
        if IsSpellInRange("Rebuke", target) == 1 and not player:AutoAttack() then
            _A.AttackTarget()
        end

        if player:CanCast("Shield of the Righteous") and IsSpellInRange("Rebuke", target) == 1 and player:buff("Divine Purpose") then
            return target:Cast("Shield of the Righteous")
        end

        if player:CanCast("Judgment") and IsSpellInRange("Avenger's Shield", target) == 1 then
            return target:Cast("Judgment")
        end

        if player:CanCast("Hammer of the Righteous") and IsSpellInRange("Rebuke", target) == 1 then
            return target:Cast("Hammer of the Righteous")
        end
    end
end

local outCombat = function()
    local player = Object("player")
    if not player then return end
    local lowest = Object("lowest")

    if not IsInInstance() then
        if player:CanCast("Cleanse Toxins") and player:debuff(391404) then
            return player:Cast("Cleanse Toxins")
        end
    end

    if player:keybind("lalt") then
        return
    end

    if IsMounted() or IsBagOpen(0) or IsBagOpen(-1) then
        return
    end

    if _A.ArkInventory then
        if _A.ArkInventory.Frame_Main_Get(_A.ArkInventory.Const.Location.Bag):IsVisible() then
            return
        end
    end

    if _A.Bagnon then
        if _A.Bagnon.Frames:IsShown('inventory') then
            return
        end
    end

    -- Flash of Light Heal out of combat
    if player:toggle('healFlashOfLight') and player:CanCast("Flash of Light") and player:mana() > 11 and not player:moving() then
        if player:health() < 80 then
            return player:Cast("Flash of Light")
        end

        if lowest and lowest:health() < 80 and lowest:distance() < 35 and lowest:los() then
            return lowest:Cast("Flash of Light")
        end
    end
end

local eventHandler = CreateFrame("Frame")
eventHandler:RegisterEvent("PLAYER_LOGIN")
eventHandler:RegisterEvent("PLAYER_REGEN_ENABLED")
eventHandler:RegisterEvent("PLAYER_REGEN_DISABLED")
eventHandler:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        exeOnLoad()
    elseif event == "PLAYER_REGEN_ENABLED" then
        outCombat()
    elseif event == "PLAYER_REGEN_DISABLED" then
        inCombat()
    end
end)
