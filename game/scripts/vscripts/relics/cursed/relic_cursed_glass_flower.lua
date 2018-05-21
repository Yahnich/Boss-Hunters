relic_cursed_glass_flower = class(relicBaseClass)

function relic_cursed_glass_flower:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function relic_cursed_glass_flower:GetModifierIncomingDamage_Percentage()
	return 50
end

function relic_cursed_glass_flower:GetModifierSpellAmplify_Percentage()
	return 100
end