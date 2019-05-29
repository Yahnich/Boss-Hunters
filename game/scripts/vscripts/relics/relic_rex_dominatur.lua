relic_rex_dominatur = class(relicBaseClass)

function relic_rex_dominatur:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function relic_rex_dominatur:GetModifierTotalDamageOutgoing_Percentage(params)
	if params.target:IsCelestial() then
		return 25
	end
end