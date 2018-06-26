boss_necro_plague_wave = class({})

function boss_necro_plague_wave:OnAbilityPhaseStart()
	self.direction = self:GetCaster():GetForwardVector()
	local forward = RollPercentage(50)
	if not forward then self.direction = self.direction * -1 end
	ParticleManager:FireLinearWarningParticle(self:GetCaster():GetAbsOrigin(), self:GetCaster():GetAbsOrigin() + self.direction * self:GetTrueCastRange(), self:GetSpecialValueFor("bolt_radius"))
	return true
end

function boss_necro_plague_wave:OnSpellStart()
	local caster = self:GetCaster()
	
	local direction = self.direction
	local speed = self:GetSpecialValueFor("bolt_speed")
	local radius = self:GetSpecialValueFor("bolt_radius")
	local distance = self:GetTrueCastRange()
	local spread = self:GetSpecialValueFor("bolt_angle")
	local angle = 0
	local delay = self:GetSpecialValueFor("bolt_delay")
	local endAngle = 180
	if caster:GetHealthPercent() <= 50 then endAngle = 360 end
	
	Timers:CreateTimer(function()
		EmitSoundOn("Hero_Necrolyte.Attack", caster)
		self:FireLinearProjectile("particles/death_spear.vpcf", RotateVector2D(direction, ToRadians(angle) ) * speed, distance, radius)
		self:FireLinearProjectile("particles/death_spear.vpcf", RotateVector2D(direction,  ToRadians(360-angle) ) * speed, distance, radius)
		if angle < endAngle then
			angle = angle + spread
			return delay
		end
	end)
end

function boss_necro_plague_wave:OnProjectileHit( target, position )
	if target then
		local caster = self:GetCaster()
		
		self:DealDamage( caster, target, math.max( self:GetSpecialValueFor("max_hp_damage") * target:GetHealth() / 100, 100), {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
		target:DisableHealing( self:GetSpecialValueFor("duration") )
		
		if target:IsNull() then
			if target:IsRealHero() then
				return true
			else
				return false
			end
		end
		return true
	end
end

