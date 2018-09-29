boss33b_shadowrazeF = class({})


function boss33b_shadowrazeF:OnAbilityPhaseStart(forceWarning, direction, position)
	local caster = self:GetCaster()
	local distance = self:GetSpecialValueFor("distance")
	local radius = self:GetSpecialValueFor("radius")
	local belowHPThreshold = caster:GetHealthPercent() < 50 or forceWarning
	local vDir = direction or caster:GetForwardVector()
	local vPos = position or caster:GetAbsOrigin() + vDir * distance
	if not belowHPThreshold then
		ParticleManager:FireWarningParticle(GetGroundPosition( (position or caster:GetAbsOrigin()) + vDir * distance, caster), radius)
	else
		ParticleManager:FireLinearWarningParticle(vPos, vPos  + vDir * (distance/3) * self:GetSpecialValueFor("phase2_raze_count"), radius)
	end
	return true
end

function boss33b_shadowrazeF:OnSpellStart()
	local caster = self:GetCaster()
	
	local distance = self:GetSpecialValueFor("distance")
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	local razePos = caster:GetAbsOrigin() + caster:GetForwardVector() * distance
	
	local belowHPThreshold = caster:GetHealthPercent() < 50
	self:CreateRazePattern(belowHPThreshold, razePos, radius, damage)
	
	local sdDeath = not caster:IsTwinAlive()
	
	if sdDeath and caster.Holdout_IsCore then
		local degrees = 360
		local angleDiff = 72
		local cd = self:GetCooldownTimeRemaining()
		local vDir = CalculateDirection(razePos, caster)
		local ogPos = caster:GetAbsOrigin()
		local bonusRadius = self:GetSpecialValueFor("sd_death_bonus_radius")
		self:EndCooldown()
		self:StartCooldown( (cd + 8 + self:GetCastPoint())*1.2 )
		self:OnAbilityPhaseStart(belowHPThreshold, RotateVector2D(vDir, ToRadians(angleDiff)), ogPos)
		Timers:CreateTimer(1, function()
			vDir = RotateVector2D(vDir, ToRadians(angleDiff))
			razePos = ogPos + vDir * distance
			self:CreateRazePattern(belowHPThreshold, razePos, radius + bonusRadius, damage, ogPos)
			degrees = degrees - angleDiff
			if degrees > 0 then 
				self:OnAbilityPhaseStart(belowHPThreshold, RotateVector2D(vDir, ToRadians(angleDiff)), ogPos)
				return 1 
			end
		end)
	end
end

function boss33b_shadowrazeF:CreateRazePattern(hpThreshold, position, radius, damage, ogPos)
	local caster = self:GetCaster()
	if hpThreshold and caster.Holdout_IsCore then
		local count = self:GetSpecialValueFor("phase2_raze_count")
		for i = -3, count do
			local newPos = position + CalculateDirection(position, ogPos or caster) * (self:GetSpecialValueFor("distance")/3) * i
			self:CreateRaze(newPos, radius, damage)
		end
	else
		self:CreateRaze(position, radius, damage)
	end
end

function boss33b_shadowrazeF:CreateRaze(position, radius, damage)
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