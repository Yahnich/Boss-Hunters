relic_generic_fog_lace = class(relicBaseClass)

function relic_generic_fog_lace:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT }
end

function relic_generic_fog_lace:GetModifierEvasion_Constant()
	return 15
end