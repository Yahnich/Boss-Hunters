warlock_demonic_summons = class({})

function warlock_demonic_summons:IsStealable()
	return true
end

function warlock_demonic_summons:IsHiddenWhenStolen()
	return false
end

function warlock_demonic_summons:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_warlock_demonic_summons_2") then cooldown = cooldown * self:GetCaster():FindTalentValue("special_bonus_unique_warlock_demonic_summons_2") end
    return cooldown
end

function warlock_demonic_summons:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_Warlock.RainOfChaos_buildup", caster)
	ParticleManager:FireParticle("particles/units/heroes/hero_warlock/warlock_rain_of_chaos_staff.vpcf", PATTACH_POINT_FOLLOW, caster, {[0]="attach_attack1"})
	return true
end

function warlock_demonic_summons:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local radius = self:GetTalentSpecialValueFor("stun_radius")
	local damage = self:GetTalentSpecialValueFor("damage")
	local duration = self:GetTalentSpecialValueFor("stun_duration")
	local golemDuration = self:GetTalentSpecialValueFor("golem_duration")
	local maxGolems = self:GetTalentSpecialValueFor("golem_number") + caster:FindTalentValue("special_bonus_unique_warlock_demonic_summons_1")
	--print(maxGolems)

	if caster:HasTalent("special_bonus_unique_warlock_demonic_summons_2") then
		golemDuration = golemDuration * caster:FindTalentValue("special_bonus_unique_warlock_demonic_summons_2")
	end

	EmitSoundOn("Hero_Warlock.RainOfChaos", caster)
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rain_of_chaos_start.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControl(nfx, 0, point)
				ParticleManager:SetParticleControl(nfx, 1, point)
				ParticleManager:SetParticleControl(nfx, 2, point)
				ParticleManager:ReleaseParticleIndex(nfx)

	Timers:CreateTimer(self:GetTalentSpecialValueFor("delay"), function()
		local nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rain_of_chaos.vpcf", PATTACH_POINT, caster)
					 ParticleManager:SetParticleControl(nfx2, 0, point)
					 ParticleManager:SetParticleControl(nfx2, 1, Vector(2,2,2))
					 ParticleManager:SetParticleControl(nfx2, 2, point)
					 ParticleManager:SetParticleControl(nfx2, 5, point)
					 ParticleManager:ReleaseParticleIndex(nfx2)

		local enemies = caster:FindEnemyUnitsInRadius(point, radius)
		for _,enemy in pairs(enemies) do
			self:Stun(enemy, duration, bDelay)
			self:DealDamage(caster, enemy, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		end

		for i=1,maxGolems do
			local golem = caster:CreateSummon("npc_dota_warlock_golem_1", point, golemDuration)
			golem:RemoveAbility("warlock_golem_flaming_fists")
			golem:AddAbility("warlock_golem_gloves"):SetLevel(self:GetLevel())
			golem:RemoveAbility("warlock_golem_permanent_immolation")
			golem:AddAbility("warlock_golem_immolation"):SetLevel(self:GetLevel())
			golem:SetBaseDamageMin( (25 + 50 * self:GetLevel())/maxGolems )
			golem:SetBaseDamageMax( (25 + 50 * self:GetLevel())/maxGolems )
			golem:SetPhysicalArmorBaseValue( (3 + 3 * self:GetLevel())/maxGolems )
			golem:SetBaseMoveSpeed(310 + 10 * self:GetLevel())
			golem:SetBaseMaxHealth( (1000 * self:GetLevel())/maxGolems )
			golem:SetHealth( (1000 * self:GetLevel())/maxGolems )
			golem:SetBaseHealthRegen( (25 * self:GetLevel())/maxGolems )
			golem:SetModelScale( 1 + self:GetLevel()/10/maxGolems )
		end
	end)
end