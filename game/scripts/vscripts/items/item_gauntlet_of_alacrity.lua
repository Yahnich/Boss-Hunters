item_gauntlet_of_alacrity = class({})
LinkLuaModifier( "modifier_item_gauntlet_of_alacrity_passive", "items/item_gauntlet_of_alacrity.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_gauntlet_of_alacrity:GetIntrinsicModifierName()
	return "modifier_item_gauntlet_of_alacrity_passive"
end

modifier_item_gauntlet_of_alacrity_passive = class(itemBaseClass)

function modifier_item_gauntlet_of_alacrity_passive:OnCreated()
	self.bonus_attack_speed = self:GetSpecialValueFor("bonus_attackspeed")
end

function modifier_item_gauntlet_of_alacrity_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_item_gauntlet_of_alacrity_passive:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_attack_speed
end

function modifier_item_gauntlet_of_alacrity_passive:IsHidden()
	return true
end

function modifier_item_gauntlet_of_alacrity_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
