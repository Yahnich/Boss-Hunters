boss_sloth_demon_slime_tendrils = class({})

function boss_sloth_demon_slime_tendrils:GetIntrinsicModifierName()
	return "modifier_boss_sloth_demon_slime_tendrils"
end

modifier_boss_sloth_demon_slime_tendrils = class({})
LinkLuaModifier( "modifier_boss_sloth_demon_slime_tendrils", "bosses/boss_sloth_demon/boss_sloth_demon_slime_tendrils", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_sloth_demon_slime_tendrils:OnCreated()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_boss_sloth_demon_slime_tendrils:OnRefresh()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_boss_sloth_demon_slime_tendrils:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_boss_sloth_demon_slime_tendrils:OnTakeDamage(params)
	if params.unit == self:GetParent() and not params.unit:PassivesDisabled() then
		params.attacker:AddNewModifier( params.unit, self:GetAbility(), "modifier_boss_sloth_demon_slime_tendrils_debuff", {duration = self.duration} )
	end
end

function modifier_boss_sloth_demon_slime_tendrils:IsHidden()
	return true
end

modifier_boss_sloth_demon_slime_tendrils_debuff = class({})
LinkLuaModifier( "modifier_boss_sloth_demon_slime_tendrils_debuff", "bosses/boss_sloth_demon/boss_sloth_demon_slime_tendrils", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_sloth_demon_slime_tendrils_debuff:OnCreated()
	self.ms = self:GetSpecialValueFor("move_slow")
	self.ts = self:GetSpecialValueFor("turn_slow")
	if IsServer() then
		self:SetStackCount(1)
	end
end

function modifier_boss_sloth_demon_slime_tendrils_debuff:OnRefresh()
	self.ms = self:GetSpecialValueFor("move_slow")
	self.ts = self:GetSpecialValueFor("turn_slow")
	if IsServer() then
		self:IncrementStackCount()
	end
end

function modifier_boss_sloth_demon_slime_tendrils_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_boss_sloth_demon_slime_tendrils_debuff:GetModifierTurnRate_Percentage()
	return self.ts * self:GetStackCount()
end

function modifier_boss_sloth_demon_slime_tendrils_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms * self:GetStackCount()
end