item_broadsword = class({})
LinkLuaModifier( "modifier_item_broadsword", "items/item_broadsword.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_broadsword:GetIntrinsicModifierName()
	return "modifier_item_broadsword"
end

modifier_item_broadsword = class({})
function modifier_item_broadsword:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_broadsword:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_item_broadsword:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_item_broadsword:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_broadsword:IsHidden()
	return true
end

