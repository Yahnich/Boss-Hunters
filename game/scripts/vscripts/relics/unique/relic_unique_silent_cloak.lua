relic_unique_silent_cloak = class({})

function relic_unique_silent_cloak:Bonus_ThreatGain()
	return -100
end

function relic_unique_silent_cloak:IsHidden()
	return true
end

function relic_unique_silent_cloak:IsPurgable()
	return false
end

function relic_unique_silent_cloak:RemoveOnDeath()
	return false
end

function relic_unique_silent_cloak:IsPermanent()
	return true
end

function relic_unique_silent_cloak:AllowIllusionDuplicate()
	return true
end

function relic_unique_silent_cloak:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end