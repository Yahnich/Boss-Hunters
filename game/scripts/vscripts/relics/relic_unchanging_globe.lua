relic_unchanging_globe = class(relicBaseClass)


function relic_unchanging_globe:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function relic_unchanging_globe:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() and params.ability:GetName() ~= "item_tombstone" and params.ability:GetName() ~= "item_creed_of_knowledge" then
		local delayedCD = params.ability:IsDelayedCooldown()
		local cd = params.ability:GetCooldownTimeRemaining()
		if not params.unit:HasModifier("relic_ritual_candle") or cd > 18 then
			params.ability:EndCooldown()
			if delayedCD then
				params.ability:StartDelayedCooldown(false, 18)
			else
				params.ability:StartCooldown(18)
			end
		end
	end
end