item_spell_refinery = class({})
LinkLuaModifier( "modifier_item_spell_refinery_passive", "items/item_spell_refinery.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_spell_refinery:GetIntrinsicModifierName()
	return "modifier_item_spell_refinery_passive"
end

modifier_item_spell_refinery_passive = class(itemBaseClass)
function modifier_item_spell_refinery_passive:OnCreated()
	self.castrange = self:GetAbility():GetSpecialValueFor("bonus_cast_range")
end

function modifier_item_spell_refinery_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_CAST_RANGE_BONUS}
end

function modifier_item_spell_refinery_passive:GetModifierCastRangeBonus()
	return self.castrange
end