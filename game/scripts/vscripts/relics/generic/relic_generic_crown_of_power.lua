relic_generic_crown_of_power = class(relicBaseClass)

function relic_generic_crown_of_power:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS }
end

function relic_generic_crown_of_power:GetModifierBonusStats_Intellect()
	return 25
end