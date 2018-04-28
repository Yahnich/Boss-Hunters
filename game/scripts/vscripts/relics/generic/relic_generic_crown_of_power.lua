relic_generic_crown_of_power = class({})

function relic_generic_crown_of_power:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS }
end

function relic_generic_crown_of_power:GetModifierBonusStats_Intellect()
	return 25
end

function relic_generic_crown_of_power:IsHidden()
	return true
end

function relic_generic_crown_of_power:IsPurgable()
	return false
end

function relic_generic_crown_of_power:RemoveOnDeath()
	return false
end

function relic_generic_crown_of_power:IsPermanent()
	return true
end

function relic_generic_crown_of_power:AllowIllusionDuplicate()
	return true
end