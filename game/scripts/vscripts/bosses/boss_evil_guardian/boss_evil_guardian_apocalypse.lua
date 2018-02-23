boss_evil_guardian_apocalypse = class({})

function boss_evil_guardian_apocalypse:OnAbilityPhaseStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_status_immunity", {duration = self:GetCastPoint() - 0.01})
	ParticleManager:FireWarningParticle(self:GetCaster():GetAbsOrigin(), 600)
	return true
end

function boss_evil_guardian_apocalypse:OnSpellStart()
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
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1, {type = DOTA_UNIT_TARGET_HERO} ) ) do
		local newPos = enemy:GetAbsOrigin()
		if not inward then 
			newPos = caster:GetAbsOrigin() 
		end
		
		Timers:CreateTimer(0.2, function() 
			self:CreateRaze(newPos, damage, radius, delay)
			if inward then 
				distance = math.max(150, distance - radius*1.5)
				newPos = newPos + CalculateDirection(caster, enemy) * radius*1.5
				if distance > 150 then return 0.2 end
			else
				distance = math.min(1500, distance + radius*1.5) 
				newPos = newPos + CalculateDirection(enemy, caster) * radius*1.5
				if distance < 1500 then return 0.2 end
			end
			caster.getRazingFactor = caster.getRazingFactor - razeFactor
		end)
	end
end

function boss_evil_guardian_apocalypse:CreateRaze(position, damage, radius, delay)
	local razeFX = ParticleManager:CreateParticle("particles/doom_ring.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl( razeFX, 0, position )
	local caster = self:GetCaster()
	Timers:CreateTimer(delay, function()
		ParticleManager:ClearParticle( razeFX )
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
			self:DealDamage(caster, enemy, damage)
		end
	end)
end