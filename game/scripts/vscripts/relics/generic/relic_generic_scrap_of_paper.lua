relic_generic_scrap_of_paper = class(relicBaseClass)

function relic_generic_scrap_of_paper:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function relic_generic_scrap_of_paper:GetModifierPhysicalArmorBonus()
	return 3
end

function relic_generic_scrap_of_paper:GetCooldownReduction()
	return 8
end