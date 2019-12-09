boss_hellbear_battle_hymn = class({})

function boss_hellbear_battle_hymn:GetIntrinsicModifierName()
	return "modifier_boss_hellbear_battle_hymn"
end

modifier_boss_hellbear_battle_hymn = class({})
LinkLuaModifier( "modifier_boss_hellbear_battle_hymn", "bosses/boss_hellbear/boss_hellbear_battle_hymn", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_hellbear_battle_hymn:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_boss_hellbear_battle_hymn:OnRefresh()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_boss_hellbear_battle_hymn:IsHidden()
	return true
end

function modifier_boss_hellbear_battle_hymn:IsAura()
	return not self:GetParent():PassivesDisabled()
end

function modifier_boss_hellbear_battle_hymn:GetModifierAura()
	return "modifier_boss_hellbear_battle_hymn_buff"
end

function modifier_boss_hellbear_battle_hymn:GetAuraRadius()
	return self.radius
end

function modifier_boss_hellbear_battle_hymn:GetAuraDuration()
	return 0.5
end

function modifier_boss_hellbear_battle_hymn:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_boss_hellbear_battle_hymn:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

modifier_boss_hellbear_battle_hymn_buff = class({})
LinkLuaModifier( "modifier_boss_hellbear_battle_hymn_buff", "bosses/boss_hellbear/boss_hellbear_battle_hymn", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_hellbear_battle_hymn_buff:OnCreated()
	self.as = self:GetSpecialValueFor("bonus_as")
end

function modifier_boss_hellbear_battle_hymn_buff:OnRefresh()
	self.as = self:GetSpecialValueFor("bonus_as")
end

function modifier_boss_hellbear_battle_hymn_buff:GetModifierAttackSpeedBonus()
	return self.as
end

function modifier_boss_hellbear_battle_hymn_buff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE 
end