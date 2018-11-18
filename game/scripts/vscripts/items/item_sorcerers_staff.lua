item_sorcerers_staff = class({})
LinkLuaModifier( "modifier_item_sorcerers_staff_passive", "items/item_sorcerers_staff.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_sorcerers_staff:GetIntrinsicModifierName()
	return "modifier_item_sorcerers_staff_passive"
end

modifier_item_sorcerers_staff_passive = class(itemBasicBaseClass)

function modifier_item_sorcerers_staff_passive:OnCreated()
	self.spellamp = self:GetSpecialValueFor("bonus_spell_amp")
end

function modifier_item_sorcerers_staff_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function modifier_item_sorcerers_staff_passive:GetModifierSpellAmplify_Percentage()
	return self.spellamp
end