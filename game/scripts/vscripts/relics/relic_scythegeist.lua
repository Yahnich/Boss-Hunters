relic_scythegeist = class(relicBaseClass)

function relic_scythegeist:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function relic_scythegeist:GetModifierPreAttack_BonusDamage()
	return 35
end

function relic_scythegeist:GetCooldownReduction()
	return 8
end