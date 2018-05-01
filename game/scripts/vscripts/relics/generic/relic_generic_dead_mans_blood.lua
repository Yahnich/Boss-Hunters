relic_generic_dead_mans_blood = class({})

function relic_generic_dead_mans_blood:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS }
end

function relic_generic_dead_mans_blood:GetModifierHealthBonus()
	return 400
end

function relic_generic_dead_mans_blood:IsHidden()
	return true
end

function relic_generic_dead_mans_blood:IsPurgable()
	return false
end

function relic_generic_dead_mans_blood:RemoveOnDeath()
	return false
end

function relic_generic_dead_mans_blood:IsPermanent()
	return true
end

function relic_generic_dead_mans_blood:AllowIllusionDuplicate()
	return true
end

function relic_generic_dead_mans_blood:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end