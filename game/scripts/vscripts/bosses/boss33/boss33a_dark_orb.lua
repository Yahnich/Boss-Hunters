boss33a_dark_orb = class({})

function boss33a_dark_orb:OnAbilityPhaseStart(forceWarning, direction, position)
	local caster = self:GetCaster()
	local vDir = CalculateDirection(self:GetCursorPosition(), caster)
	if caster:GetHealthPercent() >= 50 then
		ParticleManager:FireLinearWarningParticle(caster:GetAbsOrigin(), caster:GetAbsOrigin() + vDir * self:GetTrueCastRange() )
	else
		ParticleManager:FireWarningParticle(caster:GetAbsOrigin(), self:GetTrueCastRange())
	end
	return true
end

function boss33a_dark_orb:OnSpellStart()
	local caster = self:GetCaster()
	local direction = CalculateDirection(self:GetCursorPosition(), caster)
	
	local distance = self:GetSpecialValueFor("distance")
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	local razePos = caster:GetAbsOrigin() + caster:GetForwardVector() * distance
	
	local belowHPThreshold = caster:GetHealthPercent() < 50
	local sdDeath = not caster:IsTwinAlive()
	
	local duration = self:GetSpecialValueFor("phase2_duration")
	local angleVel = self:GetSpecialValueFor("phase2_angle_velocity")
	local tick_interval = duration / (360 / angleVel)
	
	EmitSoundOn("Hero_Puck.Illusory_Orb", caster)
	
	if not belowHPThreshold or not caster.Holdout_IsCore then
		self:CreateDarkOrb(direction)
	else
		self:CreateDarkOrb(direction)
		Timers:CreateTimer(tick_interval, function()
			direction = RotateVector2D(direction, ToRadians( angleVel ) )
			self:CreateDarkOrb(direction)
			duration = duration - tick_interval
			if duration > 0 then
				return tick_interval
			end
		end)
	end
end


function boss33a_dark_orb:CreateDarkOrb(direction)
	local caster = self:GetCaster()
	local distance = self:GetTrueCastRange()
	local speed = self:GetSpecialValueFor("orb_speed")
	local radius = self:GetSpecialValueFor("orb_radius")
	local damage = self:GetSpecialValueFor("damage")
	local duration = self:GetSpecialValueFor("duration")
	
	local ProjectileHit = function(self, target, position)
		if target then
			local caster = self:GetCaster()
			local ability = self:GetAbility()
			if not self.hitUnits[target:entindex()] then
				ability:DealDamage(caster, target, self.damage)
				EmitSoundOn("Hero_Puck.IIllusory_Orb_Damage", caster)
				ParticleManager:FireParticle("particles/units/heroes/hero_puck/puck_illusory_orb_blink_out.vpcf", PATTACH_POINT_FOLLOW, target)
				target:AddNewModifier(caster, ability, "modifier_silence", {duration = duration})
				target:AddNewModifier(caster, ability, "modifier_disarmed", {duration = duration})
				self.hitUnits[target:entindex()] = true
			end
		end
		return true
	end
	
	local ProjectileThink = function(self)
		local position = self:GetPosition()
		local velocity = self:GetVelocity()
		local caster = self:GetCaster()
		if velocity.z > 0 then velocity.z = 0 end
		self:SetPosition( position + (velocity*FrameTime()) )
		local distanceCap = 0.75
		if caster:GetHealthPercent() < 50 then distanceCap = 0.4 end
		if self.distanceTravelled > self.distance * distanceCap and RollPercentage(5) and not caster:IsTwinAlive() and not caster.HasRecentlyFuckOrbed then
			caster.HasRecentlyFuckOrbed = true
			local telePos = self:GetPosition()
			ParticleManager:FireWarningParticle(telePos, 350)
			Timers:CreateTimer(0.3, function()
				FindClearSpaceForUnit(caster, telePos, true)
				ParticleManager:FireParticle("particles/units/heroes/hero_puck/puck_illusory_orb_blink_out.vpcf", PATTACH_POINT_FOLLOW, caster)
				EmitSoundOn("Hero_Puck.EtherealJaunt", caster)
				ProjectileManager:ProjectileDodge(caster)
				Timers:CreateTimer(0.3, function() caster.HasRecentlyFuckOrbed = false end)
			end)
			self:Destroy()
		end
	end
	
	ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {  FX = "particles/bosses/boss33/boss33_dark_orb.vpcf",
																		  position = caster:GetAbsOrigin(),
																		  caster = caster,
																		  ability = self,
																		  speed = speed,
																		  radius = radius,
																		  velocity = speed * direction,
																		  distance = distance,
																		  hitUnits = {},
																		  damage = damage,
																		  duration = duration})
end