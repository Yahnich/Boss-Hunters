item_strange_trinket = class({})
LinkLuaModifier( "modifier_item_strange_trinket_passive", "items/item_strange_trinket.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_strange_trinket:GetIntrinsicModifierName()
	return "modifier_item_strange_trinket_passive"
end

modifier_item_strange_trinket_passive = class({})

function modifier_item_strange_trinket_passive:OnCreated()
	self.bonus_mana = self:GetSpecialValueFor("bonus_mana")
end

function modifier_item_strange_trinket_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS}
end

function modifier_item_strange_trinket_passive:GetModifierManaBonus()
	return self.bonus_mana
end

function modifier_item_strange_trinket_passive:IsHidden()
	return true
end

function modifier_item_strange_trinket_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end