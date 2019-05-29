relic_tanned_hide = class(relicBaseClass)

function relic_tanned_hide:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function relic_tanned_hide:GetModifierPhysicalArmorBonus()
	return 5
end