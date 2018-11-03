modifier_stunned_generic = class({})

if IsServer() then
	function modifier_stunned_generic:OnCreated(kv)
		if kv.delay == nil or toboolean(kv.delay) == true and not self:GetParent():IsRoundBoss() then
			self.delay = true
			self:GetAbility():StartDelayedCooldown(self:GetRemainingTime(), false)
		end
	end
	
	function modifier_stunned_generic:OnDestroy()
		if self.delay then self:GetAbility():EndDelayedCooldown() end
	end
end

function modifier_stunned_generic:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_stunned_generic:GetTexture()
	return "filler_ability"
end

function modifier_stunned_generic:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_stunned_generic:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_stunned_generic:CheckState()
	if not self:GetParent():IsRoundBoss() then
		local state = { [MODIFIER_STATE_STUNNED] = true}
		return state
	end
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

function modifier_stunned_generic:IsDebuff()
	return true
end

function modifier_stunned_generic:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_MAX,
		MODIFIER_PROPERTY_FIXED_ATTACK_RATE
	}

	return funcs
end

function modifier_stunned_generic:GetOverrideAnimation( params )
	if not self:GetParent():IsRoundBoss() then
		return ACT_DOTA_DISABLED
	end
end

function modifier_stunned_generic:GetModifierFixedAttackRate( params )
	if self:GetParent():IsRoundBoss() then
		return self:GetParent():GetBaseAttackTime()
	end
end

function modifier_stunned_generic:GetModifierMoveSpeedOverride( params )
	if self:GetParent():IsRoundBoss() then
		return 100
	end
end

function modifier_stunned_generic:GetModifierMoveSpeed_Absolute( params )
	if self:GetParent():IsRoundBoss() then
		return 100
	end
end

function modifier_stunned_generic:GetModifierMoveSpeed_AbsoluteMin( params )
	if self:GetParent():IsRoundBoss() then
		return 100
	end
end

function modifier_stunned_generic:GetModifierMoveSpeed_Limit( params )
	if self:GetParent():IsRoundBoss() then
		return 100
	end
end

function modifier_stunned_generic:GetModifierMoveSpeed_Max( params )
	if self:GetParent():IsRoundBoss() then
		return 100
	end
end
