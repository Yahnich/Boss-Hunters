relic_generic_giants_toenail = class(relicBaseClass)

function relic_generic_giants_toenail:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATUS_RESISTANCE}
end

function relic_generic_giants_toenail:GetModifierStatusResistance()
	return 25
end