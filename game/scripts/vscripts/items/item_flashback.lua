item_flashback = class({})
LinkLuaModifier( "modifier_item_flashback_passive", "items/item_flashback.lua" ,LUA_MODIFIER_MOTION_NONE )

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
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
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

function modifier_item_flashback_passive:OnAbilityFullyCast(params)
	if params.ability and params.unit == self:GetParent() then
		if ( params.ability:GetAbilityType() == 5 and RollPercentage( self.ultChance ) ) or ( params.ability:GetAbilityType() ~= 5 and RollPercentage( self.basicChance ) ) then
			params.ability:Refresh()
		end
	end
end

function modifier_item_flashback_passive:IsHidden()
	return true
end