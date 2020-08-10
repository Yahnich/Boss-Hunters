item_blade_of_storm = class({})
LinkLuaModifier( "modifier_item_blade_of_storm_passive", "items/item_blade_of_storm.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_blade_of_storm:GetIntrinsicModifierName()
	return "modifier_item_blade_of_storm_passive"
end

function item_blade_of_storm:GetRuneSlots()
	return self:GetSpecialValueFor("rune_slots")
end

item_blade_of_storm_2 = class(item_blade_of_storm)
item_blade_of_storm_3 = class(item_blade_of_storm)
item_blade_of_storm_4 = class(item_blade_of_storm)
item_blade_of_storm_5 = class(item_blade_of_storm)
item_blade_of_storm_6 = class(item_blade_of_storm)
item_blade_of_storm_7 = class(item_blade_of_storm)
item_blade_of_storm_8 = class(item_blade_of_storm)
item_blade_of_storm_9 = class(item_blade_of_storm)

modifier_item_blade_of_storm_passive = class(itemBasicBaseClass)

function modifier_item_blade_of_storm_passive:OnCreatedSpecific()
	self.evasion = self:GetSpecialValueFor("bonus_evasion")
end

function modifier_item_blade_of_storm_passive:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	table.insert( funcs, MODIFIER_PROPERTY_EVASION_CONSTANT )
	return funcs
end

function modifier_item_blade_of_storm_passive:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_item_blade_of_storm_passive:IsHidden()
	return true
end