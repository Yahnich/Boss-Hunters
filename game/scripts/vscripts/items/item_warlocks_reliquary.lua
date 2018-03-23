item_warlocks_reliquary = class({})
LinkLuaModifier( "modifier_item_warlocks_reliquary_passive", "items/item_warlocks_reliquary.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_warlocks_reliquary:GetIntrinsicModifierName()
	return "modifier_item_warlocks_reliquary_passive"
end

modifier_item_warlocks_reliquary_passive = class({})

function modifier_item_warlocks_reliquary_passive:OnCreated()
	self.spellamp = self:GetSpecialValueFor("bonus_spell_amp")
	self.manacost = self:GetSpecialValueFor("mana_cost_reduction")
end

function modifier_item_warlocks_reliquary_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_MANACOST_PERCENTAGE}
end

function modifier_item_warlocks_reliquary_passive:GetModifierSpellAmplify_Percentage()
	return self.spellamp
end

function modifier_item_warlocks_reliquary_passive:GetModifierPercentageManacost()
	return self.manacost
end


function modifier_item_warlocks_reliquary_passive:IsHidden()
	return true
end

function modifier_item_warlocks_reliquary_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end