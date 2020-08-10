item_blade_of_agility = class({})
function item_blade_of_agility:GetIntrinsicModifierName()
	return "modifier_item_blade_of_agility_handle"
end

modifier_item_blade_of_agility_handle = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_blade_of_agility_handle", "items/item_blade_of_agility.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_blade_of_agility_handle:OnCreated()
	self.stat = self:GetSpecialValueFor("bonus_agility")
end

function modifier_item_blade_of_agility_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_blade_of_agility_handle:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end

function modifier_item_blade_of_agility_handle:GetModifierBonusStats_Agility()
	return self.stat
end

function modifier_item_blade_of_agility_handle:IsHidden()
	return true
end