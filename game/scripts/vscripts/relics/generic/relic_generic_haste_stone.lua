relic_generic_haste_stone = class(relicBaseClass)

function relic_generic_haste_stone:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function relic_generic_haste_stone:GetModifierAttackSpeedBonus_Constant()
	return 80
end