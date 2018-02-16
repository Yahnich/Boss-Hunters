modifier_silence_immunity = class({})

function modifier_silence_immunity:CheckState()
	return {[MODIFIER_STATE_SILENCED] = false}
end

function modifier_status_immunity:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end