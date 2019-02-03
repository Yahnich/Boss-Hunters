relic_giants_toenail = class(relicBaseClass)

function relic_giants_toenail:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING}
end

function relic_giants_toenail:GetModifierStatusResistanceStacking()
	return 20
end