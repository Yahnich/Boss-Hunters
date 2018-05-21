relic_generic_power_glove = class(relicBaseClass)

function relic_generic_power_glove:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function relic_generic_power_glove:GetModifierPreAttack_BonusDamage()
	return 20
end

function relic_generic_power_glove:GetModifierPhysicalArmorBonus()
	return 3
end