item_cuirass_of_war = class({})

function item_cuirass_of_war:GetIntrinsicModifierName()
	return "modifier_item_cuirass_of_war"
end

item_cuirass_of_war_2 = class(item_cuirass_of_war)
item_cuirass_of_war_3 = class(item_cuirass_of_war)
item_cuirass_of_war_4 = class(item_cuirass_of_war)
item_cuirass_of_war_5 = class(item_cuirass_of_war)
item_cuirass_of_war_6 = class(item_cuirass_of_war)
item_cuirass_of_war_7 = class(item_cuirass_of_war)
item_cuirass_of_war_8 = class(item_cuirass_of_war)
item_cuirass_of_war_9 = class(item_cuirass_of_war)

modifier_item_cuirass_of_war = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_cuirass_of_war", "items/item_cuirass_of_war.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_cuirass_of_war:OnCreatedSpecific()
	self.radius = self:GetSpecialValueFor("aura_radius")
	self.armor = self:GetSpecialValueFor("bonus_armor")
end

function modifier_item_cuirass_of_war:OnRefreshSpecific()
	self.radius = self:GetSpecialValueFor("aura_radius")
	self.armor = self:GetSpecialValueFor("bonus_armor")
end

function modifier_item_cuirass_of_war:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	table.insert( funcs, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS )
	return funcs
end

function modifier_item_cuirass_of_war:GetModifierPhysicalArmorBonus(params)
	return self.armor
end

function modifier_item_cuirass_of_war:IsAura()
	return true
end

function modifier_item_cuirass_of_war:GetModifierAura()
	return "modifier_item_cuirass_of_war_aura_"..self:GetAbility():GetItemSlot()
end

function modifier_item_cuirass_of_war:GetAuraRadius()
	return self.radius
end

function modifier_item_cuirass_of_war:GetAuraDuration()
	return 0.5
end

function modifier_item_cuirass_of_war:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_item_cuirass_of_war:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_item_cuirass_of_war:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

LinkLuaModifier( "modifier_item_cuirass_of_war_aura", "items/item_cuirass_of_war.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_cuirass_of_war_aura = class(itemAuraBaseClass)

function modifier_item_cuirass_of_war_aura:GetStoneShareability()
	return self.stone_share
end

function modifier_item_cuirass_of_war_aura:OnCreatedSpecific()
	self.armor = TernaryOperator( self:GetSpecialValueFor("aura_armor"), self:GetParent():IsSameTeam( self:GetCaster() ), self:GetSpecialValueFor("armor_debuff") )
	self.stone_share = self:GetSpecialValueFor("stone_share")
end

function modifier_item_cuirass_of_war_aura:OnRefreshSpecific()
	self.armor = TernaryOperator( self:GetSpecialValueFor("aura_armor"), self:GetParent():IsSameTeam( self:GetCaster() ), self:GetSpecialValueFor("armor_debuff") )
	self.stone_share = self:GetSpecialValueFor("stone_share")
end

function modifier_item_cuirass_of_war_aura:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	table.insert( funcs, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS )
	return funcs
end

function modifier_item_cuirass_of_war_aura:GetModifierPhysicalArmorBonus(params)
	return self.armor
end

modifier_item_cuirass_of_war_aura_0 = class(modifier_item_cuirass_of_war_aura)
LinkLuaModifier( "modifier_item_cuirass_of_war_aura_0", "items/item_cuirass_of_war.lua" ,LUA_MODIFIER_MOTION_NONE )

modifier_item_cuirass_of_war_aura_1 = class(modifier_item_cuirass_of_war_aura)
LinkLuaModifier( "modifier_item_cuirass_of_war_aura_1", "items/item_cuirass_of_war.lua" ,LUA_MODIFIER_MOTION_NONE )

modifier_item_cuirass_of_war_aura_2 = class(modifier_item_cuirass_of_war_aura)
LinkLuaModifier( "modifier_item_cuirass_of_war_aura_2", "items/item_cuirass_of_war.lua" ,LUA_MODIFIER_MOTION_NONE )

modifier_item_cuirass_of_war_aura_3 = class(modifier_item_cuirass_of_war_aura)
LinkLuaModifier( "modifier_item_cuirass_of_war_aura_3", "items/item_cuirass_of_war.lua" ,LUA_MODIFIER_MOTION_NONE )

modifier_item_cuirass_of_war_aura_4 = class(modifier_item_cuirass_of_war_aura)
LinkLuaModifier( "modifier_item_cuirass_of_war_aura_4", "items/item_cuirass_of_war.lua" ,LUA_MODIFIER_MOTION_NONE )

modifier_item_cuirass_of_war_aura_5 = class(modifier_item_cuirass_of_war_aura)
LinkLuaModifier( "modifier_item_cuirass_of_war_aura_5", "items/item_cuirass_of_war.lua" ,LUA_MODIFIER_MOTION_NONE )