boss_aeon_distortion_field = class({})

function boss_aeon_distortion_field:GetIntrinsicModifierName()
	return "modifier_boss_aeon_distortion_field"
end

modifier_boss_aeon_distortion_field = class({})
LinkLuaModifier("modifier_boss_aeon_distortion_field", "bosses/boss_aeon/boss_aeon_distortion_field", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_aeon_distortion_field:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_boss_aeon_distortion_field:OnRefresh()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_boss_aeon_distortion_field:IsAura()
	return true
end

function modifier_boss_aeon_distortion_field:GetModifierAura()
	return "modifier_boss_aeon_distortion_field_aura"
end

function modifier_boss_aeon_distortion_field:GetAuraRadius()
	return self.radius
end

function modifier_boss_aeon_distortion_field:GetAuraDuration()
	return 0.5
end

function modifier_boss_aeon_distortion_field:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_boss_aeon_distortion_field:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_boss_aeon_distortion_field:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_boss_aeon_distortion_field:IsHidden()
	return true
end

modifier_boss_aeon_distortion_field_aura = class({})
LinkLuaModifier("modifier_boss_aeon_distortion_field_aura", "bosses/boss_aeon/boss_aeon_distortion_field", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_aeon_distortion_field_aura:OnCreated()
	self.as = self:GetSpecialValueFor("as_slow")
	self.cdr = self:GetSpecialValueFor("cdr_slow")
end

function modifier_boss_aeon_distortion_field_aura:OnRefresh()
	self.as = self:GetSpecialValueFor("as_slow")
	self.cdr = self:GetSpecialValueFor("cdr_slow")
end

function modifier_boss_aeon_distortion_field_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_boss_aeon_distortion_field_aura:OnTooltip()
	return self.cdr
end

function modifier_boss_aeon_distortion_field_aura:GetModifierAttackSpeedBonus_Constant()
	return self.as
end