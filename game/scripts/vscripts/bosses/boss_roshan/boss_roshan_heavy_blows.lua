boss_roshan_heavy_blows = class({})

function boss_roshan_heavy_blows:GetIntrinsicModifierName()
	return "modifier_boss_roshan_heavy_blows"
end

modifier_boss_roshan_heavy_blows = class({})
LinkLuaModifier( "modifier_boss_roshan_heavy_blows", "bosses/boss_roshan/boss_roshan_heavy_blows", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_roshan_heavy_blows:OnCreated()
	self.bash = self:GetSpecialValueFor("bash_chance")
	self.duration = self:GetSpecialValueFor("bash_duration")
	self.atk_bash = self:GetSpecialValueFor("chance_increase_atk")
	self.spell_bash = self:GetSpecialValueFor("chance_increase_spell")
	self.bash_dmg = self:GetSpecialValueFor("bonus_damage") / 100
end

function modifier_boss_roshan_heavy_blows:OnRefresh()
	self:OnCreated()
end

function modifier_boss_roshan_heavy_blows:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function modifier_boss_roshan_heavy_blows:OnAttackLanded(params)
	if params.attacker == self:GetParent() and self:RollPRNG( self.bash ) then
		local ability = self:GetAbility()
		ability:DealDamage( params.attacker, params.target, params.target:GetMaxHealth() * self.bash_dmg, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
		ability:Stun(params.target, self.duration)
		self.bash = self:GetSpecialValueFor("bash_chance")
	end
end

function modifier_boss_roshan_heavy_blows:OnAttack(params)
	if params.target == self:GetParent() then
		self.bash = self.bash + self.atk_bash
	end
end