alchemist_volatile_brew = class({})

function alchemist_volatile_brew:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local duration = self:GetSpecialValueFor( "brew_explosion" )

	-- add brewing modifier
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_alchemist_volatile_brew_charge", -- modifier name
		{ duration = duration } -- kv
	)

	-- check sister ability
	local ability = caster:FindAbilityByName( "alchemist_volatile_brew_throw" )
	if not ability then
		ability = caster:AddAbility( "alchemist_volatile_brew_throw" )
		ability:SetStolen( true )
	end

	-- check ability level
	ability:SetLevel( self:GetLevel() )

	-- switch ability layout
	caster:SwapAbilities(
		self:GetAbilityName(),
		ability:GetAbilityName(),
		false,
		true
	)
end
LinkLuaModifier( "modifier_alchemist_volatile_brew_charge", "heroes/hero_alchemist/alchemist_volatile_brew", LUA_MODIFIER_MOTION_NONE )
modifier_alchemist_volatile_brew_charge = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_alchemist_volatile_brew_charge:IsHidden()
	return true
end

function modifier_alchemist_volatile_brew_charge:IsDebuff()
	return false
end

function modifier_alchemist_volatile_brew_charge:IsStunDebuff()
	return false
end

function modifier_alchemist_volatile_brew_charge:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_alchemist_volatile_brew_charge:OnCreated( kv )
	-- references
	self.min_stun = self:GetAbility():GetSpecialValueFor( "min_stun" )
	self.max_stun = self:GetAbility():GetSpecialValueFor( "max_stun" )
	self.min_damage = self:GetAbility():GetSpecialValueFor( "min_damage" )
	self.max_damage = self:GetAbility():GetSpecialValueFor( "max_damage" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.does_hex = self:GetAbility():GetSpecialValueFor("does_hex") / 100
	self.does_fizzle = self:GetAbility():GetSpecialValueFor("does_fizzle") ~= 0
	self.barrier_duration = self:GetAbility():GetSpecialValueFor("barrier_duration")

	if not IsServer() then return end
	self.tick_interval = 0.5
	self.tick = kv.duration
	self.tick_halfway = true

	-- Start interval
	self:StartIntervalThink( self.tick_interval )

	-- play effects
	local sound_cast = "Hero_Alchemist.UnstableConcoction.Fuse"
	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_alchemist_volatile_brew_charge:OnRefresh( kv )
	
end

function modifier_alchemist_volatile_brew_charge:OnRemoved()
end

function modifier_alchemist_volatile_brew_charge:OnDestroy()
	if not IsServer() then return end

	-- play effects
	local sound_cast = "Hero_Alchemist.UnstableConcoction.Fuse"
	StopSoundOn( sound_cast, self:GetParent() )
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_alchemist_volatile_brew_charge:OnIntervalThink()
	self.tick = self.tick - self.tick_interval
	if self.tick>0 then
		-- play tick effects
		self.tick_halfway = not self.tick_halfway
		self:PlayEffects2()
		return
	end
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local damage = self.max_damage

	-- find units in radius
	local units = nil
	if self.does_fizzle then
		units = caster:FindAllUnitsInRadius( caster:GetOrigin(), self.radius )
	else
		units = caster:FindEnemyUnitsInRadius( caster:GetOrigin(), self.radius )
	end
	for _, unit in ipairs( units ) do
		if self.does_fizzle and unit:GetTeamNumber() == caster:GetTeamNumber() then
			unit:AddNewModifier( caster, self:GetAbility(), "modifier_alchemist_volatile_brew_panacea", { duration = self.barrier_duration } )
		else
			if self.does_hex > 0 then
				unit:AddNewModifier( caster, self:GetAbility(), "modifier_sheepstick_debuff", { duration = self.max_stun * self.does_hex } )
			end
			ability:Stun( unit, self.max_stun )
			ability:DealDamage( caster, unit, damage )
		end
	end

	if not self.does_fizzle and not self:GetParent():IsInvulnerable() then
		if self.does_hex > 0 then
			parent:AddNewModifier( caster, self:GetAbility(), "modifier_sheepstick_debuff", { duration = self.max_stun * self.does_hex } )
		end
		ability:Stun( parent, self.max_stun )
		ability:DealDamage( caster, parent, damage )
	end

	-- switch ability layout
	local ability = self:GetCaster():FindAbilityByName( "alchemist_volatile_brew_throw" )
	self:GetCaster():SwapAbilities(
		self:GetAbility():GetAbilityName(),
		ability:GetAbilityName(),
		true,
		false
	)

	-- remove if stolen
	if ability:IsStolen() then
		self:GetCaster():RemoveAbilityByHandle( ability )
	end

	-- Play effects
	self:PlayEffects1( self:GetParent() )

	-- destroy
	self:Destroy()
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_alchemist_volatile_brew_charge:PlayEffects1( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_explosion.vpcf"
	local sound_cast = "Hero_Alchemist.UnstableConcoction.Stun"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, target )
end

function modifier_alchemist_volatile_brew_charge:PlayEffects2()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_timer.vpcf"

	-- Get data
	local time = math.floor( self.tick )
	local mid = 1
	if self.tick_halfway then mid = 8 end

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( 1, time, mid ) )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( 2, 0, 0 ) )

	if time<1 then
		ParticleManager:SetParticleControl( effect_cast, 2, Vector( 1, 0, 0 ) )
	end

	ParticleManager:ReleaseParticleIndex( effect_cast )
