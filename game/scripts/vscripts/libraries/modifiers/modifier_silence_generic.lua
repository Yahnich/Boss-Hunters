modifier_silence_generic = class({})

if IsServer() then
	function modifier_silence_generic:OnCreated(kv)
		if kv.delay == nil or toboolean(kv.delay) == true then
			self.delay = true
			self:GetAbility():StartDelayedCooldown(self:GetRemainingTime(), false)
		end
	end
	
	function modifier_silence_generic:OnDestroy()
		if self.delay then self:GetAbility():EndDelayedCooldown() end
	end
end

function modifier_silence_generic:GetEffectName()
	return "particles/generic_gameplay/generic_silence.vpcf"
end

function modifier_silence_generic:GetTexture()
	return "silencer_last_word"
end

function modifier_silence_generic:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_silence_generic:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_silence_generic:CheckState()
	local state = { [MODIFIER_STATE_SILENCED] = true}
	return state
end

function modifier_silence_generic:IsPurgable()
	return true
end

function modifier_silence_generic:IsDebuff()
	return true
end