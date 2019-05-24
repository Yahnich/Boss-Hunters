boss27_ursa_giant = class({})

function boss27_ursa_giant:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_Ursa.Enrage", caster)
	self.warmUpFX = ParticleManager:CreateParticle("particles/bosses/boss27/boss27_summon_bigbears_summon.vpcf", PATTACH_POINT_FOLLOW, caster)
	return true
end

function boss27_ursa_giant:OnAbilityPhaseInterrupted()
	local caster = self:GetCaster()
	ParticleManager:ClearParticle(self.warmUpFX)
	StopSoundOn("Hero_Ursa.Enrage", caster)
end

function boss27_ursa_giant:OnSpellStart()
	local caster = self:GetCaster()
	ParticleManager:ClearParticle(self.warmUpFX)
	
	local bearCount = self:GetSpecialValueFor("spawn_count") + math.floor( HeroList:GetActiveHeroCount() / self:GetSpecialValueFor("players_per_bonus") )
	local bearSpawnRadius = self:GetSpecialValueFor("spawn_radius")
	for i = 1, bearCount do
		local bearPos = caster:GetAbsOrigin() + ActualRandomVector(bearSpawnRadius, 150)
		local bear = CreateUnitByName("npc_dota_boss26", bearPos, true, caster, caster, caster:GetTeamNumber())
		ParticleManager:FireParticle("particles/units/heroes/hero_ursa/ursa_earthshock_energy.vpcf", PATTACH_POINT_FOLLOW, bear)
		bear:FindAbilityByName("boss26_smash"):SetLevel(self:GetLevel())
		bear:FindAbilityByName("boss26_rend"):SetLevel(self:GetLevel())
		bear:FindAbilityByName("boss26_ravage"):SetLevel(self:GetLevel())
		EmitSoundOn("ursa_ursa_pain_"..RandomInt(14,20), caster)
		table.insert(caster.bigBearsTable, bear)
	end
end