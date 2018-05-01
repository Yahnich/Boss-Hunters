relic_cursed_adamantium_ingot = class({})

function relic_cursed_adamantium_ingot:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function relic_cursed_adamantium_ingot:GetModifierPhysicalArmorBonus()
	return 20
end

function relic_cursed_adamantium_ingot:GetModifierMagicalResistanceBonus()
	return -50
end

function relic_cursed_adamantium_ingot:IsHidden()
	return true
end

function relic_cursed_adamantium_ingot:IsPurgable()
	return false
end

function relic_cursed_adamantium_ingot:RemoveOnDeath()
	return false
end

function relic_cursed_adamantium_ingot:IsPermanent()
	return true
end

function relic_cursed_adamantium_ingot:AllowIllusionDuplicate()
	return true
end

function relic_cursed_adamantium_ingot:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end