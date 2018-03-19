item_elven_boots = class({})
LinkLuaModifier( "modifier_item_elven_boots_passive", "items/item_elven_boots.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_elven_boots:GetIntrinsicModifierName()
	return "modifier_item_elven_boots_passive"
end

function item_elven_boots:OnSpellStart()
	local caster = self:GetCaster()
	local tree = self:GetCursorPosition()
	GridNavDestroyTreesAroundPoint(tree, 20, true)
end

modifier_item_elven_boots_passive = class({})

function modifier_item_elven_boots_passive:OnCreated()
	self.bonus_ms = self:GetSpecialValueFor("bonus_ms")
end

function modifier_item_elven_boots_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE}
end

function modifier_item_elven_boots_passive:GetModifierMoveSpeedBonus_Special_Boots()
	return self.bonus_ms
end

function modifier_item_elven_boots_passive:IsHidden()
	return true
end