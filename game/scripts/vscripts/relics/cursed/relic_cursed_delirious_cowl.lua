relic_cursed_delirious_cowl = class({})

function relic_cursed_delirious_cowl:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function relic_cursed_delirious_cowl:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() then
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

function relic_cursed_delirious_cowl:IsHidden()
	return true
end

function relic_cursed_delirious_cowl:IsPurgable()
	return false
end

function relic_cursed_delirious_cowl:RemoveOnDeath()
	return false
end

function relic_cursed_delirious_cowl:IsPermanent()
	return true
end

function relic_cursed_delirious_cowl:AllowIllusionDuplicate()
	return true
end

function relic_cursed_delirious_cowl:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end