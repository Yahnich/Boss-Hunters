relic_generic_banshee_tear = class({})

function relic_generic_banshee_tear:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS,MODIFIER_PROPERTY_MANA_REGEN_CONSTANT}
end

function relic_generic_banshee_tear:GetModifierManaBonus()
	return 500
end

function relic_generic_banshee_tear:GetModifierConstantManaRegen()
	return 1
end

function relic_generic_banshee_tear:IsHidden()
	return true
end

function relic_generic_banshee_tear:IsPurgable()
	return false
end

function relic_generic_banshee_tear:RemoveOnDeath()
	return false
end

function relic_generic_banshee_tear:IsPermanent()
	return true
end

function relic_generic_banshee_tear:AllowIllusionDuplicate()
	return true
end

function relic_generic_banshee_tear:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end