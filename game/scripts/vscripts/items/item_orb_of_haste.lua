item_orb_of_haste = class({})

function item_orb_of_haste:GetIntrinsicModifierName()
	return "modifier_item_orb_of_haste"
end

modifier_item_orb_of_haste = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_orb_of_haste", "items/item_orb_of_haste.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_item_orb_of_haste:OnCreated()
	self.attackSpeed = self:GetSpecialValueFor("bonus_attackspeed")
	self.agility = self:GetSpecialValueFor("bonus_agility")
	self.movespeed = self:GetSpecialValueFor("bonus_movespeed")
end

function modifier_item_orb_of_haste:DeclareFunctions()
	return {
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			}
end

function modifier_item_orb_of_haste:GetModifierAttackSpeedBonus()
	return self.attackSpeed
end

function modifier_item_orb_of_haste:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_item_orb_of_haste:GetModifierBonusStats_Agility()
	return self.agility
end