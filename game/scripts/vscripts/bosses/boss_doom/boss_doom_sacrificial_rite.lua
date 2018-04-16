boss_doom_sacrificial_rite = class({})

function boss_doom_sacrificial_rite:GetIntrinsicModifierName()
	return "modifier_boss_doom_sacrificial_rite"
end

function boss_doom_sacrificial_rite:ShouldUseResources()
	return true
end

modifier_boss_doom_sacrificial_rite = class({})
LinkLuaModifier("modifier_boss_doom_sacrificial_rite", "bosses/boss_doom/boss_doom_sacrificial_rite", LUA_MODIFIER_MOTION_NONE)


function modifier_boss_doom_sacrificial_rite:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
	self.delay = self:GetSpecialValueFor("delay")
	self.damage = self:GetSpecialValueFor("damage")
	self.duration = self:GetSpecialValueFor("duration")
	self.threshold = self:GetSpecialValueFor("hp_threshold") / 100
end

function modifier_boss_doom_sacrificial_rite:OnRefresh()
	self.radius = self:GetSpecialValueFor("radius")
	self.delay = self:GetSpecialValueFor("delay")
	self.damage = self:GetSpecialValueFor("damage")
	self.duration = self:GetSpecialValueFor("duration")
	self.threshold = self:GetSpecialValueFor("hp_threshold") / 100
end

function modifier_boss_doom_sacrificial_rite:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_boss_doom_sacrificial_rite:OnTakeDamage(params)
	if params.unit == self:GetParent() then
		self.dmgTaken = (self.dmgTaken or 0) + params.damage
		if self.dmgTaken > params.unit:GetMaxHealth() * self.threshold then
			self.dmgTaken = 0
			local caster = self:GetCaster()
			local ability = self:GetAbility()
			local position = caster:GetAbsOrigin()
			local doomFX = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_ring.vpcf", PATTACH_WORLDORIGIN, nil)
			EmitSoundOn("Hero_Bloodseeker.BloodRite.Cast", caster)
			ParticleManager:SetParticleControl(doomFX, 0, position)
			ParticleManager:SetParticleControl(doomFX, 1, Vector(self.radius, 1, 1))
			caster:RefreshAllCooldowns()
			ability:Stun(caster, self.delay + 0.1)
			Timers:CreateTimer(self.delay, function()
				ParticleManager:ClearParticle(doomFX)
				EmitSoundOn("hero_bloodseeker.bloodRite", caster)
				for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, self.radius ) ) do
					ability:DealDamage( caster, enemy, self.damage,  )
					ability:Stun( enemy, self.duration )
					EmitSoundOn("hero_bloodseeker.bloodRite.silence", enemy)
					ParticleManager:FireParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_impact.vpcf", PATTACH_POINT_FOLLOW, enemy)
				end
			end)
		end
	end
end

function modifier_boss_doom_sacrificial_rite:IsHidden()
	return true
end