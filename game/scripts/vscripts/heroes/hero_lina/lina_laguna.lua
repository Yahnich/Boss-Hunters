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
	
	local totalDamage = self:GetSpecialValueFor("damage") * (1 + caster:GetSpellAmplification( false ) ) + target:GetMaxHealth()*self:GetSpecialValueFor("hp")/100
	local damage_type = TernaryOperator( DAMAGE_TYPE_PURE, self:GetSpecialValueFor("pure_damage") == 1, DAMAGE_TYPE_MAGICAL )
	local dazeDuration = self:GetSpecialValueFor("daze_duration")

    EmitSoundOn("Ability.LagunaBlade", caster)

    ParticleManager:FireRopeParticle("particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf", PATTACH_POINT_FOLLOW, caster, target, {})
	if target:TriggerSpellAbsorb( self ) then return end
    if dazeDuration > 0 then
        target:Daze(self, caster, dazeDuration)
    end
	
	self:DealDamage(caster, target, totalDamage, {damage_type = damage_type, damage_flags=DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, 0) 

    EmitSoundOn("Ability.LagunaBladeImpact", target)
end