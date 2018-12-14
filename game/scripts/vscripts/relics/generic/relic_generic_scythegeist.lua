relic_generic_scythegeist = class(relicBaseClass)

function relic_generic_scythegeist:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function relic_generic_scythegeist:GetModifierPreAttack_BonusDamage()
	return 35
end

function relic_generic_scythegeist:GetCooldownReduction()
	return 8
end