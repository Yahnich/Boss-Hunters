elite_hasted = class({})

function elite_hasted:GetIntrinsicModifierName()
	return "modifier_elite_hasted"
end

modifier_elite_hasted = class({})
LinkLuaModifier("modifier_elite_hasted", "elites/elite_hasted", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_hasted:OnCreated()
	self.ms = self:GetSpecialValueFor("movespeed")
end

function modifier_elite_hasted:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN, MODIFIER_PROPERTY_MOVESPEED_LIMIT, MODIFIER_PROPERTY_MOVESPEED_MAX}
end

function modifier_elite_hasted:GetModifierMoveSpeed_AbsoluteMin()
	return self.ms
end

function modifier_elite_hasted:GetModifierMoveSpeed_Limit()
	return self.ms
end

function modifier_elite_hasted:GetModifierMoveSpeed_Max()
	return self.ms
end