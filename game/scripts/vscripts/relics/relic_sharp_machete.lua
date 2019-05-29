relic_sharp_machete = class(relicBaseClass)

function relic_sharp_machete:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function relic_sharp_machete:GetModifierTotalDamageOutgoing_Percentage(params)
	if params.target:IsWild() then
		return 25
	end
end