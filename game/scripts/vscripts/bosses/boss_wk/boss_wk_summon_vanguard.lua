boss_wk_summon_vanguard = class({})

function boss_wk_summon_vanguard:GetChannelTime()
	return 1.5
end

function boss_wk_summon_vanguard:GetChannelAnimation()
	return ACT_DOTA_TELEPORT
end

function boss_wk_summon_vanguard:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_SkeletonKing.Reincarnate.Ghost", caster)
	self.warmUpFX = ParticleManager:CreateParticle("particles/bosses/boss_wk/boss_wk_summon_vanguard.vpcf", PATTACH_POINT_FOLLOW, caster)
	caster.vanguardTable = caster.vanguardTable or {}
	setmetatable(caster.vanguardTable, { __mode = 'k' })
end

function boss_wk_summon_vanguard:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()
	ParticleManager:ClearParticle(self.warmUpFX)
	if not bInterrupted then
		local vanguardCount = self:GetSpecialValueFor("spawn_vanguard")
		if (GetTableLength(caster.vanguardTable) + vanguardCount) > self:GetSpecialValueFor("max_vanguard") then
			local toKill = (GetTableLength(caster.vanguardTable) + vanguardCount) - self:GetSpecialValueFor("max_vanguard")
			
			for vanguard,_ in pairs(caster.vanguardTable) do
				caster.vanguardTable[vanguard] = nil
				if not vanguard:IsNull() then vanguard:ForceKill(true) end
				toKill = toKill - 1
				if toKill == 0 then break end
			end
		end
		for i = 1, vanguardCount do
			local vanguardPos = caster:GetAbsOrigin() + ActualRandomVector(600, 150)
			local vanguard = CreateUnitByName("npc_dota_boss24_stomper", vanguardPos, true, caster, caster, caster:GetTeamNumber())
			ParticleManager:FireParticle("particles/units/heroes/hero_ursa/ursa_earthshock_energy.vpcf", PATTACH_POINT_FOLLOW, vanguard)
			vanguard:FindAbilityByName("boss_vanguard_bone_wall"):SetLevel(self:GetLevel())
			vanguard:FindAbilityByName("boss_vanguard_shin_shatter"):SetLevel(self:GetLevel())
			vanguard:FindAbilityByName("boss_vanguard_back_breaker"):SetLevel(self:GetLevel())
			EmitSoundOn("Hero_SkeletonKing.PreAttack", vanguard)
			caster.vanguardTable[vanguard] = true
		end
	end
end