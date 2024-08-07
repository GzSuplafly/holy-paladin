local function GetHP(unit)
    return (UnitHealth(unit) / UnitHealthMax(unit)) * 100
end

local function UseSkillIfNeeded(skill, condition)
    if condition then
        _A:UseSkill(skill)
    end
end

local function HealParty()
    for i = 1, 4 do
        local partyUnit = "party" .. i
        if UnitExists(partyUnit) and GetHP(partyUnit) < 100 then
            -- ใช้สกิล Holy Shock หรือ Flash of Light ตามความเหมาะสม
            if GetHP(partyUnit) < DM_Settings.FlashOfLightHP then
                UseSkillIfNeeded("Flash of Light", true)
            elseif GetHP(partyUnit) < DM_Settings.HolyShockHP then
                UseSkillIfNeeded("Holy Shock", true)
            end
        end
    end
end

local function Rotation()
    local hp = GetHP("player")
    
    -- ใช้สกิล Holy Shock ถ้า HP น้อยกว่า 50%
    UseSkillIfNeeded("Holy Shock", hp < DM_Settings.HolyShockHP)

    -- ใช้สกิล Flash of Light ถ้า HP น้อยกว่า 30%
    UseSkillIfNeeded("Flash of Light", hp < DM_Settings.FlashOfLightHP)

    -- ใช้สกิล Light of Dawn ถ้ามีมากกว่าสี่เป้าหมายที่มี HP ต่ำกว่า 50%
    if _A:GetCountLowHealthTargets(50) >= 4 then
        _A:UseSkill("Light of Dawn")
    end

    -- ใช้สกิล Beacon of Light ถ้าไม่มีกำลังบัพนี้
    if not _A:HasBuff("Beacon of Light") then
        _A:UseSkill("Beacon of Light")
    end

    -- ฮิลให้กับสมาชิกในปาร์ตี้เมื่ออยู่นอกการต่อสู้
    if not UnitAffectingCombat("player") then
        HealParty()
    end
end

-- การทำงานหลัก
local function OnUpdate()
    Rotation()
end

-- ตั้งค่าการทำงานทุกๆ 0.5 วินาที
local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function(self, elapsed)
    self.time = (self.time or 0) + elapsed
    if self.time >= 0.5 then
        OnUpdate()
        self.time = 0
    end
end)
