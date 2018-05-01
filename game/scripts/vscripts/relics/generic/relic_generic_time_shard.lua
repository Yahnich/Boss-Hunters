relic_generic_time_shard = class({})

function relic_generic_time_shard:GetCooldownReduction()
	return 10
end

function relic_generic_time_shard:IsHidden()
	return true
end

function relic_generic_time_shard:IsPurgable()
	return false
end

function relic_generic_time_shard:RemoveOnDeath()
	return false
end

function relic_generic_time_shard:IsPermanent()
	return true
end

function relic_generic_time_shard:AllowIllusionDuplicate()
	return true
end

function relic_generic_time_shard:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end