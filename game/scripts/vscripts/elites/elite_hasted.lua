elite_hasted = class({})

function elite_hasted:GetIntrinsicModifierName()
	return "modifier_elite_hasted"
end

modifier_elite_hasted = class({})
LinkLuaModifier("modifier_elite_hasted", "elites/elite_hasted", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_hasted:OnCreated()
	self.ms = self:GetSpecialValueFor("movespeed")
	if IsServer() then
		self:AddEffect( ParticleManager:CreateParticle( "particles/units/elite_warning_special_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() ) )
	end
end

function modifier_elite_hasted:OnRefresh()
	self.ms = self:GetSpecialValueFor("movespeed")
end

function modifier_elite_hasted:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN }
end

function modifier_elite_hasted:GetModifierMoveSpeed_AbsoluteMin()
	if not self:GetParent():PassivesDisabled() then
		return self.ms
	end
end

function modifier_elite_hasted:GetEffectName()
	return "particles/generic_gameplay/rune_haste_owner.vpcf"
end

function modifier_elite_hasted:IsHidden()
	return true
end