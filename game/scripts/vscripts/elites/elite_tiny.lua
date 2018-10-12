elite_tiny = class({})

function elite_tiny:GetIntrinsicModifierName()
	return "modifier_elite_tiny"
end

modifier_elite_tiny = class(relicBaseClass)
LinkLuaModifier("modifier_elite_tiny", "elites/elite_tiny", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_tiny:DeclareFunctions()
	return {MODIFIER_PROPERTY_MODEL_SCALE }
end

function modifier_elite_tiny:GetModifierModelScale()
	return self:GetSpecialValueFor("size")
end
