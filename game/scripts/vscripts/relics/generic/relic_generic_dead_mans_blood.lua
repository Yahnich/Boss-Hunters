relic_generic_dead_mans_blood = class(relicBaseClass)

function relic_generic_dead_mans_blood:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS }
end

function relic_generic_dead_mans_blood:GetModifierHealthBonus()
	return 400
end