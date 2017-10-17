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
		for i = 1, zombieCount do
			local zombiePos = caster:GetAbsOrigin() + ActualRandomVector(zombieSpawnRadius, 150)
			local zombie = CreateUnitByName("npc_dota_mini_boss1", zombiePos, true, caster, caster, caster:GetTeamNumber())
			ParticleManager:FireParticle("particles/bosses/boss4/boss4_summon_zombies_spawn.vpcf", PATTACH_POINT_FOLLOW, zombie)
			zombie:FindAbilityByName("boss4_horde_power"):SetLevel(self:GetLevel())
			self.zombies[zombie] = true
			EmitSoundOn("Creature.ZombieSpawn", zombie)
		end
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