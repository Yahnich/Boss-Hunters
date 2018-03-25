item_staff_of_magi = class({})
function item_staff_of_magi:GetIntrinsicModifierName()
	return "modifier_item_staff_of_magi_handle"
end

modifier_item_staff_of_magi_handle = class({})
LinkLuaModifier( "modifier_item_staff_of_magi_handle", "items/item_staff_of_magi.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_staff_of_magi_handle:OnCreated()
	self.stat = self:GetSpecialValueFor("bonus_strength")
end

function modifier_item_staff_of_magi_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_staff_of_magi_handle:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_item_staff_of_magi_handle:GetModifierBonusStats_Intellect()
	return self.stat
end

function modifier_item_staff_of_magi_handle:IsHidden()
	return true
end