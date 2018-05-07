relic_unique_eagles_beak = class({})

function relic_unique_eagles_beak:CheckState()
	return {[MODIFIER_STATE_CANNOT_MISS] = true}
end

function relic_unique_eagles_beak:IsHidden()
	return true
end

function relic_unique_eagles_beak:IsPurgable()
	return false
end

function relic_unique_eagles_beak:RemoveOnDeath()
	return false
end

function relic_unique_eagles_beak:IsPermanent()
	return true
end

function relic_unique_eagles_beak:AllowIllusionDuplicate()
	return true
end

function relic_unique_eagles_beak:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end