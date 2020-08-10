item_arcane_accelerator = class({})
LinkLuaModifier( "modifier_item_arcane_accelerator_passive", "items/item_arcane_accelerator.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_arcane_accelerator:GetIntrinsicModifierName()
	return "modifier_item_arcane_accelerator_passive"
end

modifier_item_arcane_accelerator_passive = class({})

function modifier_item_arcane_accelerator_passive:OnCreated()
	self.status_amp = self:GetSpecialValueFor("status_amp")
	self.spell_amp = self:GetSpecialValueFor("bonus_spell_amp")
	self.mr = self:GetSpecialValueFor("bonus_mana_regen")
	self.intellect = self:GetSpecialValueFor("bonus_intellect")
	self.bonus_mana = self:GetSpecialValueFor("bonus_mana")
end

function modifier_item_arcane_accelerator_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_MANA_BONUS}
end

function modifier_item_arcane_accelerator_passive:GetModifierStatusAmplify_Percentage(params)
	return self.status_amp
end

function modifier_item_arcane_accelerator_passive:GetModifierSpellAmplify_Percentage(params)
	return self.spell_amp
end

function modifier_item_arcane_accelerator_passive:GetModifierManaBonus()
	return self.bonus_mana
end

function modifier_item_arcane_accelerator_passive:GetModifierConstantManaRegen()
	return self.mr
end

function modifier_item_arcane_accelerator_passive:GetModifierBonusStats_Intellect()
	return self.intellect
end

function modifier_item_arcane_accelerator_passive:IsHidden()
	return true
end

function modifier_item_arcane_accelerator_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end