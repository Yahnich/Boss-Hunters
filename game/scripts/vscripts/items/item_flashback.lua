item_flashback = class({})
LinkLuaModifier( "modifier_item_flashback_passive", "items/item_flashback.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_flashback:IsRefreshable()
	return false
end

function item_flashback:OnSpellStart()
	local caster = self:GetCaster()
	caster:RefreshAllCooldowns(true)
end

function item_flashback:GetIntrinsicModifierName()
	return "modifier_item_flashback_passive"
end

modifier_item_flashback_passive = class({})

function modifier_item_flashback_passive:OnCreated()
	self.ultChance = self:GetSpecialValueFor("ult_chance")
	self.basicChance = self:GetSpecialValueFor("basic_chance")
	self.mr = self:GetSpecialValueFor("bonus_mana_regen")
	self.intellect = self:GetSpecialValueFor("bonus_intellect")
end

function modifier_item_flashback_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,}
end

function modifier_item_flashback_passive:GetModifierPercentageCooldownStacking(params)
	return self.cdr
end

function modifier_item_flashback_passive:GetModifierConstantManaRegen()
	return self.mr
end

function modifier_item_flashback_passive:GetModifierBonusStats_Intellect()
	return self.intellect
end

function modifier_item_flashback_passive:IsHidden()
	return true
end

function modifier_item_flashback_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end