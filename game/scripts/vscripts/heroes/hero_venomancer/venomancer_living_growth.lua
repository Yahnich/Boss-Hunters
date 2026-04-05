venomancer_living_growth = class({})

function venomancer_living_growth:GetBehavior()
	local behavior = DOTA_ABILITY_BEHAVIOR_POINT
	if self:GetSpecialValueFor("cast_on_allies") == 1 then
		behavior = behavior + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	end
	return behavior
end

function venomancer_living_growth:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget() or self:GetCursorPosition()
	
	EmitSoundOn("Hero_Venomancer.Plague_Ward", caster)
	self:CreateWard( target )
end

function venomancer_living_growth:CreateWard( target, duration)
	local caster = self:GetCaster()
	local fDur = duration or self:GetSpecialValueFor("duration")
	local hp = self:GetSpecialValueFor("ward_hp_tooltip")
	local damage = self:GetSpecialValueFor("ward_damage_tooltip")
	
	local position = target
	if target.GetAbsOrigin then
		position = target:GetAbsOrigin()
	end
	
	local ward = caster:CreateSummon("npc_dota_venomancer_plague_ward_1", position or caster:GetAbsOrigin(), fDur)
	ward:SetCoreHealth(hp)
	ward:SetBaseHealthRegen(0)
	ward:SetModelScale( 0.8 + (self:GetLevel()-1) * 0.1 )
	ward:SetHullRadius(8)
	ward:SetRangedProjectileName("particles/units/heroes/hero_venomancer/venomancer_living_growth_projectile.vpcf")
	ResolveNPCPositions(position, 64)
	
	local entindex = nil
	if target.entindex then entindex = target:entindex() end
	ward:AddNewModifier( caster, self, "modifier_venomancer_living_growth_handler", {target = entindex})
	ward:SetAverageBaseDamage(damage, 15)
	
	if target.GetAbsOrigin then
		-- attach
		ward:SetParent( target, "attach_hitloc" )
		ward:SetLocalOrigin( RandomVector( 50 ) )
		ward:SetAbsAngles( RandomFloat( -360, 360 ), RandomFloat( -360, 360 ), RandomFloat( -360, 360 ) )
		
		if self:GetSpecialValueFor("provides_barrier") == 1 then
			target:AddNewModifier( caster, self, "modifier_venomancer_living_growth_attached", {ward = ward:entindex(), duration = fDur})
		end
	end
	
	ward:MoveToPositionAggressive( ward:GetAbsOrigin() )
end

modifier_venomancer_living_growth_handler = class({})
LinkLuaModifier( "modifier_venomancer_living_growth_handler", "heroes/hero_venomancer/venomancer_living_growth", LUA_MODIFIER_MOTION_NONE )

function modifier_venomancer_living_growth_handler:OnCreated( kv )
	self.target = kv.target
	self.explodes_on_death = self:GetSpecialValueFor("explodes_on_death") / 100
	self.explosion_radius = self:GetSpecialValueFor("explosion_radius")
	if IsServer() then
		self:StartIntervalThink( 0.5 )
	end
end

function modifier_venomancer_living_growth_handler:OnIntervalThink()
	local parent = self:GetParent()
	if parent:IsAttacking() then return end
	parent:SetAttacking( parent:FindRandomEnemyInRadius( parent:GetAbsOrigin(), parent:GetAttackRange() ) )
end

function modifier_venomancer_living_growth_handler:OnDestroy()
	if IsClient() then return end
	if self.explodes_on_death <= 0 then return end
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), self.explosion_radius ) ) do
		ability:DealDamage( caster, enemy, parent:GetMaxHealth(), {damage_type = DAMAGE_TYPE_PHYSICAL} )
	end
	ParticleManager:FireParticle("particles/units/heroes/hero_venomancer/venomancer_poison_nova.vpcf", PATTACH_POINT_FOLLOW, parent, {[1] = Vector(self.explosion_radius, 1, self.explosion_radius)} )
end

function modifier_venomancer_living_growth_handler:CheckState()
	state = {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
	if self.target then
		state[MODIFIER_STATE_NO_UNIT_COLLISION] = true
		state[MODIFIER_STATE_INVULNERABLE] = true
		state[MODIFIER_STATE_NO_HEALTH_BAR] = true
	end
	return state
end

modifier_venomancer_living_growth_attached = class({})
LinkLuaModifier( "modifier_venomancer_living_growth_attached", "heroes/hero_venomancer/venomancer_living_growth", LUA_MODIFIER_MOTION_NONE )

function modifier_venomancer_living_growth_attached:OnCreated( kv )
	self.provides_barrier = self:GetSpecialValueFor("provides_barrier")
	
	if kv.ward then
		self._attachedWard = EntIndexToHScript( kv.ward )
		self.barrier = self._attachedWard:GetMaxHealth() * self.provides_barrier
		self:SetHasCustomTransmitterData(true)
	end
end

function modifier_venomancer_living_growth_attached:OnDestroy()
	if IsServer() then
		if self._attachedWard then self._attachedWard:Destroy() end
	end
end

function modifier_venomancer_living_growth_attached:DeclareFunctions(params)
    return { MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT }
end

function modifier_venomancer_living_growth_attached:GetModifierIncomingDamageConstant( params )
	if IsServer() then
		local barrier = math.min( self.barrier, math.max( self.barrier, params.damage ) )
		self.barrier = math.max( self.barrier - params.damage, 0 )
		if self.barrier <= 0 then 
			self:Destroy()
			return
		end
		self:SendBuffRefreshToClients()
		return -barrier
	else
		return self.barrier
	end
end

function modifier_venomancer_living_growth_attached:AddCustomTransmitterData()
	return {barrier = self.barrier}
end

function modifier_venomancer_living_growth_attached:HandleCustomTransmitterData(data)
	self.barrier = data.barrier
end

function modifier_venomancer_living_growth_attached:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE 
end