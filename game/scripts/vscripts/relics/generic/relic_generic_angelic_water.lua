relic_generic_angelic_water = class(relicBaseClass)

function relic_generic_angelic_water:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT}
end

function relic_generic_angelic_water:GetModifierConstantManaRegen()
	return 10
end
