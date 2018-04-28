relic_cursed_unstoppable_force = class({})

function relic_cursed_unstoppable_force:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN, MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE}
end

function relic_cursed_unstoppable_force:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function relic_cursed_unstoppable_force:GetModifierMoveSpeed_AbsoluteMin()
	return 550
end

function relic_cursed_unstoppable_force:GetModifierTurnRate_Percentage()
	return -80
end

function relic_cursed_unstoppable_force:IsHidden()
	return true
end

function relic_cursed_unstoppable_force:IsPurgable()
	return false
end

function relic_cursed_unstoppable_force:RemoveOnDeath()
	return false
end

function relic_cursed_unstoppable_force:IsPermanent()
	return true
end

function relic_cursed_unstoppable_force:AllowIllusionDuplicate()
	return true
end