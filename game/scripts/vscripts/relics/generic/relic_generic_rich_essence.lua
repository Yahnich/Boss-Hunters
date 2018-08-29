relic_generic_rich_essence = class(relicBaseClass)

function relic_generic_rich_essence:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE , MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function relic_generic_rich_essence:GetModifierSpellAmplify_Percentage()
	return 10
end

function relic_generic_rich_essence:GetModifierHealAmplify_Percentage()
	return 10
end