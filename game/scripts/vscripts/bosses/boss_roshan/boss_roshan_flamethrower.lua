boss_roshan_flamethrower = class({})

function boss_roshan_flamethrower:OnAbilityPhaseStart()
	local distance = self:GetSpecialValueFor("distance")
	local startPos = self:GetCaster():GetAbsOrigin()
	local endPos = startPos + CalculateDirection( self:GetCaster():GetCursorPosition(), startPos ) * distance
	ParticleManager:FireLinearWarningParticle( startPos, endPos, distance, 50 )
	return true
end

function boss_roshan_flamethrower:OnSpellStart()
	local caster = self:GetCaster()
	self.direction = CalculateDirection( self:GetCaster():GetCursorPosition(), caster )
	self.projectiles = self:GetSpecialValueFor("projectiles")
	self.angleOffset = -ToRadians( self:GetSpecialValueFor("angle") / 2 )
	self.angleOffsetPerProj = (self.angleOffset * 2) / self.projectiles
	self.damage = self:GetSpecialValueFor("breath_damage")
	self.speed = self:GetSpecialValueFor("speed")
	self.width = self:GetSpecialValueFor("width")
	self.distance = self:GetSpecialValueFor("distance")
	self.timeDelay = self:GetChannelTime() / self.projectiles
	self.thinker = self.timeDelay
	EmitSoundOn( "Hero_Jakiro.DualBreath.Cast", self:GetCaster() )
end

function boss_roshan_flamethrower:OnChannelThink( dt )
	self.thinker = self.thinker + dt
	if self.thinker >= self.timeDelay then
		self.thinker = 0
		self.angleOffset = self.angleOffset - self.angleOffsetPerProj
		local fireDirection = RotateVector2D( self.direction, self.angleOffset )
		self:FireLinearProjectile("particles/units/bosses/boss_roshan/boss_roshan_flamethrower.vpcf", fireDirection * self.speed, self.distance, self.width, {attach = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1 })
		EmitSoundOn( "Hero_DragonKnight.ElderDragonShoot2.Attack", self:GetCaster() )
	end
end

function boss_roshan_flamethrower:OnProjectileHit( target, position )
	if target and not target:TriggerSpellAbsorb( self ) then
		self:DealDamage( self:GetCaster(), target, self:GetSpecialValueFor("breath_damage") )
	end
end