relic_generic_unicorn_horn = class(relicBaseClass)

function relic_generic_unicorn_horn:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function relic_generic_unicorn_horn:GetModifierMoveSpeedBonus_Constant()
	return 20
end

function relic_generic_unicorn_horn:GetModifierSpellAmplify_Percentage()
	return 25
end