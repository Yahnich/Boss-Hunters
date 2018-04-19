boss27_ursa_warrior = class({})

function boss27_ursa_warrior:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_Ursa.Enrage", caster)
	self.warmUpFX = ParticleManager:CreateParticle("particles/bosses/boss27/boss27_summon_lilbears_summon.vpcf", PATTACH_POINT_FOLLOW, caster)
	caster.smallBearsTable = self.smallBearsTable or {}
end


function boss27_ursa_warrior:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()
	ParticleManager:ClearParticle(self.warmUpFX)
	if not bInterrupted then
		local bearCount = self:GetSpecialValueFor("spawn_count")
		local bearSpawnRadius = self:GetSpecialValueFor("spawn_radius")
		for i = 1, bearCount do
			local bearPos = caster:GetAbsOrigin() + ActualRandomVector(bearSpawnRadius, 150)
			local bear = CreateUnitByName("npc_dota_boss26_mini", bearPos, true, caster, caster, caster:GetTeamNumber())
			ParticleManager:FireParticle("particles/units/heroes/hero_ursa/ursa_earthshock_energy.vpcf", PATTACH_POINT_FOLLOW, bear)
			bear:FindAbilityByName("boss26b_ankle_biter"):SetLevel(self:GetLevel())
			bear:FindAbilityByName("boss26b_screech"):SetLevel(self:GetLevel())
			bear:FindAbilityByName("boss26b_wound"):SetLevel(self:GetLevel())
			EmitSoundOn("ursa_ursa_pain_"..RandomInt(14,20), caster)
			table.insert(caster.smallBearsTable, bear)
		end
	end
end