modifier_break_generic = class({})

if IsServer() then
	function modifier_break_generic:OnCreated(kv)
		if kv.delay == nil or toboolean(kv.delay) == true then
			self.delay = true
			self:GetAbility():StartDelayedCooldown(self:GetRemainingTime(), false)
		end
	end
	
	function modifier_break_generic:OnDestroy()
		if self.delay then self:GetAbility():EndDelayedCooldown() end
	end
end

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