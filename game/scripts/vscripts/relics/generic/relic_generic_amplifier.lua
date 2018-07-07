relic_generic_amplifier = class(relicBaseClass)

function relic_generic_amplifier:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function relic_generic_amplifier:GetModifierSpellAmplify_Percentage()
	return 20
end

function relic_generic_amplifier:GetModifierStatusAmplify_Percentage()
	return 10
end