item_crystalline_staff = class({})
LinkLuaModifier( "modifier_item_crystalline_staff_passive", "items/item_crystalline_staff.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_crystalline_staff:GetIntrinsicModifierName()
	return "modifier_item_crystalline_staff_passive"
end

modifier_item_crystalline_staff_passive = class({})
function modifier_item_crystalline_staff_passive:OnCreated()
	self.castrange = self:GetAbility():GetSpecialValueFor("bonus_cast_range")
	self.spellamp = self:GetAbility():GetSpecialValueFor("bonus_spell_damage")
	self.bonusdamage = self:GetAbility():GetSpecialValueFor("bonus_damage_taken")
	self.int = self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_crystalline_staff_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_CAST_RANGE_BONUS,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_item_crystalline_staff_passive:GetModifierCastRangeBonus()
	return self.castrange
end

function modifier_item_crystalline_staff_passive:GetModifierSpellAmplify_Percentage()
	return self.spellamp
end

function modifier_item_crystalline_staff_passive:GetModifierIncomingDamage_Percentage()
	return self.bonusdamage
end

function modifier_item_crystalline_staff_passive:GetModifierBonusStats_Intellect()
	return self.int
end

function modifier_item_crystalline_staff_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end