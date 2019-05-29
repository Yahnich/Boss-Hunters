relic_unstoppable_force = class(relicBaseClass)

function relic_unstoppable_force:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN, MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE}
end

function relic_unstoppable_force:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function relic_unstoppable_force:GetModifierMoveSpeed_AbsoluteMin()
	return 550
end

function relic_unstoppable_force:GetModifierTurnRate_Percentage()
	if not self:GetParent():HasModifier("relic_ritual_candle") then return -80 end
end