relic_generic_hammerhead = class(relicBaseClass)

function relic_generic_hammerhead:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function relic_generic_hammerhead:GetModifierPreAttack_BonusDamage()
	return 80
end