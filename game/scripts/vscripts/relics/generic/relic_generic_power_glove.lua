relic_generic_power_glove = class({})

function relic_generic_power_glove:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function relic_generic_power_glove:GetModifierPreAttack_BonusDamage()
	return 20
end

function relic_generic_power_glove:GetModifierPhysicalArmorBonus()
	return 3
end

function relic_generic_power_glove:IsHidden()
	return true
end

function relic_generic_power_glove:IsPurgable()
	return false
end

function relic_generic_power_glove:RemoveOnDeath()
	return false
end

function relic_generic_power_glove:IsPermanent()
	return true
end

function relic_generic_power_glove:AllowIllusionDuplicate()
	return true
end

function relic_generic_power_glove:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end