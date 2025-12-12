lycan_feral_impulse_bh = class({})

function lycan_feral_impulse_bh:GetIntrinsicModifierName()
	return "modifier_lycan_feral_impulse_bh"
end

modifier_lycan_feral_impulse_bh = class({})
LinkLuaModifier("modifier_lycan_feral_impulse_bh", "heroes/hero_lycan/lycan_feral_impulse_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_lycan_feral_impulse_bh:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_lycan_feral_impulse_bh:OnRefresh()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_lycan_feral_impulse_bh:IsAura()
	return true
end

function modifier_lycan_feral_impulse_bh:GetModifierAura()
	return "modifier_lycan_feral_impulse_bh_aura"
end

function modifier_lycan_feral_impulse_bh:GetAuraRadius()
	return self.radius
end

function modifier_lycan_feral_impulse_bh:GetAuraDuration()
	return 0.5
end

function modifier_lycan_feral_impulse_bh:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_lycan_feral_impulse_bh:GetAuraEntityReject(entity)
	if entity == self:GetParent() or (entity:GetOwnerEntity() and entity:GetOwnerEntity() == self:GetParent()) then 
		return false
	else
		return true
	end
end

function modifier_lycan_feral_impulse_bh:IsHidden()
	return true
end

function modifier_lycan_feral_impulse_bh:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

modifier_lycan_feral_impulse_bh_aura = class({})
LinkLuaModifier("modifier_lycan_feral_impulse_bh_aura", "heroes/hero_lycan/lycan_feral_impulse_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_lycan_feral_impulse_bh_aura:OnCreated()
	self.damage = self:GetSpecialValueFor("bonus_damage")
	self.regen = self:GetSpecialValueFor("bonus_hp_regen")
	self:StartIntervalThink(0.33)
	if self:GetCaster():HasTalent("special_bonus_unique_lycan_feral_impulse_2") then
		if not GameRules:IsDaytime() then
			self.damage = self.damage + self:GetCaster():FindTalentValue("special_bonus_unique_lycan_feral_impulse_2")
		end
	end
	self:GetParent():HookInModifier("GetModifierExtraHealthBonusPercentage", self)
	if self:GetCaster():HasScepter() then
		self.health = self:GetSpecialValueFor("scepter_bonus_health")
	else
		self.health = 0
	end
end

function modifier_lycan_feral_impulse_bh_aura:OnDestroy()
	self:GetParent():HookOutModifier("GetModifierExtraHealthBonusPercentage", self)
end

function modifier_lycan_feral_impulse_bh_aura:OnIntervalThink()
	self.damage = self:GetSpecialValueFor("bonus_damage")
	self.regen = self:GetSpecialValueFor("bonus_hp_regen")
	if self:GetCaster():HasTalent("special_bonus_unique_lycan_feral_impulse_2") then
		if not GameRules:IsDaytime() then
			self.damage = self.damage + self:GetCaster():FindTalentValue("special_bonus_unique_lycan_feral_impulse_2")
		end
	end
	if self:GetCaster():HasScepter() then
		self.health = self:GetSpecialValueFor("scepter_bonus_health")
	else
		self.health = 0
	end
end

function modifier_lycan_feral_impulse_bh_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,}
end

function modifier_lycan_feral_impulse_bh_aura:GetModifierDamageOutgoing_Percentage()    
	return self.damage
end

function modifier_lycan_feral_impulse_bh_aura:GetModifierConstantHealthRegen()    
	return self.regen
end

function modifier_lycan_feral_impulse_bh_aura:GetModifierExtraHealthBonusPercentage()
	return self.health
end
