relic_generic_helm_of_justice = class({})

function relic_generic_helm_of_justice:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end

function relic_generic_helm_of_justice:GetModifierBonusStats_Strength()
	return 25
end

function relic_generic_helm_of_justice:IsHidden()
	return true
end

function relic_generic_helm_of_justice:IsPurgable()
	return false
end

function relic_generic_helm_of_justice:RemoveOnDeath()
	return false
end

function relic_generic_helm_of_justice:IsPermanent()
	return true
end

function relic_generic_helm_of_justice:AllowIllusionDuplicate()
	return true
end