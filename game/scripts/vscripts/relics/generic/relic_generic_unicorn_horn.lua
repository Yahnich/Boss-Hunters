relic_generic_unicorn_horn = class({})

function relic_generic_unicorn_horn:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function relic_generic_unicorn_horn:GetModifierMoveSpeedBonus_Constant()
	return 20
end

function relic_generic_unicorn_horn:GetModifierSpellAmplify_Percentage()
	return 25
end

function relic_generic_unicorn_horn:IsHidden()
	return true
end

function relic_generic_unicorn_horn:IsPurgable()
	return false
end

function relic_generic_unicorn_horn:RemoveOnDeath()
	return false
end

function relic_generic_unicorn_horn:IsPermanent()
	return true
end

function relic_generic_unicorn_horn:AllowIllusionDuplicate()
	return true
end

function relic_generic_unicorn_horn:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end