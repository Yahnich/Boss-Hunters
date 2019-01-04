death_prophet_exorcism_bh = class({})

function death_prophet_exorcism_bh:GetIntrinsicModifierName()
	return "modifier_death_prophet_exorcism_bh_talent"
end

function death_prophet_exorcism_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	caster:RemoveModifierByName("modifier_death_prophet_exorcism_bh")
	caster:AddNewModifier( caster, self, "modifier_death_prophet_exorcism_bh", {duration = self:GetDuration()})
	
	caster:EmitSound("Hero_DeathProphet.Exorcism.Cast")
	ParticleManager:FireParticle("particles/units/heroes/hero_death_prophet/death_prophet_spawn.vpcf", PATTACH_POINT_FOLLOW, caster)
end

function death_prophet_exorcism_bh:CreateGhost(position, duration)
	local caster = self:GetCaster()
	local vPos = position or caster:GetAbsOrigin()
	
	local speed = self:GetTalentSpecialValueFor("spirit_speed")
	local radius = self:GetTalentSpecialValueFor("radius")
	local give_up_distance = self:GetTalentSpecialValueFor("give_up_distance")
	local max_distance = self:GetTalentSpecialValueFor("max_distance")
	local damage = self:GetTalentSpecialValueFor("average_damage")
	local damageType = TernaryOperator( DAMAGE_TYPE_PURE, caster:HasScepter(), DAMAGE_TYPE_PHYSICAL )
	local turnSpeed = 150
	local stateList = {ORBITING = 1, SEEKING = 2, RETURNING = 3}
	local direction = TernaryOperator( caster:GetRightVector(), RollPercentage(50), caster:GetRightVector() * (-1) )
	local position = caster:GetAbsOrigin() + direction * 180
	
	caster.nearbyEnemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius )
	local ProjectileThink = function(self)
		local position = self:GetPosition()
		local velocity = self:GetVelocity()
		local speed = self:GetSpeed()
		local caster = self:GetCaster()
		local casterDistance = CalculateDistance( caster, position )
		if velocity.z > 0 then velocity.z = 0 end
		if self.state == stateList.ORBITING then
			local distance = self.orbitRadius - casterDistance
			local direction = CalculateDirection( position, caster)
			self:SetVelocity( GetPerpendicularVector( direction ) * speed * (-1)^self.orientation + direction * distance )
			self:SetPosition( position + (velocity*FrameTime()) )
			if caster:GetAttackTarget() or caster.nearbyEnemies[RandomInt(1, #caster.nearbyEnemies)] then
				self.seekTarget = caster:GetAttackTarget() or caster.nearbyEnemies[RandomInt(1, #caster.nearbyEnemies)]
				self.state = stateList.SEEKING
			end
		elseif self.state == stateList.SEEKING then
			if self.seekTarget and self.seekTarget:IsAlive() and not self.seekTarget:IsNull() then
				local distance = CalculateDistance( position, self.seekTarget )
				local targetPos = self.seekTarget:GetAbsOrigin()
				local direction = CalculateDirection( self.seekTarget, position)
				local distVect = distance * direction
				local comparator = velocity - distVect
				
				local angle = math.deg( math.atan2(distVect.y, distVect.x) - math.atan2(velocity.y, velocity.x) )
				if angle > 360 then
					angle = angle - 360
				end
				local sign = -1
				if angle > 0 then
					sign = 1
				end
				angle = math.abs( angle )
				local direction = RotateVector2D( velocity, ToRadians( math.min( self.turn_speed, angle ) ) * FrameTime() )
				self:SetVelocity( direction * speed + CalculateDirection( self.seekTarget, position ) * math.max(100, (350 - distance) ) )
				self:SetPosition( position + (velocity*FrameTime()) )
			else
				self.state = stateList.RETURNING
			end
		elseif self.state == stateList.RETURNING then
			local distance = CalculateDistance( position, caster )
			local targetPos = caster:GetAbsOrigin()
			local direction = CalculateDirection( caster, position)
			local distVect = distance * direction
			local comparator = velocity - distVect
			
			local angle = math.deg( math.atan2(distVect.y, distVect.x) - math.atan2(velocity.y, velocity.x) )
			if angle > 360 then
				angle = angle - 360
			end
			local sign = -1
			if angle > 0 then
				sign = 1
			end
			angle = math.abs( angle )
			local direction = RotateVector2D( velocity, math.min( self.turn_speed, angle ) * sign * FrameTime() )
			self:SetVelocity( direction * speed + CalculateDirection( caster, position ) * math.max(100, (350 - distance) ) )
			self:SetPosition( position + (velocity*FrameTime()) )
			if casterDistance < ( self.radius + caster:GetHullRadius() ) then
				self.state = stateList.ORBITING
			end
		end
		if casterDistance > self.maxRadius then
			self:Remove()
		end
	end
	
	local ProjectileHit = function(self, target, position)
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if self.seekTarget then
			self.state = stateList.RETURNING
			self.damageDealt = self.damageDealt + ability:DealDamage( caster, target, self.damage, {damage_type = self.damageType} )
			self.seekTarget = nil
		end
		return true
	end
	local projectile = ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {  FX = "particles/units/heroes/hero_death_prophet/death_prophet_exorcism_ghost.vpcf",
																		  position = position,
																		  caster = caster,
																		  ability = self,
																		  speed = speed,
																		  radius = 10,
																		  velocity = speed * caster:GetForwardVector(),
																		  turn_speed = turnSpeed,
																		  state = stateList.ORBITING,
																		  orbitRadius = math.random() * radius + 50,
																		  maxRadius = max_distance,
																		  damage = damage,
																		  damageType = damageType,
																		  giveUpDistance = give_up_distance,
																		  orientation = RandomInt(1,10),
																		  damageDealt = 0,
																		  duration = duration})
	return projectile
end

modifier_death_prophet_exorcism_bh = class({})
LinkLuaModifier( "modifier_death_prophet_exorcism_bh", "heroes/hero_death_prophet/death_prophet_exorcism_bh", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_death_prophet_exorcism_bh:OnCreated()
		self.spawnRate = self:GetTalentSpecialValueFor("ghost_spawn_rate")
		self.maxGhosts = self:GetTalentSpecialValueFor("spirits")
		self.seekRadius = self:GetTalentSpecialValueFor("radius")
		self:StartIntervalThink( self.spawnRate )
		self:GetCaster():EmitSound("Hero_DeathProphet.Exorcism")
		self.ghostList = {}
	end
	
	function modifier_death_prophet_exorcism_bh:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		
		caster.nearbyEnemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self.seekRadius)
		if self:GetGhostCount() >= self.maxGhosts then return end
		local ghost = self:GetAbility():CreateGhost()
		table.insert( self.ghostList, ghost )
	end
	
	function modifier_death_prophet_exorcism_bh:OnDestroy()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		caster:StopSound("Hero_DeathProphet.Exorcism")
		if not caster:IsAlive() and caster:HasTalent("special_bonus_unique_death_prophet_exorcism_1") then
			local respawnPosition = caster:GetAbsOrigin()
			caster:RespawnHero(false, false)
			caster:SetHealth(1)
			caster:SetAbsOrigin( respawnPosition )
		end
		if caster:IsAlive() then
			local heal = 0
			for _, ghost in ipairs( self:GetGhosts() ) do
				heal = heal + ghost.damageDealt
				ghost:Remove()
			end
			caster:HealEvent( heal, ability, caster )
		end
	end
	
	function modifier_death_prophet_exorcism_bh:GetGhosts()
		return self.ghostList
	end

	function modifier_death_prophet_exorcism_bh:GetGhostCount()
		for i = #self.ghostList, 1, -1 do
			if not ProjectileHandler.projectiles[self.ghostList[i].uniqueProjectileID] then
				table.remove(self.ghostList, i)
			end
		end
		return #self.ghostList
	end
end

modifier_death_prophet_exorcism_bh_talent = class({})
LinkLuaModifier( "modifier_death_prophet_exorcism_bh_talent", "heroes/hero_death_prophet/death_prophet_exorcism_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_death_prophet_exorcism_bh_talent:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_death_prophet_exorcism_bh_talent:OnDeath(params)
	if params.attacker == self:GetParent() and self:GetParent():HasTalent("special_bonus_unique_death_prophet_exorcism_2") then
		local ghosts = 1
		if params.unit:IsRoundNecessary() then
			ghosts = 4
		end
		for i = 1, ghosts do
			self:GetAbility():CreateGhost( params.unit:GetAbsOrigin(), self:GetAbility():GetDuration() )
		end
	end
end

function modifier_death_prophet_exorcism_bh_talent:IsHidden()
	return true
end

function modifier_death_prophet_exorcism_bh_talent:IsPurgable()
	return false
end

function modifier_death_prophet_exorcism_bh_talent:RemoveOnDeath()
	return false
end

