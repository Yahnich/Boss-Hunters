item_fortress_shield = class({})

function item_fortress_shield:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_item_fortress_shield_block", {})
end

function item_fortress_shield:GetIntrinsicModifierName()
	return "modifier_item_fortress_shield_passive"
end

function item_fortress_shield:GetRuneSlots()
	return self:GetSpecialValueFor("rune_slots")
end

item_fortress_shield_2 = class(item_fortress_shield)
item_fortress_shield_3 = class(item_fortress_shield)
item_fortress_shield_4 = class(item_fortress_shield)
item_fortress_shield_5 = class(item_fortress_shield)
item_fortress_shield_6 = class(item_fortress_shield)
item_fortress_shield_7 = class(item_fortress_shield)
item_fortress_shield_8 = class(item_fortress_shield)
item_fortress_shield_9 = class(item_fortress_shield)

modifier_item_fortress_shield_passive = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_fortress_shield_passive", "items/item_fortress_shield.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_fortress_shield_passive:OnCreatedSpecific()
	self.armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_fortress_shield_passive:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	table.insert( funcs, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS )
	return funcs
end

function modifier_item_fortress_shield_passive:GetModifierPhysicalArmorBonus(params)
	return self.armor
end

modifier_item_fortress_shield_block = class({})
LinkLuaModifier( "modifier_item_fortress_shield_block", "items/item_fortress_shield.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_fortress_shield_block:OnCreated()
	self:OnRefresh()
end

function modifier_item_fortress_shield_block:OnRefresh()
	self.block = self:GetSpecialValueFor("damage_reduction") * (-1)
end

function modifier_item_fortress_shield_block:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_item_fortress_shield_block:GetModifierIncomingDamage_Percentage()
	self:Destroy()
	return self.block
end