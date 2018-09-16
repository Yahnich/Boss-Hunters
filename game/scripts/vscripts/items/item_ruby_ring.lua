item_ruby_ring = class({})
LinkLuaModifier( "modifier_item_ruby_ring", "items/item_ruby_ring.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_ruby_ring:GetIntrinsicModifierName()
	return "modifier_item_ruby_ring"
end

modifier_item_ruby_ring = class(itemBaseClass)
function modifier_item_ruby_ring:OnCreated()
	self.hp_regen = self:GetSpecialValueFor("hp_regen")
end

function modifier_item_ruby_ring:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function modifier_item_ruby_ring:GetModifierConstantHealthRegen()
	return self.hp_regen
end