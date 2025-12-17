pudge_butchers_hook = class({})

--------------------------------------------------------------------------------
-- Init Abilities
function pudge_butchers_hook:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_pudge.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_pudge/pudge_meathook.vpcf", context )
end

function pudge_butchers_hook:Spawn()
	if not IsServer() then return end
end

function pudge_butchers_hook:GetBehavior()
	local behavior = DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	if self:GetSpecialValueFor("autocast") == 1 then
		behavior = behavior + DOTA_ABILITY_BEHAVIOR_AUTOCAST
	end
	if self:GetSpecialValueFor("instant_Hook") == 1 then
		behavior = behavior + DOTA_ABILITY_BEHAVIOR_IMMEDIATE 
	end
	return behavior
end

--------------------------------------------------------------------------------
-- Ability Start
function pudge_butchers_hook:OnAbilityPhaseStart()
	self:GetCaster():StartGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
end

function pudge_butchers_hook:OnAbilityPhaseInterrupted()
	self:GetCaster():FadeGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
end

function pudge_butchers_hook:GetIntrinsicModifierName()
	return "modifier_pudge_butchers_hook_autocast"
end

function pudge_butchers_hook:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	-- calculate direction
	local dir = CalculateDirection( point, caster )
	dir.z = 0
	local projectile_direction = dir:Normalized()
	
	
	self.castIDs = self.castIDs or {}
	self._latestCastID = DoUniqueString("pudge_hook")
	self.castIDs[self._latestCastID ] = {cooldown_reset = false, projectiles = {}}
	self:LaunchHook( projectile_direction )
	
	local bonusHooks = self:GetSpecialValueFor( "bonus_hooks" )
	if bonusHooks > 0 then
		local angle = 360 / (bonusHooks+1)
		for i = 1, bonusHooks do
			local newDir = RotateVector2D( projectile_direction, ToRadians( angle * i ) )
			self:LaunchHook( newDir, false )
		end
	end
	
	-- add self stun modifier
	local projectile_distance = self:GetSpecialValueFor( "hook_distance" ) + caster:GetCastRangeBonus()
	local projectile_speed = self:GetSpecialValueFor( "hook_speed" )
	local self_stun_duration_percent = self:GetSpecialValueFor( "self_stun_duration_percent" ) / 100

	local duration = (projectile_distance/projectile_speed) * self_stun_duration_percent
	local msDuration = self:GetSpecialValueFor("movespeed_duration")
	if msDuration > 0 then
		caster:AddNewModifier( caster, self, "modifier_pudge_butchers_hook_talent", {duration = msDuration})
	else
		caster:AddNewModifier( caster, self, "modifier_pudge_butchers_hook_self", {duration = duration})
	end
	
	local buffDuration = self:GetSpecialValueFor("buff_linger_duration")
	if buffDuration > 0 then
		caster:AddNewModifier( caster, self, "modifier_pudge_butchers_hook_rotten_giant", {duration = buffDuration} )
	end
end

function pudge_butchers_hook:LaunchHook( direction, bHitAllies )
	local caster = self:GetCaster()
	local origin = caster:GetAbsOrigin()
	-- load data
	local projectile_name = ""
	local projectile_distance = self:GetSpecialValueFor( "hook_distance" ) + caster:GetCastRangeBonus()
	local projectile_speed = self:GetSpecialValueFor( "hook_speed" )
	local projectile_radius = self:GetSpecialValueFor( "hook_width" )
	local pierces_enemies = self:GetSpecialValueFor("pierces_enemies") == 1
	local hitAllies = not (bHitAllies == false)
	-- calculate target
	local target = origin + direction * projectile_distance
	
	local hookDummy = caster:CreateDummy( origin )
	-- create projectiles
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = origin,
	
		bDeleteOnHit = not pierces_enemies,
	
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	
		EffectName = projectile_name,
		fDistance = projectile_distance,
		fStartRadius = projectile_radius,
		fEndRadius = projectile_radius,
		vVelocity = direction * projectile_speed,
	}
	local id = ProjectileManager:CreateLinearProjectile(info)

	self.projectiles = self.projectiles or {}
	-- create projectile data
	local data = {}
	data.cast_location = origin
	data.hook_dummy = hookDummy
	data.hitAllies = hitAllies
	data.castID = self._latestCastID
	table.insert( self.castIDs[data.castID].projectiles, id )
	self.projectiles[id] = data

	-- play effects
	self:PlayEffects( target, data )
	
	self:SetEffects2( data, hookDummy )
