item_breeze_amulet = class({})
LinkLuaModifier( "modifier_item_breeze_amulet_passive", "items/item_breeze_amulet.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_breeze_amulet:GetIntrinsicModifierName()
	return "modifier_item_breeze_amulet_passive"
end

modifier_item_breeze_amulet_passive = class({})

function modifier_item_breeze_amulet_passive:OnCreated()
	self.manacost = self:GetSpecialValueFor("bonus_evasion")
end

function modifier_item_breeze_amulet_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function modifier_item_breeze_amulet_passive:GetModifierEvasion_Constant()
	return self.manacost
end

function modifier_item_breeze_amulet_passive:IsHidden()
	return true
end

function modifier_item_breeze_amulet_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end