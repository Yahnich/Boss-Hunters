relic_generic_blood_crystal = class({})

function relic_generic_blood_crystal:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function relic_generic_blood_crystal:GetModifierConstantHealthRegen()
	return 10
end

function relic_generic_blood_crystal:IsHidden()
	return true
end

function relic_generic_blood_crystal:IsPurgable()
	return false
end

function relic_generic_blood_crystal:RemoveOnDeath()
	return false
end

function relic_generic_blood_crystal:IsPermanent()
	return true
end

function relic_generic_blood_crystal:AllowIllusionDuplicate()
	return true
end