boss_vanguard_back_breaker = class({})

function boss_vanguard_back_breaker:GetIntrinsicModifierName()
	return "modifier_boss_vanguard_back_breaker"
end

function boss_vanguard_back_breaker:OnProjectileHit(target, position)
	if target then
		self:DealDamage(self:GetCaster(), target, self:GetCaster():GetAttackDamage(), {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
	end
end

modifier_boss_vanguard_back_breaker = class({})
LinkLuaModifier("modifier_boss_vanguard_back_breaker", "bosses/boss_wk/boss_vanguard_back_breaker", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_vanguard_back_breaker:OnCreated()
	self.procHit = self:GetSpecialValueFor("attacks_to_proc")
	self.duration = self:GetSpecialValueFor("duration")
	self.hits = 0
end

function modifier_boss_vanguard_back_breaker:OnRefresh()
	self.procHit = self:GetSpecialValueFor("attacks_to_proc")
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_boss_vanguard_back_breaker:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK}
end

function modifier_boss_vanguard_back_breaker:OnAttack(params)
	if params.attacker == self:GetParent() and not params.attacker:PassivesDisabled() then
		if self.hits > self.procHit then
			self.hits = 0
			params.target:Disarm(self:GetAbility(), params.attacker, self.duration)
			params.target:Silence(self:GetAbility(), params.attacker, self.duration)
		end
		self.hits = self.hits + 1
	end
end

function modifier_boss_vanguard_back_breaker:IsHidden()
	return true
end