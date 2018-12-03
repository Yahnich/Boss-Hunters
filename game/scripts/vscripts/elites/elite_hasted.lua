elite_hasted = class({})

function elite_hasted:GetIntrinsicModifierName()
	return "modifier_elite_hasted"
end

modifier_elite_hasted = class({})
LinkLuaModifier("modifier_elite_hasted", "elites/elite_hasted", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_hasted:OnCreated()
	self.ms = self:GetSpecialValueFor("movespeed")
end

function modifier_elite_hasted:OnRefresh()
	self.ms = self:GetSpecialValueFor("movespeed")
end

function modifier_elite_hasted:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN }
end

function modifier_elite_hasted:GetModifierMoveSpeed_AbsoluteMin()
	return self.ms
end

function modifier_elite_hasted:GetEffectName()
	return "particles/generic_gameplay/rune_haste_owner.vpcf"
end