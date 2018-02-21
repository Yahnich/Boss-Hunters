riki_traded_tricks = class({})
LinkLuaModifier( "modifier_traded_tricks", "heroes/hero_riki/riki_traded_tricks.lua" ,LUA_MODIFIER_MOTION_NONE )

function riki_traded_tricks:IsStealable()
    return true
end

function riki_traded_tricks:IsHiddenWhenStolen()
    return false
end

function riki_traded_tricks:GetCastRange(Location, Target)
    return self:GetTalentSpecialValueFor("range")
end

function riki_traded_tricks:OnSpellStart()
    local caster = self:GetCaster()
    EmitSoundOn("Hero_Riki.TricksOfTheTrade.Cast", caster)

    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_tricks_cast.vpcf", PATTACH_POINT, caster)
    ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(nfx)

    caster:AddNewModifier(caster, self, "modifier_traded_tricks", {Duration = self:GetSpecialValueFor("duration")})
end

modifier_traded_tricks = class({})
function modifier_traded_tricks:OnCreated(table)
    if IsServer() then
        EmitSoundOn("Hero_Riki.TricksOfTheTrade.Cast", self:GetCaster())

        self:StartIntervalThink(self:GetSpecialValueFor("interval"))
    end
end

function modifier_traded_tricks:OnIntervalThink()
    local caster = self:GetCaster()
    local radius = self:GetSpecialValueFor("radius")

    if nfx then
        ParticleManager:DestroyParticle(nfx, false)
    end

    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_tricks.vpcf", PATTACH_POINT, caster)
    ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(nfx, 1, Vector(radius, radius, radius))

    local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), {flag = self:GetAbility():GetAbilityTargetFlags()})
    for _,enemy in pairs(enemies) do
        EmitSoundOn("Hero_Riki.TricksOfTheTrade", caster)

        caster:PerformAttack(enemy, true, true, true, true, false, false, true)
    end

    Timers:CreateTimer(self:GetSpecialValueFor("interval"), function()
        ParticleManager:DestroyParticle(nfx, false)
    end)
end

function modifier_traded_tricks:OnRemoved()
    if IsServer() then
        StopSoundOn("Hero_Riki.TricksOfTheTrade.Cast", self:GetCaster())
        StopSoundOn("Hero_Riki.TricksOfTheTrade", self:GetCaster())

        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_tricks_end.vpcf", PATTACH_POINT, self:GetCaster())
        ParticleManager:SetParticleControl(nfx, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(nfx)
    end
end