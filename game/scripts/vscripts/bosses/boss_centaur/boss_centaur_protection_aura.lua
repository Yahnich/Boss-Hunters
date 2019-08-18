boss_centaur_protection_aura = class({})

function boss_centaur_protection_aura:GetIntrinsicModifierName()
	return "modifier_boss_centaur_protection_aura"
end

modifier_boss_centaur_protection_aura = class({})
LinkLuaModifier( "modifier_boss_centaur_protection_aura", "bosses/boss_centaur/boss_centaur_protection_aura", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_centaur_protection_aura:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_boss_centaur_protection_aura:OnRefresh()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_boss_centaur_protection_aura:IsHidden()
	return true
end

function modifier_boss_centaur_protection_aura:IsAura()
	return not self:GetParent():PassivesDisabled()
end

function modifier_boss_centaur_protection_aura:GetModifierAura()
	return "modifier_boss_centaur_protection_aura_buff"
end

function modifier_boss_centaur_protection_aura:GetAuraRadius()
	return self.radius
end

function modifier_boss_centaur_protection_aura:GetAuraDuration()
	return 0.5
end

function modifier_boss_centaur_protection_aura:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_boss_centaur_protection_aura:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_boss_centaur_protection_aura:GetAuraEntityReject(entity)    
	return entity:GetUnitName() == "npc_dota_boss_lesser_centaur"
end

modifier_boss_centaur_protection_aura_buff = class({})
LinkLuaModifier( "modifier_boss_centaur_protection_aura_buff", "bosses/boss_centaur/boss_centaur_protection_aura", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_centaur_protection_aura_buff:OnCreated()
	self.red = self:GetSpecialValueFor("dmg_red")
end

function modifier_boss_centaur_protection_aura_buff:OnRefresh()
	self.red = self:GetSpecialValueFor("dmg_red")
end

function modifier_boss_centaur_protection_aura_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE }
end

function modifier_boss_centaur_protection_aura_buff:GetModifierIncomingDamage_Percentage()
	return -self.red
end

function modifier_boss_centaur_protection_aura_buff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE 
end