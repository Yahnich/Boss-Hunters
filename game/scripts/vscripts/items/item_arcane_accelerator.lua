item_arcane_accelerator = class({})
LinkLuaModifier( "modifier_item_arcane_accelerator_passive", "items/item_arcane_accelerator.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_arcane_accelerator:GetIntrinsicModifierName()
	return "modifier_item_arcane_accelerator_passive"
end

modifier_item_arcane_accelerator_passive = class({})

function modifier_item_arcane_accelerator_passive:OnCreated()
	self.cdr = self:GetSpecialValueFor("cooldown_reduction")
	self.ultChance = self:GetSpecialValueFor("ult_chance")
	self.basicChance = self:GetSpecialValueFor("basic_chance")
end

function modifier_item_arcane_accelerator_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING,
			MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function modifier_item_arcane_accelerator_passive:GetModifierPercentageCooldownStacking(params)
	return self.cdr
end

function modifier_item_arcane_accelerator_passive:OnAbilityFullyCast(params)
	if params.ability then
		if ( params.ability:GetAbilityType() == 5 and RollPercentage( self.ultChance ) ) or ( params.ability:GetAbilityType() ~= 5 and RollPercentage( self.basicChance ) ) then
			params.ability:Refresh()
		end
	end
end

function modifier_item_arcane_accelerator_passive:IsHidden()
	return true
end