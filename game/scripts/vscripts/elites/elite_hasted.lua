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
	return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE, MODIFIER_PROPERTY_MOVESPEED_LIMIT, MODIFIER_PROPERTY_MOVESPEED_MAX, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT }
end

function modifier_elite_hasted:GetModifierMoveSpeed_Absolute()
	return self.ms
end

function modifier_elite_hasted:GetModifierMoveSpeedBonus_Constant()
	return self.ms
end

function modifier_elite_hasted:GetModifierMoveSpeed_Limit()
	return self.ms
end

function modifier_elite_hasted:GetModifierMoveSpeed_Max()
	return self.ms
end

function modifier_elite_hasted:GetEffectName()
	return "particles/generic_gameplay/rune_haste_owner.vpcf"
end