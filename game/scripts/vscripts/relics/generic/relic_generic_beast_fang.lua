relic_generic_beast_fang = class(relicBaseClass)

function relic_generic_beast_fang:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function relic_generic_beast_fang:GetModifierAttackSpeedBonus()
	return 40
end

function relic_generic_beast_fang:GetModifierPreAttack_BonusDamage()
	return 40
end