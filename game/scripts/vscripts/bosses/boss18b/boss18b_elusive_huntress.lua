boss18b_elusive_huntress = class({})

function boss18b_elusive_huntress:GetIntrinsicModifierName()
	return "modifier_boss18b_elusive_huntress_passive"
end

modifier_boss18b_elusive_huntress_passive = class({})
LinkLuaModifier("modifier_boss18b_elusive_huntress_passive", "bosses/boss18b/boss18b_elusive_huntress.lua", 0)

function modifier_boss18b_elusive_huntress_passive:OnCreated()
	self.hitsToEffect = self:GetSpecialValueFor("hits_to_stun")
	self.stunDuration = self:GetSpecialValueFor("stun_duration")
	self.evasion = self:GetSpecialValueFor("evasion")
	self.critical = self:GetSpecialValueFor("critical_damage")
	self.hitsApplied = 0
end

function modifier_boss18b_elusive_huntress_passive:OnRefresh()
	self.hitsToEffect = self:GetSpecialValueFor("hits_to_stun")
	self.stunDuration = self:GetSpecialValueFor("stun_duration")
	self.evasion = self:GetSpecialValueFor("evasion")
	self.critical = self:GetSpecialValueFor("critical_damage")
end

function modifier_boss18b_elusive_huntress_passive:IsHidden()
	return true
end

function modifier_boss18b_elusive_huntress_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_PROPERTY_EVASION_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_boss18b_elusive_huntress_passive:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_boss18b_elusive_huntress_passive:GetModifierPreAttack_CriticalStrike(params)
	if self.hitsApplied >= self.hitsToEffect then
		return self.critical
	end
end	

function modifier_boss18b_elusive_huntress_passive:OnAttackLanded(params)
	if self:GetParent() == params.attacker then
		if self.target == params.target then
			if self.hitsApplied >= self.hitsToEffect then
				self.hitsApplied = 0
				self:GetAbility():Stun(params.target, self.stunDuration, false)
				EmitSoundOn("Hero_Juggernaut.BladeDance", params.target)
			else
				self.hitsApplied = self.hitsApplied + 1
			end
		else self.target = params.target end
	end
end