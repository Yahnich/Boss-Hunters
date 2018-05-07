relic_generic_dragon_scales = class({})

function relic_generic_dragon_scales:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function relic_generic_dragon_scales:GetModifierSpellAmplify_Percentage()
	return 15
end

function relic_generic_dragon_scales:GetModifierPreAttack_BonusDamage()
	return 40
end

function relic_generic_dragon_scales:IsHidden()
	return true
end

function relic_generic_dragon_scales:IsPurgable()
	return false
end

function relic_generic_dragon_scales:RemoveOnDeath()
	return false
end

function relic_generic_dragon_scales:IsPermanent()
	return true
end

function relic_generic_dragon_scales:AllowIllusionDuplicate()
	return true
end

function relic_generic_dragon_scales:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end