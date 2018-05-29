relic_generic_dragon_scales = class(relicBaseClass)

function relic_generic_dragon_scales:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function relic_generic_dragon_scales:GetModifierSpellAmplify_Percentage()
	return 15
end

function relic_generic_dragon_scales:GetModifierPreAttack_BonusDamage()
	return 40
end