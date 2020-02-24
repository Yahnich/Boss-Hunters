elite_vampiric = class({})

function elite_vampiric:GetIntrinsicModifierName()
	return "modifier_elite_vampiric"
end

modifier_elite_vampiric = class(relicBaseClass)
LinkLuaModifier("modifier_elite_vampiric", "elites/elite_vampiric", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_vampiric:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_elite_vampiric:OnTakeDamage(params)
	if params.attacker == self:GetParent() and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and self:GetParent():GetHealth() > 0 and not params.inflictor then
		ParticleManager:FireParticle( "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		local flHeal = params.damage * self:GetSpecialValueFor("lifesteal") / 100
		params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
	end
end

function modifier_elite_vampiric:GetEffectName()
	return "particles/units/elite_warning_special_overhead.vpcf"
end

function modifier_elite_vampiric:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end