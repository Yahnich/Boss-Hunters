warlock_demonic_summons = class({})

function warlock_demonic_summons:IsStealable()
	return true
end

function warlock_demonic_summons:IsHiddenWhenStolen()
	return false
end

function warlock_demonic_summons:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
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
	local secondGolem
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
			self:Stun(enemy, duration, false)
			self:DealDamage(caster, enemy, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		end

		self:CreateGolem(point)
		if caster:HasTalent("special_bonus_unique_warlock_demonic_summons_2") and not secondGolem then
			EmitSoundOn("Hero_Warlock.RainOfChaos", caster)
			secondGolem = true
			return 0.5
		end
	end)
end

function warlock_demonic_summons:CreateGolem(position, duration, golemPct)
	local caster = self:GetCaster()
	local golem = caster:CreateSummon("npc_dota_warlock_golem_1", position, ( duration or self:GetTalentSpecialValueFor("golem_duration") ) )
	local golem_pct = golemPct or 1
	golem:RemoveAbility("warlock_golem_flaming_fists")
	golem:AddAbility("warlock_golem_gloves"):SetLevel(self:GetLevel())
	golem:RemoveAbility("warlock_golem_permanent_immolation")
	golem:AddAbility("warlock_golem_immolation"):SetLevel(self:GetLevel())
	golem:SetBaseDamageMin( ( 75 * self:GetLevel() ) * golem_pct )
	golem:SetBaseDamageMax( ( 75 * self:GetLevel() ) * golem_pct )
	golem:SetPhysicalArmorBaseValue( ( 5 * self:GetLevel() ) )
	golem:SetBaseMoveSpeed( 310 + 10 * self:GetLevel() )
	golem:SetCoreHealth( ( 1000 * self:GetLevel() ) * golem_pct )
	golem:SetBaseHealthRegen( (25 * self:GetLevel() ) * golem_pct )
	golem:SetModelScale( 0.7 + ( self:GetLevel()/20 ) * golem_pct )
	if caster:HasTalent("special_bonus_unique_warlock_demonic_summons_1") then
		golem:SetBaseMagicalResistanceValue( caster:FindTalentValue("special_bonus_unique_warlock_demonic_summons_1", "mr") )
		golem:SetAverageBaseDamage( golem:GetAverageBaseDamage() * caster:FindTalentValue("special_bonus_unique_warlock_demonic_summons_1", "dmg"), 25 )
		golem:SetCoreHealth( golem:GetBaseMaxHealth() * caster:FindTalentValue("special_bonus_unique_warlock_demonic_summons_1", "hp") )
		golem:SetModelScale( golem:GetModelScale() * 1.33 )
	end
	return golem
end