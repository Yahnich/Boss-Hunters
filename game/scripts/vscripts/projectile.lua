Projectile = class({})


function Projectile:constructor(thinkBehavior, hitBehavior, data)
	for key, value in pairs(data) do
		self[key] = value
	end
	
	self.uniqueProjectileID = DoUniqueString("projectile")

	self.originalCaster = data.caster
	self.currentCaster = data.caster
	self.abilitySource = data.ability
	
	self.position = data.position or self.currentCaster:GetAbsOrigin()
	self.radius = data.radius or 0
	self.speed = data.speed or 0
	self.velocity = data.velocity
	
	self.aliveTime = data.aliveTime or 0
	self.duration = data.duration
	
	self.distanceTravelled = data.distanceTravelled or 0
	self.distance = data.distance
	
	self.FX = ParticleManager:CreateParticle(data.FX, PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl( self.FX, 2, Vector(self.speed,0,0) )
		ParticleManager:SetParticleControl( self.FX, 0, self.position + self.velocity * FrameTime() )
		ParticleManager:SetParticleControl( self.FX, 1, self.position )
		ParticleManager:SetParticleControl( self.FX, 3, self.position )
		ParticleManager:SetParticleControl( self.FX, 4, Vector(self.duration,0,0) )
	self.thinkBehavior = thinkBehavior
	self.hitBehavior = hitBehavior
end

function Projectile:ProjectileThink()
	self:thinkBehavior()
	ParticleManager:SetParticleControl( self.FX, 0, self:GetPosition() )
	ParticleManager:SetParticleControl( self.FX, 1, self:GetPosition() + self:GetVelocity() * FrameTime() )
	ParticleManager:SetParticleControl( self.FX, 2, Vector( self:GetSpeed(), 0, 0 ) )
	ParticleManager:SetParticleControl( self.FX, 3, self:GetPosition() )
	
	local position = self:GetPosition()
	local radius = self:GetRadius()
	local caster = self:GetCaster()
	local enemies = caster:FindEnemyUnitsInRadius(position, radius)
	if not self.isUniqueProjectile then -- generic behavior
		for _, enemy in ipairs(enemies) do
			local status, err, ret = xpcall(self.hitBehavior, debug.traceback, self, enemy, position)
			if not status then
				print(err)
				self:Remove()
			elseif not err then -- if no errors then xpcall doesn't return to err; so ret gets shoved back
				self:Remove()
				return nil
			end
		end
	end
end

function Projectile:GetOriginalCaster()
	return self.originalCaster
end

function Projectile:GetCaster()
	return self.currentCaster
end

function Projectile:SetCaster(unit)
	self.currentCaster = unit
end

function Projectile:GetAbility()
	return self.abilitySource
end

function Projectile:Remove()
	ProjectileHandler.projectiles[self.uniqueProjectileID] = nil
	ParticleManager:DestroyParticle(self.FX, false)
	ParticleManager:ReleaseParticleIndex(self.FX)
	UTIL_Remove(self)
end

function Projectile:Deflect(unit)
	local velocity = self:GetVelocity()
	local newVel = Vector(-velocity.x, -velocity.y)
	self:SetVelocity(newVel)
	return false
end

function Projectile:GetPosition()
	return self.position
end

function Projectile:SetPosition(pos)
	self.position = pos
end

function Projectile:GetVelocity()
	return self.velocity
end

function Projectile:SetVelocity(vel)
	self.velocity = vel
end

function Projectile:GetSpeed()
	return self.speed
end

function Projectile:SetSpeed(speed)
	self.speed = speed
end

function Projectile:GetRadius()
	return self.radius
end

function Projectile:SetRadius(radius)
	self.radius = radius
end
