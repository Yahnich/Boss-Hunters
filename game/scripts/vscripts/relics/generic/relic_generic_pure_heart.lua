relic_generic_pure_heart = class({})

function relic_generic_pure_heart:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function relic_generic_pure_heart:GetModifierBonusStats_Strength()
	return 15
end

function relic_generic_pure_heart:GetModifierBonusStats_Agility()
	return 15
end

function relic_generic_pure_heart:GetModifierBonusStats_Intellect()
	return 15
end

function relic_generic_pure_heart:IsHidden()
	return true
end

function relic_generic_pure_heart:IsPurgable()
	return false
end

function relic_generic_pure_heart:RemoveOnDeath()
	return false
end

function relic_generic_pure_heart:IsPermanent()
	return true
end

function relic_generic_pure_heart:AllowIllusionDuplicate()
	return true
end

function relic_generic_pure_heart:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end