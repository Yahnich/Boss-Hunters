boss_evil_guardian_destruction = class({})

function boss_evil_guardian_destruction:OnAbilityPhaseStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_status_immunity", {duration = self:GetCastPoint() - 0.01})
	ParticleManager:FireWarningParticle(self:GetCaster():GetAbsOrigin(), 600)
	return true
end

function boss_evil_guardian_destruction:OnSpellStart()
	local caster = self:GetCaster()
	local direction = caster:GetForwardVector()
	
	local inward = TernaryOperator(true, RollPercentage(50), false)
	local distance = TernaryOperator( 1200, inward, 150 )
	local radius = self:GetSpecialValueFor("raze_radius")
	local damage = self:GetSpecialValueFor("raze_damage")
	local delay =  self:GetSpecialValueFor("raze_delay")
	local lines =  self:GetSpecialValueFor("lines")
	local duration = self:GetSpecialValueFor("duration")
	
	local razeFactor = caster:GetHealthPercent()
	caster.getRazingFactor = caster.getRazingFactor + razeFactor
	
	for i = 1, lines do
		local vDir = RotateVector2D(caster:GetForwardVector(), ToRadians(RandomInt(1, 360)))
		local newPos = caster:GetAbsOrigin() + vDir * radius
		Timers:CreateTimer(0.2, function()
			self:CreateRaze(newPos, damage, radius, delay)
			vDir = RotateVector2D(vDir, ToRadians(RandomInt(-15, 15)))
			newPos = newPos + vDir * radius
			if duration > 0 then
				duration = duration - 0.2
				return 0.2
			end
		end)
	end
	Timers:CreateTimer(duration, function() 
		caster.getRazingFactor = caster.getRazingFactor - razeFactor
	end)
end

function boss_evil_guardian_destruction:CreateRaze(position, damage, radius, delay)
	local caster = self:GetCaster()
	local razeFX = ParticleManager:CreateParticle("particles/doom_ring.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl( razeFX, 0, GetGroundPosition(position, caster) )
	Timers:CreateTimer(delay, function()
		ParticleManager:ClearParticle( razeFX )
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
			self:DealDamage(caster, enemy, damage)
		end
	end)
end