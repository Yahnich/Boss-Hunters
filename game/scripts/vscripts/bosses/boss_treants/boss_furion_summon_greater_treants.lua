boss_furion_summon_greater_treants = class({})

function boss_furion_summon_greater_treants:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Creature.Scream", caster)
	self.warmUpFX = ParticleManager:CreateParticle("particles/bosses/boss4/boss4_summon_zombies_summon.vpcf", PATTACH_POINT_FOLLOW, caster)
	self.treants = self.treants or {}
end

function boss_furion_summon_greater_treants:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()
	ParticleManager:ClearParticle(self.warmUpFX)
	if not bInterrupted then
		local treantCount = self:GetSpecialValueFor("treant_count")
		local treantSpawnRadius = self:GetSpecialValueFor("spawn_radius")
		local maxtreants = self:GetSpecialValueFor("max_treants")
		local currtreants = self:GetTreantCount()
		if maxtreants < (currtreants + treantCount) then
			local toKill = (currtreants + treantCount) - maxtreants
			for treant,_ in pairs(self.treants) do
				if treant:IsNull() or not treant:IsAlive() then
					self.treants[treant] = nil
				elseif toKill > 0 then
					toKill = toKill - 1
					treant:ForceKill(false)
					self.treants[treant] = nil
				end
			end
		end
		ParticleManager:CreateParticle("particles/units/heroes/hero_furion/furion_force_of_nature_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
		Timers:CreateTimer(0.1, function()
			local treantPos = caster:GetAbsOrigin() + ActualRandomVector(treantSpawnRadius, 150)
			local treant = CreateUnitByName("npc_dota_minion_greater_treant", treantPos, true, caster, caster, caster:GetTeamNumber())
			treant:AddNewModifier( treant, self, "modifier_phased", {})
			self.treants[treant] = true
			EmitSoundOn("Hero_Furion.TreantSpawn", treant)
			treantCount = treantCount - 1
			if treantCount > 0 then
				return 0.1
			end
		end)
	end
end

function boss_furion_summon_greater_treants:GetTreantCount()
	local treants = 0
	self.treants = self.treants or {}
	for treant,_ in pairs(self.treants) do
		if treant:IsNull() or not treant:IsAlive() then
			self.treants[treant] = nil
		else
			treants = treants + 1
		end
	end
	return treants
end

function boss_furion_summon_greater_treants:GetTreants()
	return self.treants or {}
end