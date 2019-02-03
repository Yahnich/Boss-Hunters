relic_apple_of_eden = class(relicBaseClass)

function relic_apple_of_eden:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function relic_apple_of_eden:GetModifierTotalDamageOutgoing_Percentage(params)
	if not self:GetParent():HasModifier("relic_ritual_candle") then
		return -33
	end
end

function relic_apple_of_eden:GetModifierHealAmplify_Percentage(params)
	return 100
end