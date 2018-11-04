modifier_stun_immunity = class({})

function modifier_stun_immunity:CheckState()
	return {[MODIFIER_STATE_STUNNED] = false}
end

function modifier_stun_immunity:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_stun_immunity:IsPurgable()
	return false
end

function modifier_stun_immunity:IsHidden()
	return true
end