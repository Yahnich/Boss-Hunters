relic_generic_worn_spear = class(relicBaseClass)

function relic_generic_worn_spear:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
end

function relic_generic_worn_spear:GetModifierAttackRangeBonus()
	return 100
end
