modifier_root_immunity = class({})

function modifier_stun_immunity:CheckState()
	return {[MODIFIER_STATE_STUNNED] = false}
end

function modifier_status_immunity:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end