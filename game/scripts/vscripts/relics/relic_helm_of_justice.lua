relic_helm_of_justice = class(relicBaseClass)

function relic_helm_of_justice:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end

function relic_helm_of_justice:GetModifierBonusStats_Strength()
	return 25
end