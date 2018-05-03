relic_generic_worn_spear = class({})

function relic_generic_worn_spear:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
end

function relic_generic_worn_spear:GetModifierAttackRangeBonus()
	return 100
end

function relic_generic_worn_spear:IsHidden()
	return true
end

function relic_generic_worn_spear:IsPurgable()
	return false
end

function relic_generic_worn_spear:RemoveOnDeath()
	return false
end

function relic_generic_worn_spear:IsPermanent()
	return true
end

function relic_generic_worn_spear:AllowIllusionDuplicate()
	return true
end

function relic_generic_worn_spear:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end