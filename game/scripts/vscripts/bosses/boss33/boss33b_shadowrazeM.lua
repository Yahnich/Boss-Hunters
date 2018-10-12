boss33b_shadowrazeM = class({})

function boss33b_shadowrazeM:OnAbilityPhaseStart(forceWarning, position)
	local caster = self:GetCaster()
	local distance = self:GetSpecialValueFor("distance")
	local radius = self:GetSpecialValueFor("radius")
	local belowHPThreshold = caster:GetHealthPercent() < 50 or forceWarning
	if not belowHPThreshold then
		ParticleManager:FireWarningParticle(GetGroundPosition( position or caster:GetAbsOrigin() + caster:GetForwardVector() * distance ,caster), radius)
	else
		local count = self:GetSpecialValueFor("phase2_raze_count")
		for i = 1, count do
			local newPos = (position or caster:GetAbsOrigin()) + RotateVector2D(caster:GetForwardVector(), ToRadians(360*i/count)) * distance
			ParticleManager:FireWarningParticle(GetGroundPosition(newPos, caster), radius)
		end
	end
	return true
end

function boss33b_shadowrazeM:OnSpellStart()
	local caster = self:GetCaster()
	
	local distance = self:GetSpecialValueFor("distance")
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	local razePos = caster:GetAbsOrigin() + caster:GetForwardVector() * distance
	
	local belowHPThreshold = caster:GetHealthPercent() < 50
	if belowHPThreshold then razePos = caster:GetAbsOrigin() end
	self:CreateRazePattern(belowHPThreshold, razePos, radius, damage)
	
	local sdDeath = not caster:IsTwinAlive()
	
	if sdDeath and caster.Holdout_IsCore then
		local duration = self:GetSpecialValueFor("sd_death_duration")
		local bonusRadius = self:GetSpecialValueFor("sd_death_bonus_radius")
		local cd = self:GetCooldownTimeRemaining()
		self:EndCooldown()
		self:StartCooldown( (cd + duration + self:GetCastPoint())*1.2 )
		self:OnAbilityPhaseStart(belowHPThreshold, razePos)
		Timers:CreateTimer(1, function()
			if duration > 0 then
				self:CreateRazePattern(belowHPThreshold, razePos, radius + bonusRadius, damage)
				self:OnAbilityPhaseStart(belowHPThreshold, razePos)
				duration = duration - 1
				return 1
			end
		end)
	end
end

function boss33b_shadowrazeM:CreateRazePattern(hpThreshold, position, radius, damage)
	local caster = self:GetCaster()
	if hpThreshold and caster.Holdout_IsCore then
		local count = self:GetSpecialValueFor("phase2_raze_count")
		for i = 1, count do
			local newPos = position + RotateVector2D(caster:GetForwardVector(), ToRadians(360*i/count)) * self:GetSpecialValueFor("distance")
			self:CreateRaze(newPos, radius, damage)
		end
	else
		self:CreateRaze(position, radius, damage)
	end
end

function boss33b_shadowrazeM:CreateRaze(position, radius, damage)
	local caster = self:GetCaster()
	ParticleManager:FireParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", PATTACH_ABSORIGIN, caster, {[0] = GetGroundPosition(position, caster), [3] = GetGroundPosition(position, caster)})
	EmitSoundOnLocationWithCaster(position, "Hero_Nevermore.Shadowraze", caster)
	local nearbyUnits = caster:FindEnemyUnitsInRadius(position, radius)
	for _, unit in ipairs(nearbyUnits) do
		if not unit:TriggerSpellAbsorb(self) then
			self:DealDamage(caster, unit, damage)
		end
	end
end