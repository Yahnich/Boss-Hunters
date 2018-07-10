item_orb_of_renewal = class({})
LinkLuaModifier( "modifier_item_orb_of_renewal_passive", "items/item_orb_of_renewal.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_orb_of_renewal:GetIntrinsicModifierName()
	return "modifier_item_orb_of_renewal_passive"
end

modifier_item_orb_of_renewal_passive = class({})

function modifier_item_orb_of_renewal_passive:OnCreated()
	self.reduction = self:GetSpecialValueFor("ult_chance")
end

function modifier_item_orb_of_renewal_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function modifier_item_orb_of_renewal_passive:GetModifierPercentageCooldownStacking(params)
	return self.cdr
end

function modifier_item_orb_of_renewal_passive:OnAbilityFullyCast(params)	
	local cdReduction = self.reduction * ( 1 - self:GetParent():GetCooldownReduction() / 100 )
	if params.ability and params.ability:GetCooldownTimeRemaining() > cdReduction and params.unit == self:GetParent() then
		for i = 0, params.unit:GetAbilityCount() - 1 do
			local ability = params.unit:GetAbilityByIndex( i )
			if ability and params.ability ~= ability then
				ability:ModifyCooldown(-cdReduction)
			end
		end
		if bItems then
			for i=0, 5, 1 do
				local current_item = params.unit:GetItemInSlot(i)
				if current_item ~= nil and params.ability ~= current_item then
					current_item:ModifyCooldown(-cdReduction)
				end
			end
		end
	end
end

function modifier_item_orb_of_renewal_passive:IsHidden()
	return true
end