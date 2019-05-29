relic_ectoplasm = class(relicBaseClass)

function relic_ectoplasm:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function relic_ectoplasm:GetModifierConstantManaRegen()
	return 6
end

function relic_ectoplasm:GetModifierConstantHealthRegen()
	return 6
end