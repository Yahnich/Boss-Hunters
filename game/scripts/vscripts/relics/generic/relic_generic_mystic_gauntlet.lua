relic_generic_mystic_gauntlet = class(relicBaseClass)

function relic_generic_mystic_gauntlet:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function relic_generic_mystic_gauntlet:GetModifierPhysicalArmorBonus()
	return 3
end

function relic_generic_mystic_gauntlet:GetModifierMagicalResistanceBonus()
	return 9
end