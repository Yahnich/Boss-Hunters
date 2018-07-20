undying_the_undying = class({})

function modifier_undying_the_undying:GetIntrinsicModifierName()
	return "modifier_undying_the_undying"
end

function modifier_undying_the_undying:SummonZombie( position, health, damage, duration )
	local zombie = self:GetCaster():CreateSummon("npc_dota_undying_zombie", position, duration)
	zombie:SetCoreHealth( health )
	zombie:SetAverageBaseDamage( damage )
	return zombie
end

modifier_undying_the_undying = class({})
LinkLuaModifier( "modifier_undying_the_undying", "heroes/hero_undying/undying_the_undying", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_the_undying:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("radius")
	self.duration = self:GetTalentSpecialValueFor("duration")
	self.health_pct = self:GetTalentSpecialValueFor("health_pct")
	self.damage_pct = self:GetTalentSpecialValueFor("damage_pct")
end

function modifier_undying_the_undying:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_undying_the_undying:OnDeath(params)
	if not params.unit:IsSameTeam( self:GetParent() )
	and CalculateDistance( params.unit, self:GetParent() ) <= self.radius then
		self:GetAbility():SummonZombie( params.unit:GetAbsOrigin(), params.unit:GetMaxHealth() * self.health_pct, params.unit:GetAverageBaseDamage() * self.damage_pct, self.duration )
	end
end