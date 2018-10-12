boss26b_wound = class({})

function boss26b_wound:GetIntrinsicModifierName()
	return "modifier_boss26b_wound_passive"
end

modifier_boss26b_wound_passive = class({})
LinkLuaModifier("modifier_boss26b_wound_passive", "bosses/boss27/boss26b_wound.lua", 0)

function modifier_boss26b_wound_passive:OnCreated()
	self.duration = self:GetSpecialValueFor("duration")
	self.stack_damage = self:GetSpecialValueFor("stack_damage") / 100
end

function modifier_boss26b_wound_passive:OnRefresh()
	self.duration = self:GetSpecialValueFor("duration")
	self.stack_damage = self:GetSpecialValueFor("stack_damage") / 100
end

function modifier_boss26b_wound_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_boss26b_wound_passive:OnAttackLanded(params)
	if self:GetParent() == params.attacker and not params.attacker:PassivesDisabled() then
		params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_boss26b_wound_stack", {duration = self.duration})
		self:GetAbility():DealDamage(params.attacker, params.target, params.attacker:GetAttackDamage() * self.stack_damage * params.target:FindModifierByName("modifier_boss26b_wound_stack"):GetStackCount(), {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
	end
end

modifier_boss26b_wound_stack = class({})
LinkLuaModifier("modifier_boss26b_wound_stack", "bosses/boss27/boss26b_wound.lua", 0)

function modifier_boss26b_wound_stack:OnCreated()
	self:SetStackCount(1)
end

function modifier_boss26b_wound_stack:OnRefresh()
	self:IncrementStackCount()
end

function modifier_boss26b_wound_stack:GetEffectName()
	return "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_scroll_blood.vpcf"
end