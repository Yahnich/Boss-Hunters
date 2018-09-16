item_power_core = class({})
function item_power_core:GetIntrinsicModifierName()
	return "modifier_item_power_core_handle"
end

modifier_item_power_core_handle = class(itemBaseClass)
LinkLuaModifier( "modifier_item_power_core_handle", "items/item_power_core.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_power_core_handle:OnCreated()
	self.stat = self:GetSpecialValueFor("bonus_all")
end

function modifier_item_power_core_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_power_core_handle:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_item_power_core_handle:GetModifierBonusStats_Strength()
	return self.stat
end

function modifier_item_power_core_handle:GetModifierBonusStats_Agility()
	return self.stat
end

function modifier_item_power_core_handle:GetModifierBonusStats_Intellect()
	return self.stat
end

function modifier_item_power_core_handle:IsHidden()
	return true
end

function modifier_item_power_core_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end