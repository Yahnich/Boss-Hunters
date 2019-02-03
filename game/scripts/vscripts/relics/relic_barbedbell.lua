relic_barbedbell = class(relicBaseClass)

function relic_barbedbell:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end

function relic_barbedbell:OnTakeDamage(params)
	if params.unit == self:GetParent() and params.attacker ~= self:GetParent() and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) )  then
		self:GetAbility():DealDamage( params.unit, params.attacker, 35, {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION})
		ParticleManager:FireRopeParticle("particles/units/heroes/hero_centaur/centaur_return.vpcf", PATTACH_POINT_FOLLOW, params.unit, params.attacker)
	end
end

function relic_barbedbell:GetModifierBonusStats_Strength()
	return 10
end