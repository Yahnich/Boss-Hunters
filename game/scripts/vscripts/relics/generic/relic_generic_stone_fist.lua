relic_generic_stone_fist = class(relicBaseClass)

function relic_generic_stone_fist:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function relic_generic_stone_fist:Bonus_ThreatGain()
	return 20
end