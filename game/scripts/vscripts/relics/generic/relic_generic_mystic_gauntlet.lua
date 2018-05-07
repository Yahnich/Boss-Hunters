relic_generic_mystic_gauntlet = class({})

function relic_generic_mystic_gauntlet:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function relic_generic_mystic_gauntlet:GetModifierPhysicalArmorBonus()
	return 3
end

function relic_generic_mystic_gauntlet:GetModifierMagicalResistanceBonus()
	return 9
end

function relic_generic_mystic_gauntlet:IsHidden()
	return true
end

function relic_generic_mystic_gauntlet:IsPurgable()
	return false
end

function relic_generic_mystic_gauntlet:RemoveOnDeath()
	return false
end

function relic_generic_mystic_gauntlet:IsPermanent()
	return true
end

function relic_generic_mystic_gauntlet:AllowIllusionDuplicate()
	return true
end

function relic_generic_mystic_gauntlet:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end