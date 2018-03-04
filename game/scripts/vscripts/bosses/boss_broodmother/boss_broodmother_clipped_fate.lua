boss_broodmother_clipped_fate = class({})

function boss_broodmother_clipped_fate:GetIntrinsicModifierName()
	return "modifier_boss_broodmother_clipped_fate_passive"
end

modifier_boss_broodmother_clipped_fate_passive = class({})
LinkLuaModifier("modifier_boss_broodmother_clipped_fate_passive", "bosses/boss_broodmother/boss_broodmother_clipped_fate", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_broodmother_clipped_fate_passive:OnCreated()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_boss_broodmother_clipped_fate_passive:OnRefresh()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_boss_broodmother_clipped_fate_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_boss_broodmother_clipped_fate_passive:OnAttackLanded(params)
	if params.attacker == self:GetParent() and params.target and params.target.AddAbility then
		params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_boss_broodmother_clipped_fate_debuff", {duration = self.duration})
	end
end

function modifier_boss_broodmother_clipped_fate_passive:IsHidden()
	return true
end

modifier_boss_broodmother_clipped_fate_debuff = class({})
LinkLuaModifier("modifier_boss_broodmother_clipped_fate_debuff", "bosses/boss_broodmother/boss_broodmother_clipped_fate", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_broodmother_clipped_fate_debuff:OnCreated()
	self.evasion_reduction = self:GetSpecialValueFor("evasion_reduction")
	self.heal_reduction = self:GetSpecialValueFor("heal_reduction")
end

function modifier_boss_broodmother_clipped_fate_debuff:OnRefresh()
	self.evasion_reduction = self:GetSpecialValueFor("evasion_reduction")
	self.heal_reduction = self:GetSpecialValueFor("heal_reduction")
end

function modifier_boss_broodmother_clipped_fate_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function modifier_boss_broodmother_clipped_fate_debuff:GetModifierEvasion_Constant()
	return self.evasion_reduction
end

function modifier_boss_broodmother_clipped_fate_debuff:GetModifierHealAmplify_Percentage()
	return self.heal_reduction
end

function modifier_boss_broodmother_clipped_fate_debuff:GetEffectName()
	return "particles/units/heroes/hero_broodmother/broodmother_incapacitatingbite_debuff.vpcf"
end