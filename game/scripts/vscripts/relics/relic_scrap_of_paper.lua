relic_scrap_of_paper = class(relicBaseClass)

function relic_scrap_of_paper:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE}
end

function relic_scrap_of_paper:GetModifierPhysicalArmorBonus()
	return 3
end

function relic_scrap_of_paper:GetModifierPercentageCooldown()
	return 12
end