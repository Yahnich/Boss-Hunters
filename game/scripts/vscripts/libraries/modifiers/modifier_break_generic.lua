modifier_break_generic = class({})

function modifier_break_generic:GetEffectName()
	return "particles/generic_gameplay/generic_break.vpcf"
end

function modifier_break_generic:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_break_generic:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_break_generic:CheckState()
	local state = { [MODIFIER_STATE_PASSIVES_DISABLED] = true}
	return state
end

function modifier_break_generic:IsPurgable()
	return true
end

function modifier_break_generic:IsDebuff()
	return true
end