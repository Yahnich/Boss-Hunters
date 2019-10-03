boss_ifdat_meteor_storm = class({})

function boss_ifdat_meteor_storm:OnSpellStart()
	self.think = 0
	self.interval = 1 / self:GetSpecialValueFor("meteors_per_second")
	self.radius = self:GetSpecialValueFor("impact_radius")
	self.damage = self:GetSpecialValueFor("impact_damage")
	self.stun = self:GetSpecialValueFor("impact_stun")
end

function boss_ifdat_meteor_storm:OnChannelThink(dt)
	self.think = self.think + dt
	if self.interval <= self.think then
		local caster = self:GetCaster()
		local casterPos = caster:GetAbsOrigin()
		position = casterPos + ActualRandomVector( 1500 + self.radius, self.radius)
		for _, unit in ipairs( caster:FindEnemyUnitsInRadius( casterPos, 1800 ) ) do
			if RollPercentage( 20 ) then
				position = unit:GetAbsOrigin()
			end
		end
		self:FireMeteor( position, self.radius )
		self.think = 0
	end
end


function boss_ifdat_meteor_storm:FireMeteor(point, radius)
	local caster = self:GetCaster()
	ParticleManager:FireParticle("particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf", PATTACH_POINT, caster, {[0]=point+Vector(0,0,1000),[1]=point,[2]=Vector(1.3,0,0)}) --1.3 is the particle land time
	Timers:CreateTimer(1.3, function()
        EmitSoundOnLocationWithCaster(point, "Hero_Invoker.ChaosMeteor.Impact", caster)
        ParticleManager:FireParticle("particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf", PATTACH_POINT, caster, {[0]=point, [1]=Vector(radius,radius,radius)}) --1.3 is the particle land time
        local enemies = caster:FindEnemyUnitsInRadius(point, radius, {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
        for _,enemy in pairs(enemies) do
            self:DealDamage(caster, enemy, self.damage)
			if not enemy:IsStunned() then
				self:Stun(enemy, self.stun, false)
			end
        end
	end)
end