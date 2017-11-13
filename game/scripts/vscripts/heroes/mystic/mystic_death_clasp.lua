mystic_death_clasp = class({})

function mystic_death_clasp:OnSpellStart()
	local caster = self:GetCaster()
	
	self.timerThinker = 0
	self.radius = self:GetSpecialValueFor("initial_radius")
	self.radiusGrowth = self:GetSpecialValueFor("radius_growth_speed")
	
	EmitSoundOn("Hero_Dazzle.Weave", caster)
	self.FX = ParticleManager:CreateParticle("particles/heroes/mystic/mystic_death_clasp_ring.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(self.FX, 1, Vector(self.radius, self.radius, 1))
	self:StartDelayedCooldown()
end

function mystic_death_clasp:OnChannelThink(dt)
	self.timerThinker = self.timerThinker + dt
	
	self.radius = self.radius + self.radiusGrowth * dt
	ParticleManager:SetParticleControl(self.FX, 1, Vector(self.radius, self.radius, 1))
	local caster = self:GetCaster()
	
	if self.timerThinker > 0.5 then
		local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self.radius)
		local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), self.radius)
		
		local total_damage = self:GetSpecialValueFor("total_damage")
		local damage = total_damage / self:GetChannelTime() * 0.5
		local heal = damage * self:GetSpecialValueFor("heal_percentage") / 100
	
		for _, enemy in pairs(enemies) do
			enemy:AddNewModifier(caster, self, "modifier_mystic_death_clasp_slow", {duration = self:GetSpecialValueFor("slow_duration")})		
			self:DealDamage(caster, enemy, damage)
			if not caster:HasTalent("mystic_death_clasp_talent_1") then
				caster:HealEvent(heal, self, caster)
			else
				for _, ally in ipairs(allies) do
					ally:HealEvent(heal, self, caster)
				end
			end
		end
		self.timerThinker = 0
	end
end

function mystic_death_clasp:OnChannelFinish(bInterrupted)
	ParticleManager:DestroyParticle(self.FX, false)
	ParticleManager:ReleaseParticleIndex(self.FX)
	self:EndDelayedCooldown()
end


modifier_mystic_death_clasp_slow = class({})
LinkLuaModifier("modifier_mystic_death_clasp_slow", "heroes/mystic/mystic_death_clasp.lua", 0)


function modifier_mystic_death_clasp_slow:OnCreated()
	self.ms = self:GetSpecialValueFor("slow")
end

function modifier_mystic_death_clasp_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_mystic_death_clasp_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end