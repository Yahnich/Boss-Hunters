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

	local radius = self:GetSpecialValueFor("stun_radius")
	local damage = self:GetSpecialValueFor("damage")
	local duration = self:GetSpecialValueFor("stun_duration")
	local golemDuration = self:GetSpecialValueFor("golem_duration")
	local secondGolem
	EmitSoundOn("Hero_Warlock.RainOfChaos", caster)
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rain_of_chaos_start.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControl(nfx, 0, point)
				ParticleManager:SetParticleControl(nfx, 1, point)
				ParticleManager:SetParticleControl(nfx, 2, point)
				ParticleManager:ReleaseParticleIndex(nfx)

	Timers:CreateTimer(self:GetSpecialValueFor("delay"), function()
		local nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rain_of_chaos.vpcf", PATTACH_POINT, caster)
					 ParticleManager:SetParticleControl(nfx2, 0, point)
					 ParticleManager:SetParticleControl(nfx2, 1, Vector(2,2,2))
					 ParticleManager:SetParticleControl(nfx2, 2, point)
					 ParticleManager:SetParticleControl(nfx2, 5, point)
					 ParticleManager:ReleaseParticleIndex(nfx2)

		local enemies = caster:FindEnemyUnitsInRadius(point, radius)
		for _,enemy in pairs(enemies) do
			if not enemy:TriggerSpellAbsorb( self ) then
				self:Stun(enemy, duration, false)
				self:DealDamage(caster, enemy, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
			end
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
	local golem = caster:CreateSummon("npc_dota_warlock_golem_1", position, ( duration or self:GetSpecialValueFor("golem_duration") ) )
	local golem_pct = golemPct or 1
	golem:RemoveAbility("warlock_golem_flaming_fists")
	golem:AddAbility("warlock_golem_gloves"):SetLevel(self:GetLevel())
	golem:RemoveAbility("warlock_golem_permanent_immolation")
	golem:AddAbility("warlock_golem_immolation"):SetLevel(self:GetLevel())
	golem:SetBaseDamageMin( self:GetSpecialValueFor("golem_damage") * golem_pct )
	golem:SetBaseDamageMax( self:GetSpecialValueFor("golem_damage") * golem_pct )
	golem:SetPhysicalArmorBaseValue( ( 5 * self:GetLevel() ) )
	golem:SetBaseMoveSpeed( 310 + 10 * self:GetLevel() )
	golem:SetCoreHealth( self:GetSpecialValueFor("golem_hp") * golem_pct )
	golem:SetBaseHealthRegen( ( self:GetSpecialValueFor("golem_hp") / 100 ) * golem_pct )
	
	golem:SetBaseMagicalResistanceValue( self:GetSpecialValueFor("golem_magic_resist") )
	
	return golem
end