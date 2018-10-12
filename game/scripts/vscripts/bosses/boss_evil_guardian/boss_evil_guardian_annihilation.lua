boss_evil_guardian_annihilation = class({})

function boss_evil_guardian_annihilation:OnAbilityPhaseStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_status_immunity", {duration = self:GetCastPoint() - 0.01})
	ParticleManager:FireWarningParticle( GetGroundPosition(self:GetCaster():GetAbsOrigin(), self:GetCaster()), 600)
	return true
end

function boss_evil_guardian_annihilation:OnSpellStart()
	local caster = self:GetCaster()
	local direction = caster:GetForwardVector()
	
	local inward = true
	if RollPercentage(50) then inward = false end
	local distance = TernaryOperator( 1500, inward, 150 )
	local radius = self:GetSpecialValueFor("raze_radius")
	local damage = self:GetSpecialValueFor("raze_damage")
	local delay =  self:GetSpecialValueFor("raze_delay")
	
	local razeFactor = caster:GetHealthPercent()
	caster.getRazingFactor = caster.getRazingFactor + razeFactor
	
	local ogPos = caster:GetAbsOrigin() + distance * direction
	Timers:CreateTimer(1, function() 
		local circumference = 2 * math.pi * distance
		local razes = math.min( math.ceil(circumference / radius), 15 )
		local radVel = 360/razes
		for i = 0, razes - 1 do
			local newPos =  caster:GetAbsOrigin() + RotateVector2D(direction, ToRadians(radVel)*i) * distance
			self:CreateRaze(newPos, damage, radius, delay)
		end
		if inward then 
			distance = math.max(150, distance - radius*1.5)
			if distance > 150 then return 1 end
		else
			distance = math.min(1200, distance + radius*1.5) 
			if distance < 1200 then return 1 end
		end
		caster.getRazingFactor = caster.getRazingFactor - razeFactor
	end)
end

function boss_evil_guardian_annihilation:CreateRaze(position, damage, radius, delay)
	local razeFX = ParticleManager:CreateParticle("particles/doom_ring.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl( razeFX, 0, GetGroundPosition(position, self:GetCaster()) )
	local caster = self:GetCaster()
	Timers:CreateTimer(delay, function()
		ParticleManager:ClearParticle( razeFX )
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
			if not enemy:TriggerSpellAbsorb(self) then
				self:DealDamage(caster, enemy, damage)
			end
		end
	end)
end