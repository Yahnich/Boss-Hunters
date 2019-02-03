relic_dead_mans_blood = class(relicBaseClass)

function relic_dead_mans_blood:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS }
end

function relic_dead_mans_blood:GetModifierExtraHealthBonus()
	return 400
end