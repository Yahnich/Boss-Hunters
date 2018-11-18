item_mithril_armor = class({})
LinkLuaModifier( "modifier_item_mithril_armor_passive", "items/item_mithril_armor.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_mithril_armor:GetIntrinsicModifierName()
	return "modifier_item_mithril_armor_passive"
end

modifier_item_mithril_armor_passive = class(itemBasicBaseClass)

function modifier_item_mithril_armor_passive:OnCreated()
	self.armor = self:GetSpecialValueFor("bonus_armor")
end

function modifier_item_mithril_armor_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_item_mithril_armor_passive:GetModifierPhysicalArmorBonus()
	return self.armor
end