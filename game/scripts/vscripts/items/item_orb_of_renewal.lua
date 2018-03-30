item_orb_of_renewal = class({})
LinkLuaModifier( "modifier_item_orb_of_renewal_passive", "items/item_orb_of_renewal.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_orb_of_renewal:GetIntrinsicModifierName()
	return "modifier_item_orb_of_renewal_passive"
end

modifier_item_orb_of_renewal_passive = class({})

function modifier_item_orb_of_renewal_passive:OnCreated()
	self.ultChance = self:GetSpecialValueFor("ult_chance")
	self.basicChance = self:GetSpecialValueFor("basic_chance")
end

function modifier_item_orb_of_renewal_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function modifier_item_orb_of_renewal_passive:GetModifierPercentageCooldownStacking(params)
	return self.cdr
end

function modifier_item_orb_of_renewal_passive:OnAbilityFullyCast(params)
	if params.ability and params.unit == self:GetParent() then
		if ( params.ability:GetAbilityType() == 5 and RollPercentage( self.ultChance ) ) or ( params.ability:GetAbilityType() ~= 5 and RollPercentage( self.basicChance ) ) then
			params.ability:Refresh()
		end
	end
end

function modifier_item_orb_of_renewal_passive:IsHidden()
	return true
end