boss_axe_big_impact = class({})

function boss_axe_big_impact:GetIntrinsicModifierName()
	return "modifier_boss_axe_big_impact"
end

modifier_boss_axe_big_impact = class({})
LinkLuaModifier("modifier_boss_axe_big_impact", "bosses/boss14/boss_axe_big_impact", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_axe_big_impact:OnCreated()
	self:OnRefresh()
end

function modifier_boss_axe_big_impact:OnRefresh()
	self.duration = self:GetSpecialValueFor("duration")
	self.knockback = self:GetSpecialValueFor("knockback")
end

function modifier_boss_axe_big_impact:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_boss_axe_big_impact:OnAttackLanded( params )
	if params.attacker == self:GetParent() and params.target and params.target.GetHealth then
		params.target:Paralyze(self:GetAbility(), params.attacker, self.duration)
		params.target:ApplyKnockBack(params.attacker:GetAbsOrigin(), 0.2, 0.2, self.knockback, 0, params.attacker, self:GetAbility(), false)
	end
end