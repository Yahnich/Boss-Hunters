relic_unique_eagles_beak = class(relicBaseClass)

function relic_unique_eagles_beak:CheckState()
	return {[MODIFIER_STATE_CANNOT_MISS] = true}
end