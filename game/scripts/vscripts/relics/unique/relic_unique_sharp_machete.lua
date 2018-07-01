relic_unique_sharp_machete = class(relicBaseClass)

function relic_unique_rex_dominatur:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function relic_unique_rex_dominatur:GetModifierTotalDamageOutgoing_Percentage(params)
	if params.target:IsWild() then
		return 25
	end
end