relic_stone_calendar = class(relicBaseClass)

function relic_stone_calendar:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING}
end

function relic_stone_calendar:GetModifierPhysicalArmorBonus()
	return 4
end

function relic_stone_calendar:GetModifierStatusResistanceStacking()
	return 15
end