end

--------------------------------------------------------------------------------
-- Projectile

function pudge_butchers_hook:OnProjectileThinkHandle( handle )
	local data = self.projectiles[handle]
	local caster = self:GetCaster()

	if not data then return true end
	if data.is_tracking then
		data.hook_dummy:SetAbsOrigin( ProjectileManager:GetTrackingProjectileLocation( handle ) )
	else
		data.hook_dummy:SetAbsOrigin( ProjectileManager:GetLinearProjectileLocation( handle ) )
	end
end

function pudge_butchers_hook:OnProjectileHitHandle( target, location, handle )
	local data = self.projectiles[handle]
	local caster = self:GetCaster()

	local hook_distance = self:GetSpecialValueFor( "hook_distance" )
	if not data then return true end

	if not target then
		-- remove ref
		data.is_tracking = true
		self.projectiles[self:FireTrackingProjectile("", caster, self:GetSpecialValueFor( "hook_speed" ), {source = data.hook_dummy})] = data
		data.hook_dummy.retracting = true
		self.projectiles[handle] = nil
		-- set effects
		self:SetEffects1( data )
		if self.castIDs and self.castIDs[data.castID] and not self.castIDs[data.castID].cooldown_reset then
			self:SetCooldown( self:GetCooldownTimeRemaining() * self:GetSpecialValueFor("cooldown_reduction_pct_allied_hook") / 100 )
			self.castIDs[data.castID].cooldown_reset = true
			table.removeval( self.castIDs[data.castID].projectiles, handle )
			if #self.castIDs[data.castID].projectiles == 0 then
				self.castIDs[data.castID] = nil
			end
		end
		return true
	elseif target:HasModifier("modifier_pudge_butchers_hook_movement") then 
		return -- units can only be hit by a single hook simultaneously
	end

	if target==caster then
		if data.is_tracking then
			UTIL_Remove( data.hook_dummy )
			self.projectiles[handle] = nil
			return false
		else
			return false
		end
	end
	if target:IsSameTeam( caster ) and not data.hitAllies then return end
	
	if target:HasModifier("modifier_pudge_butchers_hook_movement") then return end -- units can only be hit by a single hook simultaneously
	-- add drag modifier
	target:RemoveModifierByName("modifier_pudge_butchers_hook_movement")
	local movement = target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_pudge_butchers_hook_movement", -- modifier name
		{ handle = data.hook_dummy:entindex(), duration = (hook_distance * 2)/self:GetSpecialValueFor("hook_speed")} -- kv
	)
	
	caster:RemoveModifierByName("modifier_pudge_butchers_hook_self")
	-- damage
	local damage = self:GetSpecialValueFor( "damage" )
	
	if not target:IsSameTeam( caster ) then
		if target:IsMinion() then
			damage = damage * (1 + self:GetSpecialValueFor("minion_damage") / 100)
		end
		self:DealDamage( caster, target, damage, {damage_type = DAMAGE_TYPE_PURE} )
		if IsEntitySafe( target ) and target:IsAlive() then
			local debuffDuration = self:GetSpecialValueFor("debuff_linger_duration")
			if debuffDuration > 0 then
				local debuff = target:AddNewModifier( caster, self, "modifier_pudge_butchers_hook_flesh_carver", {duration = debuffDuration} )
				if IsModifierSafe( movement ) then
					movement._debuffModifier = debuff
				end
			end
		end
		if self.castIDs and self.castIDs[data.castID] and not self.castIDs[data.castID].cooldown_reset then
			self.castIDs[data.castID].cooldown_reset = true
		end
	else
		if self.castIDs and self.castIDs[data.castID] and not self.castIDs[data.castID].cooldown_reset then
			self:SetCooldown( self:GetCooldownTimeRemaining() * self:GetSpecialValueFor("cooldown_reduction_pct_allied_hook") / 100 )
			self.castIDs[data.castID].cooldown_reset = true
			table.removeval( self.castIDs[data.castID].projectiles, handle )
			if #self.castIDs[data.castID].projectiles == 0 then
				self.castIDs[data.castID] = nil
			end
		end
	end

	-- add FOW
	local radius = self:GetSpecialValueFor( "vision_radius" )
	local duration = self:GetSpecialValueFor( "vision_duration" )
	AddFOWViewer( caster:GetTeamNumber(), target:GetOrigin(), radius, duration, false )

	-- set effects
	
	local allies_end = true
	local pierces_enemies = self:GetSpecialValueFor("pierces_enemies") == 1
	
	-- destroy hook
	if (not (not caster:IsSameTeam( target ) and pierces_enemies)) or (caster:IsSameTeam( target ) and allies_end) then
		-- remove ref
		data.is_tracking = true
		self.projectiles[self:FireTrackingProjectile("", caster, self:GetSpecialValueFor( "hook_speed" ), {source = data.hook_dummy})] = data
		data.hook_dummy.retracting = true
		self.projectiles[handle] = nil	
		-- set effects
		self:SetEffects1( data )
		if self.castIDs and self.castIDs[data.castID] and not self.castIDs[data.castID].cooldown_reset then
			self:SetCooldown( self:GetCooldownTimeRemaining() * self:GetSpecialValueFor("cooldown_reduction_pct_allied_hook") / 100 )
			self.castIDs[data.castID].cooldown_reset = true
			table.removeval( self.castIDs[data.castID].projectiles, handle )
			if #self.castIDs[data.castID].projectiles == 0 then
				self.castIDs[data.castID] = nil
			end
		end
		return true
	end
	return false
