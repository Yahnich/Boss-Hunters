undying_the_undying = class({})

function undying_the_undying:GetIntrinsicModifierName()
	return "modifier_undying_the_undying"
end

function undying_the_undying:SummonZombie( position, health, damage, duration )
	local zombie = self:GetCaster():CreateSummon("npc_dota_unit_undying_zombie", position, duration)
	zombie:AddNewModifier(self:GetCaster(), self, "modifier_undying_the_undying_zombie", {})
	zombie:SetControllableByPlayer(-1, false)
	zombie:SetCoreHealth( health )
	zombie:SetAverageBaseDamage( damage )
	return zombie
end

modifier_undying_the_undying = class({})
LinkLuaModifier( "modifier_undying_the_undying", "heroes/hero_undying/undying_the_undying", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_the_undying:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("radius")
	self.duration = self:GetTalentSpecialValueFor("duration")
	self.health_pct = self:GetTalentSpecialValueFor("health_pct") / 100
	self.damage_pct = self:GetTalentSpecialValueFor("damage_pct") / 100
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

function modifier_undying_the_undying:IsHidden()
	return true
end

modifier_undying_the_undying_zombie = class({})
LinkLuaModifier( "modifier_undying_the_undying_zombie", "heroes/hero_undying/undying_the_undying", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_undying_the_undying_zombie:OnCreated()
		self:GetParent():MoveToPositionAggressive( self:GetCaster():GetAbsOrigin() + RandomVector(350) )
		self:StartIntervalThink(3.5)
	end
	
	function modifier_undying_the_undying_zombie:OnIntervalThink()
		self:GetParent():MoveToPositionAggressive( self:GetCaster():GetAbsOrigin() + RandomVector(350) )
	end
end

function modifier_undying_the_undying_zombie:CheckState()
	return {[MODIFIER_STATE_COMMAND_RESTRICTED] = true}
end