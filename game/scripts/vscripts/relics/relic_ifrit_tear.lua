relic_ifrit_tear = class(relicBaseClass)

function relic_ifrit_tear:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function relic_ifrit_tear:GetModifierSpellAmplify_Percentage()
	return 15
end

function relic_ifrit_tear:GetModifierConstantHealthRegen()
	return 4
end