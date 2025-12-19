kunkka_tidal_wave = class({})

function kunkka_tidal_wave:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local distance = self:GetTrueCastRange()

    local speed = self:GetSpecialValueFor("speed")
    local radius = self:GetSpecialValueFor("real_radius")
    local offset = self:GetSpecialValueFor("offset")

    local dir = CalculateDirection(point, caster)
    dir.z = 0
    local proj_dir = dir:Normalized()

    local info = {
        EffectName = "particles/units/heroes/hero_kunkka/kunkka_shard_tidal_wave.vpcf",
        Ability = self,
        vSpawnOrigin = caster:GetAbsOrigin() + dir * -offset,
        fStartRadius = radius,
        fEndRadius = radius,
        vVelocity = proj_dir * speed,
        fDistance = distance + offset,
        Source = caster,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    }
    ProjectileManager:CreateLinearProjectile(info)
    EmitSoundOnLocationWithCaster(point, "Hero_Kunkka.TidalWave", caster)
end

function kunkka_tidal_wave:OnProjectileHit(hTarget, vLocation)
    if hTarget ~= nil and not hTarget:IsMagicImmune() and not hTarget:IsInvulnerable() then
        local caster = self:GetCaster()
        local damage = self:GetSpecialValueFor("damage")
        local debuff_dur = self:GetSpecialValueFor("debuff_duration")

        local drag_direction = CalculateDirection(vLocation, hTarget:GetAbsOrigin())
        local drag_duration = self:GetSpecialValueFor("duration")
        local knockback_distance = self:GetSpecialValueFor("knockback_distance")

        hTarget:ApplyKnockBack(hTarget:GetAbsOrigin() + drag_direction, 0, drag_duration, knockback_distance, 0, caster, self, true)
        hTarget:AddNewModifier(caster, self, "modifier_kunkka_tidal_wave_debuff", {duration = debuff_dur})
        EmitSoundOn("Hero_Kunkka.TidalWave.Target", hTarget)
        self:DealDamage(caster, hTarget, damage)
    end
    return false
end

modifier_kunkka_tidal_wave_debuff = class({})
LinkLuaModifier("modifier_kunkka_tidal_wave_debuff", "heroes/hero_kunkka/kunkka_tidal_wave", LUA_MODIFIER_MOTION_NONE)

function modifier_kunkka_tidal_wave_debuff:IsDebuff()
    return true
end

function modifier_kunkka_tidal_wave_debuff:IsPurgable()
    return true
end

function modifier_kunkka_tidal_wave_debuff:OnCreated()
    self:OnRefresh()
end

function modifier_kunkka_tidal_wave_debuff:OnRefresh()
    self.mres_reduc = self:GetSpecialValueFor("mres_reduc")
    self.total_dmg_reduc = self:GetSpecialValueFor("total_dmg_reduc")
    self.armor_reduc = self:GetSpecialValueFor("armor_reduc")
end

function modifier_kunkka_tidal_wave_debuff:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
end

function modifier_kunkka_tidal_wave_debuff:GetModifierMagicalResistanceBonus()
    if self:GetSpecialValueFor("mariner") ~=0 then
        return -self.mres_reduc
    else return end
end

function modifier_kunkka_tidal_wave_debuff:GetModifierBaseDamageOutgoing_Percentage()
    if self:GetSpecialValueFor("admiral") ~= 0 then
        return -self.total_dmg_reduc
    else return end
end

function modifier_kunkka_tidal_wave_debuff:GetModifierPhysicalArmorBonus()
    if self:GetSpecialValueFor("privateer") ~= 0 then
        return -self.armor_reduc
    else return end
end