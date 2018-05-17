boss_necro_plague_wave = class({})

function boss_necro_plague_wave:OnAbilityPhaseStart()
	self.direction = self:GetParent():GetForwardVector()
	if not forward then self.direction = self.direction * -1 end
	ParticleManager:FireLinearWarningParticle(self:GetCaster():GetAbsOrigin(), self:GetCaster():GetAbsOrigin() + direction * distance, radius)
	return true
end

function boss_necro_plague_wave:OnSpellStart()
	local caster = self:GetCaster()
	local forward = RollPercentage(50)
	
	local direction = self.direction
	local speed = self:GetSpecialValueFor("bolt_speed")
	local radius = self:GetSpecialValueFor("bolt_radius")
	local distance = self:GetTrueCastRange()
	local spread = self:GetSpecialValueFor("bolt_angle")
	local angle = 0
	local delay = self:GetSpecialValueFor("bolt_delay")
	
	Timers:CreateTimer(function()
		self:FireLinearProjectile("", RotateVector2D(direction, angle) * speed, distance, radius)
		self:FireLinearProjectile("", RotateVector2D(direction, -angle) * speed, distance, radius)
		if angle < 180 then
			angle = angle + spread
			return delay
		end
	end)
end

function boss_necro_plague_wave:OnProjectileHit( target, position )
	if target then
		local caster = self:GetCaster()
		
		self:DealDamage( caster, target, self:GetSpecialValueFor("bolt_damage") )
		if target:IsRealHero() then
			return false
		else
			return true
		end
	end
end

