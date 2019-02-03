relic_blood_crystal = class(relicBaseClass)

function relic_blood_crystal:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function relic_blood_crystal:GetModifierConstantHealthRegen()
	return 10
end