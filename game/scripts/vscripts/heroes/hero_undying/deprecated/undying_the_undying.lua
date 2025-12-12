undying_the_undying = class({})

function undying_the_undying:GetIntrinsicModifierName()
	return "modifier_undying_the_undying"
end

function undying_the_undying:SummonZombie( position, health, damage, duration )
	local zombie = self:GetCaster():CreateSummon("npc_dota_unit_undying_zombie", position, duration, false)
	zombie:AddNewModifier(self:GetCaster(), self, "modifier_undying_the_undying_zombie", {})
	zombie:SetCoreHealth( health )
	zombie:SetAverageBaseDamage( damage )
	return zombie
end

modifier_undying_the_undying = class({})
LinkLuaModifier( "modifier_undying_the_undying", "heroes/hero_undying/undying_the_undying", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_the_undying:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
	self.bDuration = self:GetSpecialValueFor("boss_duration")
	self.mDuration = self:GetSpecialValueFor("mob_duration")
	self.health_pct = self:GetSpecialValueFor("health_pct") / 100
	self.damage_pct = self:GetSpecialValueFor("damage_pct") / 100
end

function modifier_undying_the_undying:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_undying_the_undying:OnDeath(params)
	if not params.unit:IsSameTeam( self:GetParent() )
	and CalculateDistance( params.unit, self:GetParent() ) <= self.radius
	and self:GetParent():IsAlive() then
		local duration = TernaryOperator( self.bDuration, params.unit:IsRoundNecessary(), self.mDuration)
		self:GetAbility():SummonZombie( params.unit:GetAbsOrigin(), params.unit:GetMaxHealth() * self.health_pct, params.unit:GetAverageBaseDamage() * self.damage_pct, duration )
	elseif params.unit:GetUnitName() == "npc_dota_unit_undying_zombie" then
		Timers:CreateTimer(3, function()
			if not params.unit:IsNull() then UTIL_Remove( params.unit ) end
		end)
	end
end

function modifier_undying_the_undying:IsHidden()
	return true
end

modifier_undying_the_undying_zombie = class({})
LinkLuaModifier( "modifier_undying_the_undying_zombie", "heroes/hero_undying/undying_the_undying", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_undying_the_undying_zombie:OnCreated()
		self.parent = self:GetParent()
		self.caster = self:GetCaster()
		self.parent:MoveToPositionAggressive( self.caster:GetAbsOrigin() + RandomVector(350) )
		self:StartIntervalThink(2)
	end
	
	function modifier_undying_the_undying_zombie:OnIntervalThink()
		self.parent:MoveToPositionAggressive( self.caster:GetAbsOrigin() + RandomVector(350) )
	end
end