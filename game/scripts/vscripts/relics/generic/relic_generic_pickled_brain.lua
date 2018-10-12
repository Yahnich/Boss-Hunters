relic_generic_pickled_brain = class(relicBaseClass)

function relic_generic_pickled_brain:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_MANA_BONUS}
end

function relic_generic_pickled_brain:GetModifierBonusStats_Intellect()
	return 15
end

function relic_generic_pickled_brain:GetModifierManaBonus()
	return 200
end