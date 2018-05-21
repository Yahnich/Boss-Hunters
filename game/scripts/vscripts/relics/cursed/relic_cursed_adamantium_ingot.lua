relic_cursed_adamantium_ingot = class(relicBaseClass)

function relic_cursed_adamantium_ingot:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function relic_cursed_adamantium_ingot:GetModifierPhysicalArmorBonus()
	return 20
end

function relic_cursed_adamantium_ingot:GetModifierMagicalResistanceBonus()
	return -50
end

