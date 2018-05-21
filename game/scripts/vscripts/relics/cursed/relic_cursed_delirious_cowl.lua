relic_cursed_delirious_cowl = class(relicBaseClass)

function relic_cursed_delirious_cowl:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function relic_cursed_delirious_cowl:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() and params.ability:GetName() ~= "item_tombstone" then
		local delayedCD = params.ability:IsDelayedCooldown()
		local cd = params.ability:GetCooldownTimeRemaining()
		params.ability:Refresh()
		if delayedCD then
			params.ability:StartDelayedCooldown(false, cd * RandomFloat(0.1, 2) )
		else
			params.ability:StartCooldown( cd * RandomFloat(0.1, 2) )
		end
	end
end