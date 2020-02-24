elite_assassin = class({})

function elite_assassin:GetIntrinsicModifierName()
	return "modifier_elite_assassin"
end

modifier_elite_assassin = (relicBaseClass)
LinkLuaModifier("modifier_elite_assassin", "elites/elite_assassin", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_assassin:GetEffectName()
	return "particles/units/elite_warning_offense_overhead.vpcf"
end

function modifier_elite_assassin:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end