boss12b_toss = class({})

function boss12b_toss:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle(self:GetCursorPosition(), self:GetSpecialValueFor("stun_radius"))
	return true
end

function boss12b_toss:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local speed = self:GetSpecialValueFor("horizontal_speed")
	local radius = self:GetSpecialValueFor("radius")
	local direction = CalculateDirection(position, caster)
	direction.z = self:GetSpecialValueFor("vertical_speed")
	
	local ProjectileHit = function(self, target, position)
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if not self.hitUnits[target:entindex()] then
			ability:DealDamage(caster, target, self.damage)
			caster:HealEvent(self.damage, ability, caster)
			EmitSoundOn("Hero_Undying.PreAttack", caster)
			ParticleManager:FireParticle("particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok_burst.vpcf", PATTACH_POINT_FOLLOW, target)
			self.hitUnits[target:entindex()] = true
		end
		return true
	end
	
	local ProjectileThink = function(self)
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local velocity = self:GetVelocity()
		local position = self:GetPosition()
		local gravity = PROJECTILE_GRAVITY
		
		
		velocity.z = velocity.z - gravity * FrameTime()
		self:SetPosition( position + (velocity*FrameTime()) )
		if velocity.z == GetGroundHeight( position, caster ) then
			self:hitBehavior()
			self:Destroy()
		end
	end
	ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {  FX = "particles/bosses/boss4/boss4_death_ball.vpcf",
																		  position = caster:GetAbsOrigin(),
																		  caster = caster,
																		  ability = self,
																		  speed = speed,
																		  radius = radius,
																		  velocity = speed * direction,
																		  damage = damage
																		  stunDuration = stunDuration
																		  isUniqueProjectile = true})
end