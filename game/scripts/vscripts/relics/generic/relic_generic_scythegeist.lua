relic_generic_scythegeist = class({})

function relic_generic_scythegeist:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function relic_generic_scythegeist:GetModifierPreAttack_BonusDamage()
	return 35
end

function relic_generic_scythegeist:GetCooldownReduction()
	return 5
end

function relic_generic_scythegeist:IsHidden()
	return true
end

function relic_generic_scythegeist:IsPurgable()
	return false
end

function relic_generic_scythegeist:RemoveOnDeath()
	return false
end

function relic_generic_scythegeist:IsPermanent()
	return true
end

function relic_generic_scythegeist:AllowIllusionDuplicate()
	return true
end

function relic_generic_scythegeist:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end