beast_beast_mode = class({})
LinkLuaModifier( "modifier_beast_mode", "heroes/hero_beast/beast_beast_mode.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_beast_mode_allies", "heroes/hero_beast/beast_beast_mode.lua" ,LUA_MODIFIER_MOTION_NONE )

function beast_beast_mode:GetIntrinsicModifierName()
	return "modifier_beast_mode"
end

modifier_beast_mode = class({})
function modifier_beast_mode:GetAuraDuration()
	return 1.0
end

function modifier_beast_mode:GetAuraRadius()
	return self:GetSpecialValueFor("radius")
end

function modifier_beast_mode:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_beast_mode:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_beast_mode:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

function modifier_beast_mode:GetModifierAura()
	return "modifier_beast_mode_allies"
end

function modifier_beast_mode:IsAura()
	return true
end

function modifier_beast_mode:IsHidden()
	return true
end

modifier_beast_mode_allies = class({})
function modifier_beast_mode_allies:OnCreated()
	self.cdr = self:GetSpecialValueFor("bonus_cdr") 
	if self:GetCaster():HasTalent("special_bonus_unique_beast_beast_mode_1") then
		self.amp = self:GetSpecialValueFor("bonus_cdr") 
	end
	self.as = self:GetSpecialValueFor("bonus_attackspeed")
	self.hp = self:GetSpecialValueFor("boar_bonus_health")
	self.hpr = self:GetSpecialValueFor("boar_bonus_regen")
	self.ms = self:GetSpecialValueFor("hawk_bonus_ms")
	self.vis = self:GetSpecialValueFor("hawk_bonus_vision")
	self:GetParent():HookInModifier("GetModifierExtraHealthBonusPercentage", self)
end

function modifier_beast_mode_allies:OnRefresh()
	self:OnCreated()
end

function modifier_beast_mode_allies:OnDestroy()
	self:GetParent():HookOutModifier("GetModifierExtraHealthBonusPercentage", self)
end

function modifier_beast_mode_allies:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION
	}
	return funcs
end

function modifier_beast_mode_allies:GetModifierPercentageCooldown()
	return self.cdr
end

function modifier_beast_mode_allies:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_beast_mode_allies:GetModifierExtraHealthBonusPercentage()
	if self:GetCaster():HasModifier("modifier_cotw_boar_spirit") then return self.hp end
end

function modifier_beast_mode_allies:GetModifierConstantHealthRegen()
	if self:GetCaster():HasModifier("modifier_cotw_boar_spirit") then return self.hpr end
end

function modifier_beast_mode_allies:GetModifierMoveSpeedBonus_Percentage()
	if self:GetCaster():HasModifier("modifier_cotw_hawk_spirit") then return self.ms end
end

function modifier_beast_mode_allies:GetBonusDayVision()
	if self:GetCaster():HasModifier("modifier_cotw_hawk_spirit") then return self.vis end
end

function modifier_beast_mode_allies:GetBonusNightVision()
	if self:GetCaster():HasModifier("modifier_cotw_hawk_spirit") then return self.vis end
end

function modifier_beast_mode_allies:GetModifierSpellAmplify_Percentage()
	return self.amp
end

function modifier_beast_mode_allies:IsDebuff()
	return false
end