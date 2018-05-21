relic_generic_pure_heart = class(relicBaseClass)

function relic_generic_pure_heart:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function relic_generic_pure_heart:GetModifierBonusStats_Strength()
	return 15
end

function relic_generic_pure_heart:GetModifierBonusStats_Agility()
	return 15
end

function relic_generic_pure_heart:GetModifierBonusStats_Intellect()
	return 15
end