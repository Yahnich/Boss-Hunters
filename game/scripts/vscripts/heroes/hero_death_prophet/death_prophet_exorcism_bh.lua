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
	local turnSpeed = 15
	local stateList = {ORBITING = 1, SEEKING = 2, RETURNING = 3}
	local direction = TernaryOperator( caster:GetRightVector(), RollPercentage(50), caster:GetRightVector() * (-1) )
	local position = caster:GetAbsOrigin() + direction * 150
	
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
			if caster:GetAttackTarget() or caster:FindRandomEnemyInRadius(caster:GetAbsOrigin(), self.seekRadius) then
				self.seekTarget = caster:GetAttackTarget() or caster:FindRandomEnemyInRadius(position, self.seekRadius)
				self.state = stateList.SEEKING
			end
		elseif self.state == stateList.SEEKING then
			if self.seekTarget and not self.seekTarget:IsNull() then
				local distance = CalculateDistance( position, self.seekTarget )
				local direction = CalculateDirection( self.seekTarget, position)
				if distance >= self.giveUpDistance then
					self.state = stateList.RETURNING
					return
				end
				
				-- direction = RotateVector2D( direction, self.turn_speed )

				self:SetVelocity( direction * speed )
				self:SetPosition( position + (velocity*FrameTime()) )
			else
				self.state = stateList.RETURNING
			end
		elseif self.state == stateList.RETURNING then
			velocity = velocity + CalculateDirection( caster, position ) * self.turn_speed + CalculateDirection( caster, position ) * self.turn_speed * (casterDistance / self.maxRadius)
			
			self:SetVelocity( velocity )
			self:SetPosition( position + (velocity*FrameTime()) )
			if casterDistance < ( self.radius + caster:GetHullRadius() ) * 2 then
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
		if target == self.seekTarget then
			self.state = stateList.RETURNING
			self.damageDealt = self.damageDealt + ability:DealDamage( caster, target, self.damage )
			self.seekTarget = nil
		end
		return true
	end
	local projectile = ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {  FX = "particles/units/heroes/hero_death_prophet/death_prophet_exorcism_ghost.vpcf",
																		  position = position,
																		  caster = caster,
																		  ability = self,
																		  speed = speed,
																		  radius = 50,
																		  velocity = speed * caster:GetForwardVector(),
																		  turn_speed = turnSpeed,
																		  state = stateList.ORBITING,
																		  orbitRadius = math.random() * radius + 50,
																		  seekRadius = radius,
																		  maxRadius = max_distance,
																		  damage = damage,
																		  giveUpDistance = give_up_distance,
																		  orientation = RandomInt(1,10),
																		  damageDealt = 0
																		  duration = duration})
	return projectile
end

modifier_death_prophet_exorcism_bh = class({})
LinkLuaModifier( "modifier_death_prophet_exorcism_bh", "heroes/hero_death_prophet/death_prophet_exorcism_bh", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_death_prophet_exorcism_bh:OnCreated()
		self.spawnRate = self:GetTalentSpecialValueFor("ghost_spawn_rate")
		self.maxGhosts = self:GetTalentSpecialValueFor("spirits")
		self:StartIntervalThink( self.spawnRate )
		self:GetCaster():EmitSound("Hero_DeathProphet.Exorcism")
		self.ghostList = {}
	end
	
	function modifier_death_prophet_exorcism_bh:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		
		if self:GetGhostCount() >= self.maxGhosts then return end
		local ghost = self:GetAbility():CreateGhost()
		table.insert( self.ghostList, ghost )
		
	end
	
	function modifier_death_prophet_exorcism_bh:OnDestroy()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		caster:StopSound("Hero_DeathProphet.Exorcism")
		if caster:HasTalent("special_bonus_unique_death_prophet_exorcism_1") then
			local respawnPosition = caster:GetAbsOrigin()
			caster:RespawnHero(false, false)
			caster:SetHealth(1)
			caster:SetAbsOrigin( respawnPosition )
		end
		local heal = 0
		for _, ghost in ipairs( self:GetGhosts() ) do
			heal = heal + ghost.damageDealt
			ghost:Remove()
		end
		caster:HealEvent( heal, ability, caster )
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

function modifier_death_prophet_exorcism_bh_talent:OnDeath()
	if params.attacker == self:GetParent() and self:GetParent():HasTalent("special_bonus_unique_death_prophet_exorcism_2") then
		local ghost = 1
		if params.unit:IsRoundBoss() then
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

