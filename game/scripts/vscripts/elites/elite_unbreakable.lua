elite_unbreakable = class({})

function elite_unbreakable:GetIntrinsicModifierName()
	return "modifier_elite_unbreakable"
end

modifier_elite_unbreakable = class(relicBaseClass)
LinkLuaModifier("modifier_elite_unbreakable", "elites/elite_unbreakable", LUA_MODIFIER_MOTION_NONE)


function modifier_elite_unbreakable:CheckState()
	return {[MODIFIER_STATE_ROOTED] = false,
			[MODIFIER_STATE_DISARMED] = false,
			[MODIFIER_STATE_SILENCED] = false,
			[MODIFIER_STATE_MUTED] = false,
			[MODIFIER_STATE_STUNNED] = false,
			[MODIFIER_STATE_HEXED] = false,
			[MODIFIER_STATE_FROZEN] = false,
			[MODIFIER_STATE_PASSIVES_DISABLED] = false}
end

function modifier_elite_unbreakable:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end

function modifier_elite_unbreakable:GetEffectName()
	return "particles/units/elite_warning_defense_overhead.vpcf"
end

function modifier_elite_unbreakable:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end