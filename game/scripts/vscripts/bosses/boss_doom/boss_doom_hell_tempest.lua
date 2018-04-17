boss_doom_hell_tempest = class({})

function boss_doom_hell_tempest:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle(self:GetCaster():GetAbsOrigin(), 900)
	return true
end

function boss_doom_hell_tempest:OnSpellStart()
	self.tornado_radius = self:GetSpecialValueFor("radius")
	self.tornado_per_sec = self:GetSpecialValueFor("tornadoes_per_second")
	self.tornado_speed = self:GetSpecialValueFor("tornado_speed")
	self.tornado_damage = self:GetSpecialValueFor("tornado_damage")
	self.tornado_delay = 1 / self.tornado_per_sec
	self.tornado_think = 0
	self.tornadoes = {}
end

function boss_doom_hell_tempest:OnChannelThink(dt)
	self.tornado_think = self.tornado_think + dt
	if self.tornado_think > self.tornado_delay then
		self.tornado_think = 0
		local velocity = self.tornado_speed * RandomVector(1)
		self.tornadoes[self:FireLinearProjectile("particles/fire_tornado.vpcf", velocity, 9000, self.tornado_radius)] = velocity
	end
end

function boss_doom_hell_tempest:OnProjectileThinkHandle( projID )
	ProjectileManager:UpdateLinearProjectileDirection( projID, RotateVector2D( self.tornadoes[projID], ToRadians( RandomInt(-10,10) ) ), 9000 )
end