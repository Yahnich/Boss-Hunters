item_boots_of_speed = class({})
LinkLuaModifier( "modifier_item_boots_of_speed_passive", "items/item_boots_of_speed.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_boots_of_speed:GetIntrinsicModifierName()
	return "modifier_item_boots_of_speed_passive"
end

function item_boots_of_speed:GetRuneSlots()
	return self:GetSpecialValueFor("rune_slots")
end

item_boots_of_speed_2 = class(item_boots_of_speed)
item_boots_of_speed_3 = class(item_boots_of_speed)
item_boots_of_speed_4 = class(item_boots_of_speed)
item_boots_of_speed_5 = class(item_boots_of_speed)
item_boots_of_speed_6 = class(item_boots_of_speed)
item_boots_of_speed_7 = class(item_boots_of_speed)
item_boots_of_speed_8 = class(item_boots_of_speed)
item_boots_of_speed_9 = class(item_boots_of_speed)

modifier_item_boots_of_speed_passive = class(itemBasicBaseClass)

function modifier_item_boots_of_speed_passive:OnCreatedSpecific()
	self.bonus_ms = self:GetSpecialValueFor("movespeed")
end

function modifier_item_boots_of_speed_passive:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	table.insert( funcs, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT )
	return funcs
end

function modifier_item_boots_of_speed_passive:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_ms
end