boss33b_shadowrazeN = class({})

function boss33b_shadowrazeN:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local distance = self:GetSpecialValueFor("distance")
	local radius = self:GetSpecialValueFor("radius")
	ParticleManager:FireWarningParticle(GetGroundPosition(caster:GetAbsOrigin() + caster:GetForwardVector() * distance, caster), radius)
	return true
end

function boss33b_shadowrazeN:OnSpellStart()
	local caster = self:GetCaster()
	
	local distance = self:GetSpecialValueFor("distance")
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	local razePos = caster:GetAbsOrigin() + caster:GetForwardVector() * distance
	
	local belowHPThreshold = caster:GetHealthPercent() < 50
	self:CreateRazePattern(belowHPThreshold, razePos, radius, damage)
	
	local sdDeath = not caster:IsTwinAlive()
	
	if sdDeath and caster.Holdout_IsCore then
		local duration = self:GetSpecialValueFor("sd_death_duration")
		local ogPos = caster:GetAbsOrigin()
		
		local cd = self:GetCooldownTimeRemaining()
		self:EndCooldown()
		self:StartCooldown( (cd + duration + self:GetCastPoint())*1.2 )
		
		razePos = ogPos + RandomVector(distance * 3)
		ParticleManager:FireWarningParticle(GetGroundPosition(razePos, caster), radius)
		
		Timers:CreateTimer(self:GetCastPoint(), function()
			duration = duration - self:GetCastPoint()
			self:CreateRazePattern(belowHPThreshold, razePos, radius, damage)
			razePos = ogPos + ActualRandomVector(distance * 3)
			if duration > 0 then
				ParticleManager:FireWarningParticle(GetGroundPosition(razePos, caster), radius)
				return self:GetCastPoint()
			end
		end)
	end
end

function boss33b_shadowrazeN:CreateRazePattern(hpThreshold, position, radius, damage)
	local caster = self:GetCaster()
	if hpThreshold and caster.Holdout_IsCore then
		self:CreateRaze(position, radius, damage)
		for i = 1, self:GetSpecialValueFor("phase2_cross_count") do
			local newPos = position + RotateVector2D(caster:GetForwardVector(), ToRadians(90*i)) * self:GetSpecialValueFor("distance")
			ParticleManager:FireWarningParticle(newPos, radius)
			Timers:CreateTimer(self:GetCastPoint() * 1.5, function()
				self:CreateRaze(newPos, radius, damage)
			end)
		end
	else
		self:CreateRaze(position, radius, damage)
	end
end

function boss33b_shadowrazeN:CreateRaze(position, radius, damage)
	local caster = self:GetCaster()
	ParticleManager:FireParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", PATTACH_ABSORIGIN, caster, {[0] = GetGroundPosition(position, caster), [3] = GetGroundPosition(position, caster)})
	EmitSoundOnLocationWithCaster(position, "Hero_Nevermore.Shadowraze", caster)
	local nearbyUnits = caster:FindEnemyUnitsInRadius(position, radius)
	for _, unit in ipairs(nearbyUnits) do
		if not enemy:TriggerSpellAbsorb(self) then
			self:DealDamage(caster, unit, damage)
		end
	end
end