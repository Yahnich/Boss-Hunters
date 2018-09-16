item_hunters_hatchet = class({})
LinkLuaModifier( "modifier_item_hunters_hatchet_passive", "items/item_hunters_hatchet.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_hunters_hatchet:GetIntrinsicModifierName()
	return "modifier_item_hunters_hatchet_passive"
end

function item_hunters_hatchet:OnSpellStart()
	local caster = self:GetCaster()
	local tree = self:GetCursorPosition()
	GridNav:DestroyTreesAroundPoint(tree, 20, true)
end

modifier_item_hunters_hatchet_passive = class(itemBaseClass)

function modifier_item_hunters_hatchet_passive:OnCreated()
	self.bonusDamage = self:GetSpecialValueFor("bonus_damage")
end

function modifier_item_hunters_hatchet_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_item_hunters_hatchet_passive:GetModifierBaseDamageOutgoing_Percentage()
	return self.bonusDamage
end

function modifier_item_hunters_hatchet_passive:IsHidden()
	return true
end

function modifier_item_hunters_hatchet_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
