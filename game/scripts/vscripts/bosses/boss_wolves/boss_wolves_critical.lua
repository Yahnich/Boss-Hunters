boss_wolves_critical = class({})

function boss_wolves_critical:GetIntrinsicModifierName()
	return "modifier_boss_wolves_critical"
end

modifier_boss_wolves_critical = class({})
LinkLuaModifier("modifier_boss_wolves_critical", "bosses/boss_wolves/boss_wolves_critical", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_wolves_critical:OnCreated()
	self.chance = self:GetSpecialValueFor("chance")
	self.damage = self:GetSpecialValueFor("crit")
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_boss_wolves_critical:OnRefresh()
	self.chance = self:GetSpecialValueFor("chance")
	self.damage = self:GetSpecialValueFor("crit")
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_boss_wolves_critical:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE }
end

function modifier_boss_wolves_critical:GetModifierPreAttack_CriticalStrike(params)
	if self:RollPRNG( self.chance ) and not params.attacker:PassivesDisabled() then
		params.target:AddNewModifier( params.attacker, self:GetAbility(), "modifier_boss_wolves_critical_cripple", {duration = self.duration})
		return self.damage
	end
end

function modifier_boss_wolves_critical:IsHidden()
	return true
end

modifier_boss_wolves_critical_cripple = class({})
LinkLuaModifier("modifier_boss_wolves_critical_cripple", "bosses/boss_wolves/boss_wolves_critical", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_wolves_critical_cripple:OnCreated()
	self.as = self:GetSpecialValueFor("as")
	self.ms = self:GetSpecialValueFor("ms")
	self.bleed = self:GetSpecialValueFor("bleed")
	if self.bleed > 0 then
		self:StartIntervalThink(1)
	end
end

function modifier_boss_wolves_critical_cripple:OnIntervalThink()
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.bleed, {damage_type = DAMAGE_TYPE_PHYSICAL} )
end

function modifier_boss_wolves_critical_cripple:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_boss_wolves_critical_cripple:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_boss_wolves_critical_cripple:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_boss_wolves_critical_cripple:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end