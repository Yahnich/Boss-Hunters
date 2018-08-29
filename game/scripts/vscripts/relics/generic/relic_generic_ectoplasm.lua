relic_generic_ectoplasm = class(relicBaseClass)

function relic_generic_ectoplasm:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function relic_generic_ectoplasm:GetModifierConstantManaRegen()
	return 6
end

function relic_generic_ectoplasm:GetModifierConstantHealthRegen()
	return 6
end