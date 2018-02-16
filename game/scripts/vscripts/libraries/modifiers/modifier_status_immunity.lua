modifier_status_immunity = class({})

function modifier_status_immunity:CheckState()
	return {[MODIFIER_STATE_ROOTED] = false,
			[MODIFIER_STATE_DISARMED] = false,
			[MODIFIER_STATE_SILENCED] = false,
			[MODIFIER_STATE_MUTED] = false,
			[MODIFIER_STATE_STUNNED] = false,
			[MODIFIER_STATE_HEXED] = false,
			[MODIFIER_STATE_FROZEN] = false,
			[MODIFIER_STATE_PASSIVES_DISABLED] = false}
end

function modifier_status_immunity:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end