end

--------------------------------------------------------------------------------
-- THROW
--------------------------------------------------------------------------------
alchemist_volatile_brew_throw = class({})

function alchemist_volatile_brew_throw:IsStealable()
	return false
end

function alchemist_volatile_brew_throw:GetAOERadius()
	return self:GetSpecialValueFor( "midair_explosion_radius" )
end

--------------------------------------------------------------------------------
-- Ability Event
function alchemist_volatile_brew_throw:OnUpgrade()
	-- if somehow a player got cornered enough to level up Concoction during throw, sync level
	local ability = self:GetCaster():FindAbilityByName( "alchemist_volatile_brew" )
	ability:SetLevel( self:GetLevel() )
end

function alchemist_volatile_brew_throw:CastFilterResultTarget( target )
	return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber() )
end

--------------------------------------------------------------------------------
-- Ability Start
function alchemist_volatile_brew_throw:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	-- load data
	local max_brew = self:GetSpecialValueFor( "brew_time" )
	local projectile_name = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_projectile.vpcf"
	local projectile_speed = 900
	local projectile_vision = 225

	-- obtain brewing time
	local brew_time

	local modifier = caster:FindModifierByName( "modifier_alchemist_volatile_brew_charge" )
	if modifier then
		 -- cast by sister ability
		brew_time = math.min( GameRules:GetGameTime()-modifier:GetCreationTime(), max_brew )
		modifier:Destroy()

	elseif alchemist_volatile_brew_throw.reflected_brew_time then
		-- reflected
		brew_time = alchemist_volatile_brew_throw.reflected_brew_time

	elseif self.stored_brew_time then
		-- recast ( Multicast, Soul bind )
		brew_time = self.stored_brew_time

	else
		-- unknown
		brew_time = 0
	end

	--  store brew time in instance variable for later recast (e.g. Multicast)
	self.brew_time = brew_time

	-- create projectile
	local info = {
		Target = target,
		Source = caster,
		Ability = self,	
		
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bDodgeable = false,                           -- Optional
	
		bVisibleToEnemies = true,                         -- Optional
		bProvidesVision = true,                           -- Optional
		iVisionRadius = projectile_vision,                              -- Optional
		iVisionTeamNumber = caster:GetTeamNumber(),        -- Optional
		ExtraData = {
			brew_time = brew_time,
		}
	}
	ProjectileManager:CreateTrackingProjectile(info)

	-- Play effects
	local sound_cast = "Hero_Alchemist.UnstableConcoction.Throw"
	EmitSoundOn( sound_cast, caster )

	-- switch ability layout
	local ability = caster:FindAbilityByName( "alchemist_volatile_brew" )
	if not ability then return end -- reflected

	caster:SwapAbilities(
		self:GetAbilityName(),
		ability:GetAbilityName(),
		false,
		true
	)
end

