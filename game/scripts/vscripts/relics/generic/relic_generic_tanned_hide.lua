relic_generic_tanned_hide = class({})

function relic_generic_tanned_hide:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function relic_generic_tanned_hide:GetModifierPhysicalArmorBonus()
	return 5
end

function relic_generic_tanned_hide:IsHidden()
	return true
end

function relic_generic_tanned_hide:IsPurgable()
	return false
end

function relic_generic_tanned_hide:RemoveOnDeath()
	return false
end

function relic_generic_tanned_hide:IsPermanent()
	return true
end

function relic_generic_tanned_hide:AllowIllusionDuplicate()
	return true
end

function relic_generic_tanned_hide:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end