end

--------------------------------------------------------------------------------
-- Effects
function pudge_butchers_hook:PlayEffects( point, data )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_pudge/pudge_meathook.vpcf"
	local sound_cast = "Hero_Pudge.AttackHookExtend"

	-- Get Data
	local speed = self:GetSpecialValueFor( "hook_speed" )
	local distance = self:GetSpecialValueFor( "hook_distance" )
	local radius = self:GetSpecialValueFor( "hook_width" )
	local duration = distance/speed * 2

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_CUSTOMORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( effect_cast, 1, point )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( speed, distance, radius ) )
	ParticleManager:SetParticleControl( effect_cast, 3, Vector( duration, 0, 0 ) )
	ParticleManager:SetParticleControl( effect_cast, 4, Vector( 1, 0, 0 ) )
	ParticleManager:SetParticleControl( effect_cast, 5, Vector( 0, 0, 0 ) )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		7,
		self:GetCaster(),
		PATTACH_CUSTOMORIGIN,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleAlwaysSimulate( effect_cast )
	ParticleManager:SetParticleShouldCheckFoW( effect_cast, false )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )

	-- store effect
	data.effect_cast = effect_cast
end

function pudge_butchers_hook:SetEffects1( data )
	-- set return effect
	ParticleManager:SetParticleControlEnt(
		data.effect_cast,
		1,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( data.effect_cast )

	EmitSoundOn( "Hero_Pudge.AttackHookRetract", self:GetCaster() )
end

function pudge_butchers_hook:SetEffects2( data, target )
	-- set effects
	ParticleManager:SetParticleControlEnt(
		data.effect_cast,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( data.effect_cast, 4, Vector( 0, 0, 0 ) )
	ParticleManager:SetParticleControl( data.effect_cast, 5, Vector( 1, 0, 0 ) )

	EmitSoundOn( "Hero_Pudge.AttackHookImpact", target )
	EmitSoundOn( "Hero_Pudge.AttackHookRetract", self:GetCaster() )
end

LinkLuaModifier( "modifier_pudge_butchers_hook_self", "heroes/hero_pudge/pudge_butchers_hook", LUA_MODIFIER_MOTION_NONE )
modifier_pudge_butchers_hook_self = class({})

function modifier_pudge_butchers_hook_self:OnDestroy()
	if IsServer() then
		self:GetCaster():FadeGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
		self:GetCaster():StartGesture( ACT_DOTA_CHANNEL_ABILITY_1 )
	end
end

--------------------------------------------------------------------------------
-- Classifications
function modifier_pudge_butchers_hook_self:IsHidden()
	return true
end

function modifier_pudge_butchers_hook_self:IsDebuff()
	return false
end

function modifier_pudge_butchers_hook_self:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_pudge_butchers_hook_self:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

LinkLuaModifier( "modifier_pudge_butchers_hook_movement", "heroes/hero_pudge/pudge_butchers_hook", LUA_MODIFIER_MOTION_NONE )
modifier_pudge_butchers_hook_movement = class({})
--------------------------------------------------------------------------------
-- Classifications
function modifier_pudge_butchers_hook_movement:IsHidden()
	return false
end

function modifier_pudge_butchers_hook_movement:IsDebuff()
	return self.enemy
end

function modifier_pudge_butchers_hook_movement:IsStunDebuff()
	return true
end

function modifier_pudge_butchers_hook_movement:IsPurgable()
	return true
end

-- Optional Classifications
function modifier_pudge_butchers_hook_movement:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_pudge_butchers_hook_movement:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_pudge_butchers_hook_movement:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	-- references
	self.offset = 80
	self.threshold = 200
	self.speed = self:GetSpecialValueFor( "hook_speed" ) * (1 + self:GetSpecialValueFor("mobility_bonus") / 100)
	self.distance_to_travel = math.min( self:GetSpecialValueFor("hook_distance"), CalculateDistance( self.caster, self.parent ) + 64 )
	self.distance_to_damage = self:GetSpecialValueFor( "distance_to_damage" ) / 100 * (1+TernaryOperator( self:GetSpecialValueFor("minion_damage") / 100, self.parent:IsMinion(), 0 ))
	self.lifesteal = self:GetSpecialValueFor( "lifesteal" ) / 100

	if not IsServer() then return end
	
	self.dummy = EntIndexToHScript( kv.handle )
	
	-- get additional data
	self.enemy = self.parent:GetTeamNumber()~=self.caster:GetTeamNumber()
	self.stunned = self.enemy and (not self.parent:IsMagicImmune())
	self.interrupted = false

	-- set facing direction
	self.parent:SetForwardVector( CalculateDirection( self.caster, self.parent ) )

	-- apply motion
	if CalculateDistance( self.caster, self.parent ) > self.threshold then
		self:StartMotionController()
	end
end

function modifier_pudge_butchers_hook_movement:OnRefresh( kv )
end

function modifier_pudge_butchers_hook_movement:OnRemoved()
end

function modifier_pudge_butchers_hook_movement:OnDestroy()
	if not IsServer() then return end
	if not ( IsEntitySafe( self.parent ) and self.parent:IsAlive() ) then return end
	if self.failed then return end

	-- remove particle ref
	self:StopMotionController( )

	-- cleanup
	ResolveNPCPositions( self.parent:GetAbsOrigin(), 128 )

	-- play effects
	EmitSoundOn( "Hero_Pudge.AttackHookRetractStop", self.caster )
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_pudge_butchers_hook_movement:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE 
	}

	return funcs
end

function modifier_pudge_butchers_hook_movement:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_pudge_butchers_hook_movement:GetModifierIncomingDamage_Percentage(params)
	local caster = self:GetCaster()
	if params.attacker ~= self:GetCaster() then return end
	caster:HealEvent( params.damage * self.lifesteal, self:GetAbility(), caster, {heal_type = DOTA_HEAL_TYPE_LIFESTEAL, target = params.unit} )
end
--------------------------------------------------------------------------------
-- Status Effects
function modifier_pudge_butchers_hook_movement:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = self.stunned,
	}

	return state
