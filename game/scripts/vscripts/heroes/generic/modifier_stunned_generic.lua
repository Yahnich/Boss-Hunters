modifier_stunned_generic = modifier_stunned_generic or class({})

function modifier_stunned_generic:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_stunned_generic:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_stunned_generic:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_stunned_generic:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true}
	return state
end

function modifier_stunned_generic:IsPurgable()
	return true
end

function modifier_stunned_generic:IsStunDebuff()
	return true
end

function modifier_stunned_generic:IsPurgeException()
	return true
end