relic_cursed_paupers_finger = class(relicBaseClass)

function relic_cursed_paupers_finger:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXP_RATE_BOOST, }
end

function relic_cursed_paupers_finger:GetModifierPercentageExpRateBoost()
	return 50
end

function relic_cursed_paupers_finger:GetBonusGold()
	return -50
end