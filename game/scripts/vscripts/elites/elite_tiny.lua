elite_tiny = class({})

function elite_tiny:GetIntrinsicModifierName()
	return "modifier_elite_tiny"
end

modifier_elite_tiny = class({})
LinkLuaModifier("modifier_elite_tiny", "elites/elite_tiny", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_tiny:DeclareFunctions()
	return {MODIFIER_PROPERTY_MODEL_SCALE }
end

function modifier_elite_tiny:GetModifierModelScale()
	return -65
end

function relicBaseClass:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end