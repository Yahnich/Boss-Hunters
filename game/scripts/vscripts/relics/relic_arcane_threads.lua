relic_arcane_threads = class(relicBaseClass)

function relic_arcane_threads:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function relic_arcane_threads:GetModifierMagicalResistanceBonus()
	return 15
end