--------------------------------------------------------------------------------
-- Projectile
function alchemist_volatile_brew_throw:OnProjectileHit_ExtraData( target, location, ExtraData )
	if not target then return end
	
	local caster = self:GetCaster()

	-- obtain data
	local brew_time = ExtraData.brew_time

	-- unique reflect interaction
	-- store brew time to static class variable
	alchemist_volatile_brew_throw.reflected_brew_time = brew_time
	self._lastBrewTime = brew_time

	-- check if the ability GOT TRIGGERED BY SOMETHING TRIVIAL
	local TRIGGERED = target:TriggerSpellAbsorb( self )

	-- clean up static variable
	alchemist_volatile_brew_throw.reflected_brew_time = nil

	-- calm down if you GOT TRIGGERED
	if TRIGGERED then return end

	-- load data
	local max_brew = self:GetSpecialValueFor( "brew_time" )
	local min_stun = self:GetSpecialValueFor( "min_stun" )
	local max_stun = self:GetSpecialValueFor( "max_stun" )
	local min_damage = self:GetSpecialValueFor( "min_damage" )
	local max_damage = self:GetSpecialValueFor( "max_damage" )
	local radius = self:GetSpecialValueFor( "radius" )
	local does_hex = self:GetSpecialValueFor( "does_hex" ) / 100
	local does_fizzle = self:GetSpecialValueFor( "does_fizzle" ) ~= 0

	-- calculate stun and damage
	local stun = (brew_time/max_brew)*(max_stun-min_stun) + min_stun
	local damage = (brew_time/max_brew)*(max_damage-min_damage) + min_damage
	local barrier_duration = self:GetSpecialValueFor("barrier_duration")
	
	-- find units in radius
	local units = nil
	if does_fizzle then
		units = caster:FindAllUnitsInRadius( target:GetOrigin(), radius )
	else
		units = caster:FindEnemyUnitsInRadius( target:GetOrigin(), radius )
	end
	for _, unit in pairs(units) do
		if does_fizzle and unit:GetTeamNumber() == caster:GetTeamNumber() then
			unit:AddNewModifier( caster, self, "modifier_alchemist_volatile_brew_panacea", { duration = barrier_duration } )
		else
			self:DealDamage( caster, unit, damage, {damage_type = DAMAGE_TYPE_PHYSICAL} )
			if does_hex > 0 then
				unit:AddNewModifier( caster, self, "modifier_sheepstick_debuff", { duration = stun * does_hex } )
			end
			self:Stun(unit, stun)
		end
	end

	-- Play effects
	self:PlayEffects( target )
end

------------------------------------------------------------------------------
function alchemist_volatile_brew_throw:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_alchemist/alchemist_volatile_brew_explosion.vpcf"
	local sound_cast = "Hero_Alchemist.UnstableConcoction.Stun"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, target )
end

modifier_alchemist_volatile_brew_panacea = class({})
LinkLuaModifier( "modifier_alchemist_volatile_brew_panacea", "heroes/hero_alchemist/alchemist_volatile_brew", LUA_MODIFIER_MOTION_NONE )

function modifier_alchemist_volatile_brew_panacea:OnCreated()
	self:OnRefresh()
	if IsServer() then self:SetHasCustomTransmitterData(true) end
end
function modifier_alchemist_volatile_brew_panacea:OnRefresh()
	self.barrier = self:GetSpecialValueFor("barrier")
	if IsServer() then
		self:SendBuffRefreshToClients()
	end
end
function modifier_alchemist_volatile_brew_panacea:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT
	}
end
function modifier_alchemist_volatile_brew_panacea:GetModifierIncomingDamageConstant(params)
	if IsServer() then
		local barrier = math.min( self.barrier, math.max( self.barrier, params.damage ) )
		self.barrier = math.max( 0, self.barrier - params.damage )
		if self.barrier > 0 then
			self:SendBuffRefreshToClients()
		else
			self:Destroy()
		end
		return -barrier
	else
		return self.barrier
	end
end
function modifier_alchemist_volatile_brew_panacea:AddCustomTransmitterData()
	return {
		barrier = self.barrier
	}
end
function modifier_alchemist_volatile_brew_panacea:HandleCustomTransmitterData(data)
	self.barrier = data.barrier
end