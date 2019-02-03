relic_hammerhead = class(relicBaseClass)

function relic_hammerhead:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function relic_hammerhead:GetModifierPreAttack_BonusDamage()
	return 80
end