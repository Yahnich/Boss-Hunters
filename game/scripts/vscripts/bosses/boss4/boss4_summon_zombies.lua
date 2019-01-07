boss4_summon_zombies = class({})

function boss4_summon_zombies:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Creature.Scream", caster)
	self.warmUpFX = ParticleManager:CreateParticle("particles/bosses/boss4/boss4_summon_zombies_summon.vpcf", PATTACH_POINT_FOLLOW, caster)
	self.zombies = self.zombies or {}
end


function boss4_summon_zombies:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()
	ParticleManager:ClearParticle(self.warmUpFX)
	if not bInterrupted then
		local zombieCount = self:GetSpecialValueFor("zombie_count")
		local zombieSpawnRadius = self:GetSpecialValueFor("spawn_radius")
		local maxZombies = self:GetSpecialValueFor("max_zombies")
		local currZombies = self:GetZombieCount()
		if maxZombies < (currZombies + zombieCount) then
			local toKill = (currZombies + zombieCount) - maxZombies
			for zombie,_ in pairs(self.zombies) do
				if zombie:IsNull() or not zombie:IsAlive() then
					self.zombies[zombie] = nil
				elseif toKill > 0 then
					toKill = toKill - 1
					zombie:ForceKill(false)
					self.zombies[zombie] = nil
				end
			end
		end
		Timers:CreateTimer(0.1, function()
			local zombiePos = caster:GetAbsOrigin() + ActualRandomVector(zombieSpawnRadius, 150)
			local zombie = CreateUnitByName("npc_dota_mini_boss1", zombiePos, true, caster, caster, caster:GetTeamNumber())
			ParticleManager:FireParticle("particles/bosses/boss4/boss4_summon_zombies_spawn.vpcf", PATTACH_POINT_FOLLOW, zombie)
			self.zombies[zombie] = true
			EmitSoundOn("Creature.ZombieSpawn", zombie)
			zombieCount = zombieCount - 1
			if zombieCount > 0 then
				return 0.1
			end
		end)
	end
end

function boss4_summon_zombies:GetZombieCount()
	local zombies = 0
	self.zombies = self.zombies or {}
	for zombie,_ in pairs(self.zombies) do
		if zombie:IsNull() or not zombie:IsAlive() then
			self.zombies[zombie] = nil
		else
			zombies = zombies + 1
		end
	end
	return zombies
end

function boss4_summon_zombies:GetZombies()
	return self.zombies or {}
end