end

--------------------------------------------------------------------------------
-- Motion Effects
function modifier_pudge_butchers_hook_movement:DoControlledMotion( me, dt )
	if self.interrupted then return end
	if not IsEntitySafe( self.dummy ) then 
		self:Destroy()
		return 
	end
	
	if IsModifierSafe( self._debuffModifier ) then
		self._debuffModifier:SetDuration( self._debuffModifier:GetRemainingTime() + dt * 2, true ) 
	end
	
	local hookPosition = self.dummy:GetAbsOrigin()
	local distanceLeft = CalculateDistance( me, self.caster )
	local distanceTraveled = math.min(self.speed * dt, distanceLeft)
	
	local direction = CalculateDirection( self.caster, self.parent )
	if (not self.dummy.retracting) or CalculateDistance( hookPosition, self.caster ) - distanceTraveled > distanceLeft then return end
	
	local nextpos = GetGroundPosition( hookPosition - direction * distanceTraveled, me )
	me:SetAbsOrigin( nextpos )
	self.parent:SetForwardVector( direction )
	
	if self.distance_to_damage > 0 and self.enemy then
		self:GetAbility():DealDamage( self:GetCaster(), me, distanceTraveled * self.distance_to_damage )
	end
	self.distance_to_travel = self.distance_to_travel - distanceTraveled
	-- check caster still in cast position
	if CalculateDistance(me, self.caster) > self.threshold then
	elseif self.distance_to_travel > 0 then
		self.interrupted = true
		self:Destroy()
	else
		self.interrupted = true
	end
