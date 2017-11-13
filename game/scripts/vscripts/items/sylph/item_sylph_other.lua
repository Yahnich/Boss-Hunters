item_sylph_other_1 = class({})

function item_sylph_other_1:GetIntrinsicModifierName()
	return "modifier_item_sylph_other"
end

item_sylph_other_2 = class(item_sylph_other_1)
item_sylph_other_3 = class(item_sylph_other_1)
item_sylph_other_4 = class(item_sylph_other_1)
item_sylph_other_5 = class(item_sylph_other_1)

modifier_item_sylph_other = class({})
LinkLuaModifier("modifier_item_sylph_other", "items/sylph/item_sylph_other.lua", 0)


function modifier_item_sylph_other:OnCreated()
	self.bonus_dmg = self:GetSpecialValueFor("bonus_dmg")
	self.atk_spd = self:GetSpecialValueFor("bonus_atkspeed")
end

function modifier_item_sylph_other:OnRefresh()
	self.bonus_dmg = self:GetSpecialValueFor("bonus_dmg")
	self.atk_spd = self:GetSpecialValueFor("bonus_atkspeed")
end

function modifier_item_sylph_other:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_item_sylph_other:GetModifierBaseAttack_BonusDamage()
	return self.bonus_dmg
end


function modifier_item_sylph_other:GetModifierAttackSpeedBonus_Constant()
	return self.atk_spd
end

function modifier_item_sylph_other:IsHidden()
	return true
end