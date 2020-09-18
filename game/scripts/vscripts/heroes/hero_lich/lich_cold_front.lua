lich_cold_front = class({})


function lich_cold_front:GetIntrinsicModifierName()
	return "modifier_lich_cold_front"
end

modifier_lich_cold_front = class({})
LinkLuaModifier("modifier_lich_cold_front", "heroes/hero_lich/lich_cold_front", LUA_MODIFIER_MOTION_NONE )

function modifier_lich_cold_front:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("radius")
end

function modifier_lich_cold_front:OnRefresh()
	self.radius = self:GetTalentSpecialValueFor("radius")
end

function modifier_lich_cold_front:IsAura()
	return true
end

function modifier_lich_cold_front:GetModifierAura()
	return "modifier_lich_cold_front_debuff"
end

function modifier_lich_cold_front:GetAuraRadius()
	return self.radius
end

function modifier_lich_cold_front:GetAuraDuration()
	return 0.5
end

function modifier_lich_cold_front:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_lich_cold_front:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_lich_cold_front:IsHidden()    
	return true
end

function modifier_lich_cold_front:IsPurgable()    
	return false
end

modifier_lich_cold_front_debuff = class({})
LinkLuaModifier("modifier_lich_cold_front_debuff", "heroes/hero_lich/lich_cold_front", LUA_MODIFIER_MOTION_NONE )

function modifier_lich_cold_front_debuff:OnCreated()
	self.ms = self:GetTalentSpecialValueFor("ms_slow")
	self.as = self:GetTalentSpecialValueFor("as_slow")
end

function modifier_lich_cold_front_debuff:OnRefresh()
	self.ms = self:GetTalentSpecialValueFor("ms_slow")
	self.as = self:GetTalentSpecialValueFor("as_slow")
end

function modifier_lich_cold_front_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_lich_cold_front_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_lich_cold_front_debuff:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_lich_cold_front_debuff:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end