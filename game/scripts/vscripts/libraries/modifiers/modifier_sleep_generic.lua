modifier_sleep_generic = class({})

if IsServer() then
	function modifier_sleep_generic:OnCreated(kv)
		self.minDuration = kv.min_duration
	end
end

function modifier_sleep_generic:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
			MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_sleep_generic:OnTakeDamage(params)
	if params.unit == self:GetParent() and self:GetElapsedTime() > self.minDuration then
		self:Destroy()
	end
end

function modifier_sleep_generic:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end

function modifier_sleep_generic:GetOverrideAnimationRate()
	return 0.5
end


function modifier_sleep_generic:GetEffectName()
	return "particles/generic_gameplay/generic_sleep.vpcf"
end

function modifier_sleep_generic:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_sleep_generic:GetStatusEffectName()
	return "particles/status_fx/status_effect_nightmare.vpcf"
end

function modifier_sleep_generic:StatusEffectPriority()
	return 10
end

function modifier_sleep_generic:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NIGHTMARED] = true,
			[MODIFIER_STATE_SPECIALLY_DENIABLE] = true,
			[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
			}
end

function modifier_sleep_generic:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_sleep_generic:IsHidden()
	return false
end

function modifier_sleep_generic:IsPurgable()
	return true
end

function modifier_sleep_generic:IsDebuff()
	return true
end