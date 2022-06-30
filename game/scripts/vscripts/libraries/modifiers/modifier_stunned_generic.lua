modifier_stunned_generic = class({})

function modifier_stunned_generic:OnCreated(kv)
	self:GetParent():HookInModifier( "GetMoveSpeedLimitBonus", self )
	
	if IsServer() then
		self:GetParent():RemoveGesture(ACT_DOTA_DISABLED)
		if self:GetParent():IsBoss() then
			self:GetParent():Interrupt()
			self:GetParent():Stop()
		end
		if kv.delay == nil or toboolean(kv.delay) == true and not self:GetParent():IsRoundNecessary() then
			self.delay = true
			if self:GetAbility() then self:GetAbility():StartDelayedCooldown(self:GetRemainingTime(), false) end
		end
	end
end

function modifier_stunned_generic:OnDestroy()
	self:GetParent():HookOutModifier( "GetMoveSpeedLimitBonus", self )
	if IsServer() then
		if self.delay and self:GetAbility() then self:GetAbility():EndDelayedCooldown() end
	end
end

function modifier_stunned_generic:CheckState()
	if not self:GetParent():IsBoss() then
		return {[MODIFIER_STATE_STUNNED] = true,
				[MODIFIER_STATE_PASSIVES_DISABLED] = true,
		}
	else
		return { [MODIFIER_STATE_PASSIVES_DISABLED] = true}
	end
end

function modifier_stunned_generic:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT ,
		MODIFIER_PROPERTY_CASTTIME_PERCENTAGE, 
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE
	}

	return funcs
end

function modifier_stunned_generic:GetOverrideAnimation( params )
	if self:GetParent():IsStunned() then
		return ACT_DOTA_DISABLED
	end
end

function modifier_stunned_generic:GetModifierAttackSpeedBonus_Constant( params )
	if self:GetParent():IsBoss() then
		return -300
	end
end

function modifier_stunned_generic:GetModifierMoveSpeedOverride( params )
	if self:GetParent():IsBoss() then
		return 100
	end
end

function modifier_stunned_generic:GetMoveSpeedLimitBonus( params )
	if self:GetParent():IsBoss() then
		return -450
	end
end

function modifier_stunned_generic:GetModifierPercentageCasttime()
	if self:GetParent():IsBoss() then
		return -50
	end
end

function modifier_stunned_generic:GetModifierTurnRate_Percentage()
	if self:GetParent():IsBoss() then
		return -80
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

function modifier_stunned_generic:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_stunned_generic:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_stunned_generic:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end