lina_laguna = class({})

function lina_laguna:IsStealable()
    return true
end

function lina_laguna:IsHiddenWhenStolen()
    return false
end

function lina_laguna:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    EmitSoundOn("Ability.LagunaBlade", caster)
    EmitSoundOn("Ability.LagunaBladeImpact", target)

    ParticleManager:FireRopeParticle("particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf", PATTACH_POINT_FOLLOW, caster, target, {})

    if caster:HasTalent("special_bonus_unique_lina_laguna_2") then
        target:Daze(self, caster, caster:FindTalentValue("special_bonus_unique_lina_laguna_2"))
    end

    if caster:HasTalent("special_bonus_unique_lina_laguna_1") then
        self:DealDamage(caster, target, self:GetTalentSpecialValueFor("damage"), {damage_type = DAMAGE_TYPE_PURE}, 0) 
        local hpDamage = target:GetMaxHealth()*self:GetTalentSpecialValueFor("hp")/100
        self:DealDamage(caster, target, hpDamage, {damage_type = DAMAGE_TYPE_PURE, damage_flags=DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, OVERHEAD_ALERT_DAMAGE)
    else
        self:DealDamage(caster, target, self:GetTalentSpecialValueFor("damage"), {damage_type = DAMAGE_TYPE_MAGICAL}, 0) 
        local hpDamage = target:GetMaxHealth()*self:GetTalentSpecialValueFor("hp")/100
        self:DealDamage(caster, target, hpDamage, {damage_type = DAMAGE_TYPE_MAGICAL, damage_flags=DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, OVERHEAD_ALERT_DAMAGE)
    end
end