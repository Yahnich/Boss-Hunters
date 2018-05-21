relic_generic_broken_mirror = class(relicBaseClass)

function relic_generic_broken_mirror:DeclareFunctions()
	return {MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING }
end

function relic_generic_broken_mirror:GetModifierCastRangeBonusStacking()
	return 150
end