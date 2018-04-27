relic_generic_time_shard = class({})

function relic_generic_time_shard:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING}
end

function relic_generic_time_shard:GetModifierPercentageCooldownStacking()
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