boss_wk_summon_reaper = class({})

function boss_wk_summon_reaper:GetChannelTime()
	return 1.5
end

function boss_wk_summon_reaper:GetChannelAnimation()
	return ACT_DOTA_TELEPORT
end

function boss_wk_summon_reaper:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_SkeletonKing.Reincarnate.Ghost", caster)
	self.warmUpFX = ParticleManager:CreateParticle("particles/bosses/boss_wk/boss_wk_summon_reaper.vpcf", PATTACH_POINT_FOLLOW, caster)
	caster.reaperTable = caster.reaperTable or {}
	setmetatable(caster.reaperTable, { __mode = 'k' })
end

function boss_wk_summon_reaper:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()
	ParticleManager:ClearParticle(self.warmUpFX)
	if not bInterrupted then
		local reaperCount = self:GetSpecialValueFor("spawn_reaper")
		if (GetTableLength(caster.reaperTable) + reaperCount) > self:GetSpecialValueFor("max_reaper") then
			local toKill = (GetTableLength(caster.reaperTable) + reaperCount) - self:GetSpecialValueFor("max_reaper")
			for reaper,_ in pairs(caster.reaperTable) do
				caster.vanguardTable[reaper] = nil
				if not reaper:IsNull() then reaper:ForceKill(true) end
				toKill = toKill - 1
				if toKill == 0 then break end
			end
		end
		for i = 1, reaperCount do
			local reaperPos = caster:GetAbsOrigin() + ActualRandomVector(600, 150)
			local reaper = CreateUnitByName("npc_dota_boss24_archer", reaperPos, true, caster, caster, caster:GetTeamNumber())
			ParticleManager:FireParticle("particles/units/heroes/hero_ursa/ursa_earthshock_energy.vpcf", PATTACH_POINT_FOLLOW, reaper)
			reaper:FindAbilityByName("boss_reaper_necrotic_hail"):SetLevel(self:GetLevel())
			reaper:FindAbilityByName("boss_reaper_reposition"):SetLevel(self:GetLevel())
			reaper:FindAbilityByName("boss_reaper_multi_shot"):SetLevel(self:GetLevel())
			EmitSoundOn("Hero_SkeletonKing.PreAttack", reaper)
			caster.reaperTable[reaper] = true
		end
	end
end