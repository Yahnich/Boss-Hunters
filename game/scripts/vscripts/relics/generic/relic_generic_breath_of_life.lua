relic_generic_breath_of_life = class({})

function relic_generic_breath_of_life:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_MANA_BONUS }
end

function relic_generic_breath_of_life:GetModifierHealthBonus()
	return 200
end

function relic_generic_breath_of_life:GetModifierConstantHealthRegen()
	return 5
end

function relic_generic_breath_of_life:GetModifierManaBonus()
	return 200
end

function relic_generic_breath_of_life:GetModifierConstantManaRegen()
	return 5
end

function relic_generic_breath_of_life:IsHidden()
	return true
end

function relic_generic_breath_of_life:IsPurgable()
	return false
end

function relic_generic_breath_of_life:RemoveOnDeath()
	return false
end

function relic_generic_breath_of_life:IsPermanent()
	return true
end

function relic_generic_breath_of_life:AllowIllusionDuplicate()
	return true
end

function relic_generic_breath_of_life:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end