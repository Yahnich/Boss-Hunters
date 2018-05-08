relic_generic_barbedbell = class({})

function relic_generic_barbedbell:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end

function relic_generic_barbedbell:OnTakeDamage(params)
	if params.unit == self:GetParent() and params.attacker ~= self:GetParent() and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) )  then
		self:GetAbility():DealDamage( params.unit, params.attacker, 35, {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION})
		ParticleManager:FireRopeParticle("particles/units/heroes/hero_centaur/centaur_return.vpcf", PATTACH_POINT_FOLLOW, params.unit, params.attacker)
	end
end

function relic_generic_barbedbell:GetModifierBonusStats_Strength()
	return 10
end

function relic_generic_barbedbell:IsHidden()
	return true
end

function relic_generic_barbedbell:IsPurgable()
	return false
end

function relic_generic_barbedbell:RemoveOnDeath()
	return false
end

function relic_generic_barbedbell:IsPermanent()
	return true
end

function relic_generic_barbedbell:AllowIllusionDuplicate()
	return true
end

function relic_generic_barbedbell:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end