item_gladiatrix_weapon_1 = class({})

function item_gladiatrix_weapon_1:GetIntrinsicModifierName()
	return "modifier_item_gladiatrix_weapon"
end

item_gladiatrix_weapon_2 = class(item_gladiatrix_weapon_1)
item_gladiatrix_weapon_3 = class(item_gladiatrix_weapon_1)
item_gladiatrix_weapon_4 = class(item_gladiatrix_weapon_1)
item_gladiatrix_weapon_5 = class(item_gladiatrix_weapon_1)

modifier_item_gladiatrix_weapon = class({})
LinkLuaModifier("modifier_item_gladiatrix_weapon", "items/gladiatrix/item_gladiatrix_weapon.lua", 0)

function modifier_item_gladiatrix_weapon:OnCreated()
	self.bonus_dmg = self:GetSpecialValueFor("bonus_dmg")
end

function modifier_item_gladiatrix_weapon:OnRefresh()
	self.bonus_dmg = self:GetSpecialValueFor("bonus_dmg")
end

function modifier_item_gladiatrix_weapon:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE}
end

function modifier_item_gladiatrix_weapon:GetModifierBaseAttack_BonusDamage()
	return self.bonus_dmg
end

function modifier_item_gladiatrix_weapon:IsHidden()
	return true
end