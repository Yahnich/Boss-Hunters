abyssal_underlord_firestorm_bh = class({})
LinkLuaModifier( "modifier_abyssal_underlord_firestorm_bh", "heroes/hero_abyssal_underlord/abyssal_underlord_firestorm_bh.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_abyssal_underlord_firestorm_bh_burn", "heroes/hero_abyssal_underlord/abyssal_underlord_firestorm_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

function abyssal_underlord_firestorm_bh:IsStealable()
    return true
end

function abyssal_underlord_firestorm_bh:IsHiddenWhenStolen()
    return false
end

function abyssal_underlord_firestorm_bh:GetAOERadius()
    return self:GetTalentSpecialValueFor("radius")
end

function abyssal_underlord_firestorm_bh:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    local radius = self:GetTalentSpecialValueFor("radius")

    local nfx = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/underlord_firestorm_pre.vpcf", PATTACH_POINT, caster)
                ParticleManager:SetParticleControl(nfx, 0, point)
                ParticleManager:SetParticleControl(nfx, 1, Vector(radius, radius, 1))
                ParticleManager:ReleaseParticleIndex(nfx)

    return true
end

function abyssal_underlord_firestorm_bh:OnSpellStart()
	local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    CreateModifierThinker(caster, self, "modifier_abyssal_underlord_firestorm_bh", {Duration = self:GetTalentSpecialValueFor("wave_duration")}, point, caster:GetTeam(), false)
end

modifier_abyssal_underlord_firestorm_bh = class({})
function modifier_abyssal_underlord_firestorm_bh:OnCreated(table)
    if IsServer() then
        self:StartIntervalThink(1)
    end
end

function modifier_abyssal_underlord_firestorm_bh:OnIntervalThink()
    local caster = self:GetCaster()
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local point = parent:GetAbsOrigin()

    local damage = self:GetTalentSpecialValueFor("wave_damage")
    local radius = self:GetTalentSpecialValueFor("radius")

    local nfx = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/abyssal_underlord_firestorm_wave.vpcf", PATTACH_POINT, caster)
                ParticleManager:SetParticleControl(nfx, 0, point)
                ParticleManager:SetParticleControl(nfx, 4, Vector(radius, radius, radius))
                ParticleManager:ReleaseParticleIndex(nfx)

    local enemies = caster:FindEnemyUnitsInRadius(point, radius)
    for _,enemy in pairs(enemies) do
        enemy:AddNewModifier(caster, ability, "modifier_abyssal_underlord_firestorm_bh_burn", {Duration = self:GetTalentSpecialValueFor("burn_damage")})
        ability:DealDamage(caster, enemy, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
    end
end


modifier_abyssal_underlord_firestorm_bh_burn = class({})
function modifier_abyssal_underlord_firestorm_bh_burn:IsDebuff()
    return true
end

function modifier_abyssal_underlord_firestorm_bh_burn:OnCreated(table)
    if IsServer() then
        self:StartIntervalThink(self:GetTalentSpecialValueFor("burn_interval"))
    end
end

function modifier_abyssal_underlord_firestorm_bh_burn:OnIntervalThink()
    local caster = self:GetCaster()
    local parent = self:GetParent()
    local damage = self:GetParent():GetMaxHealth() * self:GetTalentSpecialValueFor("burn_damage")/100

    self:GetAbility():DealDamage(caster, parent, damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
end

function modifier_abyssal_underlord_firestorm_bh_burn:GetEffectName()
    return "particles/units/heroes/heroes_underlord/abyssal_underlord_firestorm_wave_burn.vpcf"
end