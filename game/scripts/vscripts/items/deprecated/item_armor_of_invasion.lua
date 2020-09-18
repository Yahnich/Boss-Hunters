item_armor_of_invasion = class({})

function item_armor_of_invasion:GetIntrinsicModifierName()
	return "modifier_armor_of_invasion_passive"
end

modifier_armor_of_invasion_passive = class(itemBaseClass)
LinkLuaModifier("modifier_armor_of_invasion_passive", "items/item_armor_of_invasion", LUA_MODIFIER_MOTION_NONE)

function modifier_armor_of_invasion_passive:OnCreated()
	self.armor = self:GetSpecialValueFor("bonus_armor")
	self.attackspeed = self:GetSpecialValueFor("bonus_attack_speed")
	self.damage = self:GetSpecialValueFor("bonus_damage")
	self.radius = self:GetSpecialValueFor("aura_radius")
end

function modifier_armor_of_invasion_passive:DeclareFunctions()
	funcs = {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
	return funcs
end

function modifier_armor_of_invasion_passive:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_armor_of_invasion_passive:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_armor_of_invasion_passive:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_armor_of_invasion_passive:IsAura()
	return true
end

function modifier_armor_of_invasion_passive:GetModifierAura()
	return "modifier_armor_of_invasion_aura"
end

function modifier_armor_of_invasion_passive:GetAuraRadius()
	return self.radius
end

function modifier_armor_of_invasion_passive:GetAuraDuration()
	return 0.5
end

function modifier_armor_of_invasion_passive:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_armor_of_invasion_passive:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_armor_of_invasion_passive:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_armor_of_invasion_passive:IsHidden()
	return true
end

modifier_armor_of_invasion_aura = class({})
LinkLuaModifier("modifier_armor_of_invasion_aura", "items/item_armor_of_invasion", LUA_MODIFIER_MOTION_NONE)

function modifier_armor_of_invasion_aura:OnCreated()
	self.armor = self:GetSpecialValueFor("aura_armor")
	self.as = self:GetSpecialValueFor("aura_attack_speed")
	if not self:GetParent():IsSameTeam( self:GetCaster() ) then
		self.armor = self:GetSpecialValueFor("aura_armor") * (-1)
		self.as = self:GetSpecialValueFor("aura_attack_speed") * (-1)
	end
end

function modifier_armor_of_invasion_aura:OnRefresh()
	self.armor = self:GetSpecialValueFor("aura_armor")
	self.as = self:GetSpecialValueFor("aura_attack_speed")
	if not self:GetParent():IsSameTeam( self:GetCaster() ) then
		self.armor = self:GetSpecialValueFor("aura_armor") * (-1)
		self.as = self:GetSpecialValueFor("aura_attack_speed") * (-1)
	end
end

function modifier_armor_of_invasion_aura:DeclareFunctions()
	funcs = {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
	return funcs
end

function modifier_armor_of_invasion_aura:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_armor_of_invasion_aura:GetModifierAttackSpeedBonus_Constant()
	return self.as
end