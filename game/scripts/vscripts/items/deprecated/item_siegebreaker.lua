item_siegebreaker = class({})

LinkLuaModifier( "modifier_item_siegebreaker", "items/item_siegebreaker.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_siegebreaker:GetIntrinsicModifierName()
	return "modifier_item_siegebreaker"
end

modifier_item_siegebreaker = class(itemBaseClass)

function modifier_item_siegebreaker:OnCreated()
	self.range = self:GetSpecialValueFor("bonus_range")
end

function modifier_item_siegebreaker:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,}
end

function modifier_item_siegebreaker:GetModifierAttackRangeBonus()
	if self:GetParent():IsRangedAttacker() then
		return self.range
	end
end