item_ring_of_mana = class({})
LinkLuaModifier( "modifier_item_ring_of_mana_passive", "items/item_ring_of_mana.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_ring_of_mana:GetIntrinsicModifierName()
	return "modifier_item_ring_of_mana_passive"
end

modifier_item_ring_of_mana_passive = class(itemBaseClass)

function modifier_item_ring_of_mana_passive:OnCreated()
	self.manaregen = self:GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_ring_of_mana_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT}
end

function modifier_item_ring_of_mana_passive:GetModifierConstantManaRegen()
	return self.manaregen
end