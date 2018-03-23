item_calming_skull = class({})
LinkLuaModifier( "modifier_item_calming_skull_passive", "items/item_calming_skull.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_calming_skull:GetIntrinsicModifierName()
	return "modifier_item_calming_skull_passive"
end

modifier_item_calming_skull_passive = class({})

function modifier_item_calming_skull_passive:OnCreated()
	self.manacost = self:GetSpecialValueFor("mana_cost_reduction")
end

function modifier_item_calming_skull_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANACOST_PERCENTAGE}
end

function modifier_item_calming_skull_passive:GetModifierPercentageManacost()
	return self.manacost
end

function modifier_item_calming_skull_passive:IsHidden()
	return true
end

function modifier_item_calming_skull_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end