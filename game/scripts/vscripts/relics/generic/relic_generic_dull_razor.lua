relic_generic_dull_razor = class(relicBaseClass)

function relic_generic_dull_razor:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function relic_generic_dull_razor:GetModifierBonusStats_Agility()
	return 15
end

function relic_generic_dull_razor:GetModifierPreAttack_BonusDamage()
	return 25
end