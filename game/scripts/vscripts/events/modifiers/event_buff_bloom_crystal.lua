event_buff_bloom_crystal = class(relicBaseClass)

function event_buff_bloom_crystal:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function event_buff_bloom_crystal:GetModifierExtraHealthBonus()
	return 500
end

function event_buff_bloom_crystal:GetModifierConstantHealthRegen()
	return 7
end