modifier_disarm_generic = class({})

if IsServer() then
	function modifier_disarm_generic:OnCreated(kv)
		if toboolean(kv.delay) == true then
			self.delay = true
			self:GetAbility():StartDelayedCooldown()
		end
	end
	
	function modifier_disarm_generic:OnDestroy()
		if self.delay then self:GetAbility():EndDelayedCooldown() end
	end
end

function modifier_disarm_generic:GetEffectName()
	return "particles/generic_gameplay/generic_disarm.vpcf"
end

function modifier_disarm_generic:GetTexture()
	return "filler_ability"
end

function modifier_disarm_generic:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_disarm_generic:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_disarm_generic:CheckState()
	local state = { [MODIFIER_STATE_DISARMED] = true}
	return state
end

function modifier_disarm_generic:IsPurgable()
	return true
end

function modifier_disarm_generic:IsHidden()
	return false
end