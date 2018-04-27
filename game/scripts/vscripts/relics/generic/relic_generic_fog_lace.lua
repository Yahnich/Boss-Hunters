relic_generic_fog_lace = class({})

function relic_generic_fog_lace:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT }
end

function relic_generic_fog_lace:GetModifierEvasion_Constant()
	return 15
end

function relic_generic_fog_lace:IsHidden()
	return true
end

function relic_generic_fog_lace:IsPurgable()
	return false
end

function relic_generic_fog_lace:RemoveOnDeath()
	return false
end

function relic_generic_fog_lace:IsPermanent()
	return true
end

function relic_generic_fog_lace:AllowIllusionDuplicate()
	return true
end