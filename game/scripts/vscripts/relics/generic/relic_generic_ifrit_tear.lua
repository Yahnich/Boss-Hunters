relic_generic_ifrit_tear = class({})

function relic_generic_ifrit_tear:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function relic_generic_ifrit_tear:GetModifierSpellAmplify_Percentage()
	return 15
end

function relic_generic_ifrit_tear:GetModifierConstantHealthRegen()
	return 4
end

function relic_generic_ifrit_tear:IsHidden()
	return true
end

function relic_generic_ifrit_tear:IsPurgable()
	return false
end

function relic_generic_ifrit_tear:RemoveOnDeath()
	return false
end

function relic_generic_ifrit_tear:IsPermanent()
	return true
end

function relic_generic_ifrit_tear:AllowIllusionDuplicate()
	return true
end

function relic_generic_ifrit_tear:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end