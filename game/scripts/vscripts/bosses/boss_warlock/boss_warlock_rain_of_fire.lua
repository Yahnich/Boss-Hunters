boss_warlock_rain_of_fire = class({})

function boss_warlock_rain_of_fire:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	self.pos = target:GetAbsOrigin()

	ParticleManager:FireWarningParticle(self.pos, self:GetSpecialValueFor("radius"))

	return true
end

function boss_warlock_rain_of_fire:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local pos = self.pos
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	local delay = self:GetSpecialValueFor("delay")
	local interval = self:GetSpecialValueFor("wave_interval")
	local maxWaves = self:GetSpecialValueFor("wave_number")
	local currentWaves = 0

	Timers:CreateTimer(0, function()
		if currentWaves < maxWaves then
			local nfx = ParticleManager:CreateParticle("particles/bosses/boss_warlock/boss_warlock_rain_of_fire.vpcf", PATTACH_POINT, caster)
						ParticleManager:SetParticleControl(nfx, 0, pos)
						ParticleManager:SetParticleControl(nfx, 1, pos)
						ParticleManager:SetParticleControl(nfx, 3, pos)
						ParticleManager:SetParticleControl(nfx, 4, Vector(radius,radius,radius))
						ParticleManager:SetParticleControl(nfx, 5, Vector(1,0,0))
						ParticleManager:SetParticleControl(nfx, 6, pos)
						ParticleManager:SetParticleControl(nfx, 7, pos)
						ParticleManager:SetParticleControl(nfx, 8, pos)
						ParticleManager:SetParticleControl(nfx, 16, pos)
						ParticleManager:ReleaseParticleIndex(nfx)
			Timers:CreateTimer(delay, function()
				local enemies = caster:FindEnemyUnitsInRadius(pos, radius)
				for _,enemy in pairs(enemies) do
					if not enemy:TriggerSpellAbsorb(self) then
						self:DealDamage(caster, enemy, damage, {}, 0)
					end
				end
			end)
			currentWaves = currentWaves + 1
			return interval
		else
			return nil
		end
	end)
end
