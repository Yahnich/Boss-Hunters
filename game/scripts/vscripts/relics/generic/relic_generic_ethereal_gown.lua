relic_generic_ethereal_gown = class(relicBaseClass)

function relic_generic_ethereal_gown:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function relic_generic_ethereal_gown:GetModifierPhysicalArmorBonus()
	return 2
end

function relic_generic_ethereal_gown:GetModifierMagicalResistanceBonus()
	return 8
end

function relic_generic_ethereal_gown:GetModifierEvasion_Constant()
	return 8
end