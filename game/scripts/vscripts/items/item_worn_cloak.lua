item_worn_cloak = class({})
LinkLuaModifier( "modifier_item_worn_cloak", "items/item_worn_cloak.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_worn_cloak:GetIntrinsicModifierName()
	return "modifier_item_worn_cloak"
end

modifier_item_worn_cloak = class({})
function modifier_item_worn_cloak:OnCreated()
	self.magic_resist = self:GetAbility():GetSpecialValueFor("bonus_magic_resist")
end

function modifier_item_worn_cloak:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_item_worn_cloak:GetModifierMagicalResistanceBonus()
	return self.magic_resist
end

function modifier_item_worn_cloak:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_worn_cloak:IsHidden()
	return true
end

