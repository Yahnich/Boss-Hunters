relic_generic_horn_of_bannermen = class({})

function relic_generic_horn_of_bannermen:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end

function relic_generic_horn_of_bannermen:GetModifierBonusStats_Agility()
	return 25
end

function relic_generic_horn_of_bannermen:IsHidden()
	return true
end

function relic_generic_horn_of_bannermen:IsPurgable()
	return false
end

function relic_generic_horn_of_bannermen:RemoveOnDeath()
	return false
end

function relic_generic_horn_of_bannermen:IsPermanent()
	return true
end

function relic_generic_horn_of_bannermen:AllowIllusionDuplicate()
	return true
end

function relic_generic_horn_of_bannermen:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end