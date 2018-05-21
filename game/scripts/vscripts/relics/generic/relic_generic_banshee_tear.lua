relic_generic_banshee_tear = class(relicBaseClass)

function relic_generic_banshee_tear:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS,MODIFIER_PROPERTY_MANA_REGEN_CONSTANT}
end

function relic_generic_banshee_tear:GetModifierManaBonus()
	return 500
end

function relic_generic_banshee_tear:GetModifierConstantManaRegen()
	return 1
end