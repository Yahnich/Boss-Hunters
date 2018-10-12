relic_generic_bowl_of_chi = class(relicBaseClass)

function relic_generic_bowl_of_chi:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING}
end

function relic_generic_bowl_of_chi:GetModifierStatusAmplify_Percentage()
	return 15
end

function relic_generic_bowl_of_chi:GetModifierStatusResistanceStacking()
	return 15
end