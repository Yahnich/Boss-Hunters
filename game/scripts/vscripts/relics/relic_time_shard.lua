relic_time_shard = class(relicBaseClass)

function relic_time_shard:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE}
end

function relic_time_shard:GetModifierPercentageCooldown()
	return 15
end