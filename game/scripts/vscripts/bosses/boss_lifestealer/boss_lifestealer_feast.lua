boss_lifestealer_feast = class({})

function boss_lifestealer_feast:GetIntrinsicModifierName()
	return "modifier_boss_lifestealer_feast"
end

modifier_boss_lifestealer_feast = class({})
LinkLuaModifier( "modifier_boss_lifestealer_feast", "bosses/boss_lifestealer/boss_lifestealer_feast", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_lifestealer_feast:OnCreated()
	self.damage = self:GetSpecialValueFor("max_hp_damage") / 100 
end

function modifier_boss_lifestealer_feast:OnRefresh()
	self.damage = self:GetSpecialValueFor("max_hp_damage") / 100 
end

function modifier_boss_lifestealer_feast:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_boss_lifestealer_feast:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		local bonusDamage = params.target:GetMaxHealth() * self.damage
		local ability = self:GetAbility()
		local heal = ability:DealDamage( params.attacker, params.target, bonusDamage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
		params.attacker:HealEvent( heal, ability, params.attacker )
	end
end

function modifier_boss_lifestealer_feast:IsHidden()
	return true
end