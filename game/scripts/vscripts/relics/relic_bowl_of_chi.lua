relic_bowl_of_chi = class(relicBaseClass)

function relic_bowl_of_chi:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING}
end

function relic_bowl_of_chi:GetModifierStatusAmplify_Percentage()
	return 10
end

function relic_bowl_of_chi:GetModifierStatusResistanceStacking()
	return 10
end