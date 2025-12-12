death_prophet_occultism = class({})

function death_prophet_occultism:GetIntrinsicModifierName()
	return "modifier_death_prophet_occultism"
end

function death_prophet_occultism:OnHeroLevelUp()
	self:GetCaster().passiveModifier:SetStackCount( self:GetCaster():GetLevel() )
end

modifier_death_prophet_occultism = class({})
LinkLuaModifier("modifier_death_prophet_occultism", "heroes/hero_death_prophet/death_prophet_occultism", LUA_MODIFIER_MOTION_NONE)

function modifier_death_prophet_occultism:OnCreated()
	self.ms = self:GetSpecialValueFor("bonus_movespeed")
	self.as = self:GetSpecialValueFor("bonus_attackspeed")
	self:GetCaster().passiveModifier = self
	self:GetParent():HookInModifier( "GetMoveSpeedLimitBonus", self )
	if IsServer() then
		self:SetStackCount( self:GetCaster():GetLevel() )
	end
end

function modifier_death_prophet_occultism:OnDestroy()
	self:GetParent():HookInModifier( "GetMoveSpeedLimitBonus", self )
end

function modifier_death_prophet_occultism:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_death_prophet_occultism:GetModifierAttackSpeedBonus_Constant()
	return self.as * self:GetStackCount()
end

function modifier_death_prophet_occultism:GetMoveSpeedLimitBonus()
	return self.ms * self:GetStackCount()
end

function modifier_death_prophet_occultism:GetModifierMoveSpeedBonus_Constant()
	return self.ms * self:GetStackCount()
end

function modifier_death_prophet_occultism:IsHidden()
	return true
end