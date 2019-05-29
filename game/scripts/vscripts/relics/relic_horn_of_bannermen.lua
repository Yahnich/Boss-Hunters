relic_horn_of_bannermen = class(relicBaseClass)

function relic_horn_of_bannermen:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end

function relic_horn_of_bannermen:GetModifierBonusStats_Agility()
	return 25
end