end

LinkLuaModifier( "modifier_pudge_butchers_hook_rotten_giant", "heroes/hero_pudge/pudge_butchers_hook", LUA_MODIFIER_MOTION_NONE )
modifier_pudge_butchers_hook_rotten_giant = class({})

function modifier_pudge_butchers_hook_rotten_giant:OnCreated()
	self:OnRefresh()
end

function modifier_pudge_butchers_hook_rotten_giant:OnRefresh()
	self.bonus_armor = self:GetSpecialValueFor("bonus_armor")
	self.bonus_mr = self:GetSpecialValueFor("bonus_mr")
end

function modifier_pudge_butchers_hook_rotten_giant:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}

	return funcs
end

function modifier_pudge_butchers_hook_rotten_giant:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end

function modifier_pudge_butchers_hook_rotten_giant:GetModifierMagicalResistanceBonus()
	return self.bonus_mr
end

LinkLuaModifier( "modifier_pudge_butchers_hook_flesh_carver", "heroes/hero_pudge/pudge_butchers_hook", LUA_MODIFIER_MOTION_NONE )
modifier_pudge_butchers_hook_flesh_carver = class({})

function modifier_pudge_butchers_hook_flesh_carver:OnCreated()
	self:OnRefresh()
end

function modifier_pudge_butchers_hook_flesh_carver:OnRefresh()
	self.armor_loss = -self:GetSpecialValueFor("armor_loss")
	self.mr_loss = -self:GetSpecialValueFor("mr_loss")
	self.bleed_max_hp = -self:GetSpecialValueFor("bleed_max_hp") / 100
	self.tick = 0.5
	if IsServer() and self.bleed_max_hp > 0 then
		self:StartIntervalThink( self.tick )
	end
end

function modifier_pudge_butchers_hook_flesh_carver:OnIntervalThink()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	
	local damage = parent:GetMaxHealth() * self.bleed_max_hp * parent:GetMaxHealthDamageResistance()
	ability:DealDamage( caster, parent, damage * self.tick, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
end

function modifier_pudge_butchers_hook_flesh_carver:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}

	return funcs
end

function modifier_pudge_butchers_hook_flesh_carver:GetModifierPhysicalArmorBonus()
	return self.armor_loss
end

function modifier_pudge_butchers_hook_flesh_carver:GetModifierMagicalResistanceBonus()
	return self.mr_loss
end

LinkLuaModifier( "modifier_pudge_butchers_hook_autocast", "heroes/hero_pudge/pudge_butchers_hook", LUA_MODIFIER_MOTION_NONE )
modifier_pudge_butchers_hook_autocast = class({})

function modifier_pudge_butchers_hook_autocast:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_FINISHED}
end

function modifier_pudge_butchers_hook_autocast:OnAttackFinished( params )
	if params.attacker ~= self:GetCaster() then return end
	if not self:GetAbility():GetAutoCastState() then return end
	if not self:GetAbility():IsFullyCastable() then return end
	params.attacker:CastAbilityOnPosition( params.target:GetAbsOrigin(), self:GetAbility(), params.attacker:GetPlayerOwnerID() )
end

function modifier_pudge_butchers_hook_autocast:IsHidden()
	return true
end

modifier_pudge_butchers_hook_talent = class({})
LinkLuaModifier( "modifier_pudge_butchers_hook_talent", "heroes/hero_pudge/pudge_butchers_hook.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_pudge_butchers_hook_talent:OnCreated()
	self:OnRefresh()
end

function modifier_pudge_butchers_hook_talent:OnRefresh()
	self.evasion = self:GetSpecialValueFor("bonus_movespeed")
	self.bonus_movespeed = self:GetSpecialValueFor("bonus_movespeed")
end

function modifier_pudge_butchers_hook_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_pudge_butchers_hook_talent:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_pudge_butchers_hook_talent:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_movespeed
end