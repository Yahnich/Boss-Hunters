relic_scythegeist = class(relicBaseClass)

function relic_scythegeist:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE}
end

function relic_scythegeist:GetModifierPreAttack_BonusDamage()
	return 35
end

function relic_scythegeist:GetModifierPercentageCooldown()
	return 8
end