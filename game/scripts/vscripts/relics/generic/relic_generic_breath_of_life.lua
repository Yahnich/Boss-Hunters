relic_generic_breath_of_life = class(relicBaseClass)

function relic_generic_breath_of_life:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_MANA_BONUS }
end

function relic_generic_breath_of_life:GetModifierHealthBonus()
	return 200
end

function relic_generic_breath_of_life:GetModifierConstantHealthRegen()
	return 5
end

function relic_generic_breath_of_life:GetModifierManaBonus()
	return 200
end

function relic_generic_breath_of_life:GetModifierConstantManaRegen()
	return 5
end