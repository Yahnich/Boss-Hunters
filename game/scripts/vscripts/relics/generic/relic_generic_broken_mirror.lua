relic_generic_broken_mirror = class({})

function relic_generic_broken_mirror:DeclareFunctions()
	return {MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING }
end

function relic_generic_broken_mirror:GetModifierCastRangeBonusStacking()
	return 150
end

function relic_generic_broken_mirror:IsHidden()
	return true
end

function relic_generic_broken_mirror:IsPurgable()
	return false
end

function relic_generic_broken_mirror:RemoveOnDeath()
	return false
end

function relic_generic_broken_mirror:IsPermanent()
	return true
end

function relic_generic_broken_mirror:AllowIllusionDuplicate()
	return true
end

function relic_generic_broken_mirror:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end