relic_cursed_icon_of_pride = class(relicBaseClass)

function relic_cursed_icon_of_pride:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function relic_cursed_icon_of_pride:GetModifierBonusStats_Strength()
	return 40
end

function relic_cursed_icon_of_pride:GetModifierBonusStats_Agility()
	return 40
end

function relic_cursed_icon_of_pride:GetModifierBonusStats_Intellect()
	return 40
end