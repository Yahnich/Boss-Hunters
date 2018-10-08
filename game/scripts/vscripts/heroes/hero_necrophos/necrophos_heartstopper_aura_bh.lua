necrophos_heartstopper_aura_bh = class({})

function necrophos_heartstopper_aura_bh:GetCastRange( target, position )
	return self:GetTalentSpecialValueFor("aura_radius")
end

function necrophos_heartstopper_aura_bh:GetIntrinsicModifierName()
	return "modifier_necrophos_heart_stopper_bh"
end

modifier_necrophos_heart_stopper_bh = class({})
LinkLuaModifier( "modifier_necrophos_heart_stopper_bh", "heroes/hero_necrophos/necrophos_heartstopper_aura_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_necrophos_heart_stopper_bh:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("aura_radius")
end

function modifier_necrophos_heart_stopper_bh:OnRefresh()
	self.radius = self:GetTalentSpecialValueFor("aura_radius")
end

function modifier_necrophos_heart_stopper_bh:IsAura()
	return true
end

function modifier_necrophos_heart_stopper_bh:GetModifierAura()
	return "modifier_necrophos_heart_stopper_bh_degen"
end

function modifier_necrophos_heart_stopper_bh:GetAuraRadius()
	return self.radius
end

function modifier_necrophos_heart_stopper_bh:GetAuraDuration()
	return 0.5
end

function modifier_necrophos_heart_stopper_bh:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_necrophos_heart_stopper_bh:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

modifier_necrophos_heart_stopper_bh_degen = class({})
LinkLuaModifier( "modifier_necrophos_heart_stopper_bh_degen", "heroes/hero_necrophos/necrophos_heartstopper_aura_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_necrophos_heart_stopper_bh_degen:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_necrophos_heart_stopper_bh_degen:GetModifierHealthRegenPercentage()
	return self:GetTalentSpecialValueFor("aura_damage") * (-1)
end

function modifier_necrophos_heart_stopper_bh_degen:GetModifierAttackSpeedBonus_Constant()
	return self:GetCaster():FindTalentValue("special_bonus_unique_necrophos_heartstopper_aura_1")
end