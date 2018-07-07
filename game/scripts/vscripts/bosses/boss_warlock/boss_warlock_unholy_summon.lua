boss_warlock_unholy_summon = class({})

function boss_warlock_unholy_summon:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local maxTargets = self:GetSpecialValueFor("max_targets")
	local currentTargets = 0

	self.locations = {}

	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
	for _,enemy in pairs(enemies) do
		if enemy:IsHero() and currentTargets < maxTargets then
			ParticleManager:FireWarningParticle(enemy:GetAbsOrigin(), self:GetSpecialValueFor("radius"))
			ParticleManager:FireParticle("particles/units/heroes/hero_warlock/warlock_rain_of_chaos_start.vpcf", PATTACH_POINT, caster, {[0]=enemy:GetAbsOrigin()})
			table.insert(self.locations, enemy:GetAbsOrigin())
			currentTargets = currentTargets + 1
		end
	end
	return true
end

function boss_warlock_unholy_summon:OnSpellStart()
	local caster = self:GetCaster()

	for _,location in pairs(self.locations) do
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rain_of_chaos.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControl(nfx, 0, location)
					ParticleManager:SetParticleControl(nfx, 1, Vector(1,1,1))
					ParticleManager:SetParticleControl(nfx, 2, location)
					ParticleManager:SetParticleControl(nfx, 5, location)
					ParticleManager:ReleaseParticleIndex(nfx)
		
		local demon = CreateUnitByName("npc_dota_boss_warlock_demon", location, true, caster, caster, caster:GetTeam())
		FindClearSpaceForUnit(demon, demon:GetAbsOrigin(), true)

		local enemies = caster:FindEnemyUnitsInRadius(location, self:GetSpecialValueFor("radius"))
		for _,enemy in pairs(enemies) do
			if not enemy:IsMagicImmune() and not enemy:IsInvulnerable() then
				self:Stun(enemy, 1)
				self:DealDamage(caster, enemy, self:GetSpecialValueFor("damage"))
			end
		end
	end
end