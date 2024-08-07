local addonName, _A = ...
local _G = _A._G
local Version = 1.0

local settings = {
    holyShockHP = 50,          -- เปอร์เซ็นต์ HP ที่จะใช้ Holy Shock
    cleanseDebuffHP = 30,      -- เปอร์เซ็นต์ HP ที่จะใช้ Cleanse
    defensiveCooldownHP = 30, -- เปอร์เซ็นต์ HP ที่จะใช้ Defensive Cooldowns
    interruptThreshold = 70,   -- เปอร์เซ็นต์ HP ของเป้าหมายที่ควรใช้ Interrupt
    aoeHealingRadius = 10,     -- ระยะทางสำหรับ AOE Healing
    aoeHealingHP = 70,         -- เปอร์เซ็นต์ HP ที่จะใช้ AOE Healing
}

local function castSpellIfPossible(spellName, unit)
    if _A.CanCast(spellName, unit) then
        _A.CastSpellByName(spellName, unit)
    end
end

local function updateRotation()
    local playerHP = _A.UnitHealthPercent("player")
    local targetHP = _A.UnitHealthPercent("target")

    -- ใช้ Holy Shock
    if targetHP <= settings.holyShockHP then
        castSpellIfPossible("Holy Shock", "target")
    end

    -- ใช้ Cleanse ถ้ามี Debuff
    if targetHP <= settings.cleanseDebuffHP and _A.HasDebuff("target") then
        castSpellIfPossible("Cleanse", "target")
    end

    -- ใช้ Defensive Cooldowns
    if playerHP <= settings.defensiveCooldownHP then
        castSpellIfPossible("Ardent Defender", "player")
        castSpellIfPossible("Shield of Vengeance", "player")
    end

    -- ใช้ Interrupt
    if settings.interruptThreshold and _A.IsCasting("target") then
        castSpellIfPossible("Rebuke", "target")
    end

    -- AOE Healing
    local aoeMembers = _A.GetUnitsInRange("player", settings.aoeHealingRadius)
    local lowHPMembers = 0
    for _, unit in pairs(aoeMembers) do
        if _A.UnitHealthPercent(unit) <= settings.aoeHealingHP then
            lowHPMembers = lowHPMembers + 1
        end
    end

    if lowHPMembers > 0 then
        castSpellIfPossible("Light of Dawn", "player")
    end

    -- Healing Abilities
    if targetHP <= 70 then
        castSpellIfPossible("Word of Glory", "target")
    end

    if playerHP <= 50 then
        castSpellIfPossible("Lay on Hands", "player")
    end
end

-- ตั้งค่า Timer เพื่อตรวจสอบและใช้ Rotation เป็นประจำ
_G.C_Timer.NewTicker(1, function()
    updateRotation()
end)

-- ฟังก์ชันเริ่มต้นสำหรับการโหลดการตั้งค่า
local function initializeSettings()
    -- โหลดหรือกำหนดค่าเริ่มต้นที่นี่
    _A.print("|cFF00FF00Holy Paladin Rotation Initialized|r")
end

initializeSettings()
local addonName, _A = ...
local _G = _A._G
local Version = 1.0

local settings = {
    holyShockHP = 50,          -- เปอร์เซ็นต์ HP ที่จะใช้ Holy Shock
    cleanseDebuffHP = 30,      -- เปอร์เซ็นต์ HP ที่จะใช้ Cleanse
    defensiveCooldownHP = 30, -- เปอร์เซ็นต์ HP ที่จะใช้ Defensive Cooldowns
    interruptThreshold = 70,   -- เปอร์เซ็นต์ HP ของเป้าหมายที่ควรใช้ Interrupt
    aoeHealingRadius = 10,     -- ระยะทางสำหรับ AOE Healing
    aoeHealingHP = 70,         -- เปอร์เซ็นต์ HP ที่จะใช้ AOE Healing
}

local function castSpellIfPossible(spellName, unit)
    if _A.CanCast(spellName, unit) then
        _A.CastSpellByName(spellName, unit)
    end
end

local function updateRotation()
    local playerHP = _A.UnitHealthPercent("player")
    local targetHP = _A.UnitHealthPercent("target")

    -- ใช้ Holy Shock
    if targetHP <= settings.holyShockHP then
        castSpellIfPossible("Holy Shock", "target")
    end

    -- ใช้ Cleanse ถ้ามี Debuff
    if targetHP <= settings.cleanseDebuffHP and _A.HasDebuff("target") then
        castSpellIfPossible("Cleanse", "target")
    end

    -- ใช้ Defensive Cooldowns
    if playerHP <= settings.defensiveCooldownHP then
        castSpellIfPossible("Ardent Defender", "player")
        castSpellIfPossible("Shield of Vengeance", "player")
    end

    -- ใช้ Interrupt
    if settings.interruptThreshold and _A.IsCasting("target") then
        castSpellIfPossible("Rebuke", "target")
    end

    -- AOE Healing
    local aoeMembers = _A.GetUnitsInRange("player", settings.aoeHealingRadius)
    local lowHPMembers = 0
    for _, unit in pairs(aoeMembers) do
        if _A.UnitHealthPercent(unit) <= settings.aoeHealingHP then
            lowHPMembers = lowHPMembers + 1
        end
    end

    if lowHPMembers > 0 then
        castSpellIfPossible("Light of Dawn", "player")
    end

    -- Healing Abilities
    if targetHP <= 70 then
        castSpellIfPossible("Word of Glory", "target")
    end

    if playerHP <= 50 then
        castSpellIfPossible("Lay on Hands", "player")
    end
end

-- ตั้งค่า Timer เพื่อตรวจสอบและใช้ Rotation เป็นประจำ
_G.C_Timer.NewTicker(1, function()
    updateRotation()
end)

-- ฟังก์ชันเริ่มต้นสำหรับการโหลดการตั้งค่า
local function initializeSettings()
    -- โหลดหรือกำหนดค่าเริ่มต้นที่นี่
    _A.print("|cFF00FF00Holy Paladin Rotation Initialized|r")
end

initializeSettings()
