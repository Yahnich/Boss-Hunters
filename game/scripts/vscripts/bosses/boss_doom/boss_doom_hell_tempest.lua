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
	self.tornadoes = self.tornadoes or {}
end

function boss_doom_hell_tempest:OnChannelThink(dt)
	self.tornado_think = self.tornado_think + dt
	local caster = self:GetCaster()
	if self.tornado_think > self.tornado_delay then
		self.tornado_think = 0
		local projID = self:FireLinearProjectile("", self.tornado_speed * RandomVector(1), 9000, self.tornado_radius)
		local fxID = ParticleManager:CreateParticle("particles/bosses/boss_doom/hell_tempest_tornado.vpcf", PATTACH_WORLDORIGIN, nil)
		self.tornadoes[projID] = fxID
		ParticleManager:SetParticleControl( self.tornadoes[projID], 0, caster:GetAbsOrigin() )
		EmitSoundOn("Brewmaster_Storm.ProjectileImpact", caster)
		Timers:CreateTimer(15, function() ParticleManager:ClearParticle(fxID) end)
	end
end

function boss_doom_hell_tempest:OnProjectileThinkHandle( projID )
	local caster = self:GetCaster()
	if RollPercentage( 10 ) then
		local vVelocity = RotateVector2D( ProjectileManager:GetLinearProjectileVelocity(projID), ToRadians( RandomFloat(-20, 20) ) ) * self.tornado_speed
		ProjectileManager:UpdateLinearProjectileDirection( projID, vVelocity, 9000 )
	end
	local position = ProjectileManager:GetLinearProjectileLocation( projID )
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, self.tornado_radius ) ) do
		local damage = self.tornado_damage
		if enemy:InWater() then damage = damage * 0.05 end
		self:DealDamage( caster, enemy, self.tornado_damage * 0.03 )
		EmitSoundOn("Brewmaster_Storm.Attack", enemy)
		
	end
	ParticleManager:SetParticleControl( self.tornadoes[projID], 0, position )
end

function boss_doom_hell_tempest:OnProjectileHitHandle( target, position, projID )
	if not target then
		ParticleManager:ClearParticle( self.tornadoes[projID] )
		self.tornadoes[projID] = nil
	end
end