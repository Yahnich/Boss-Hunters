undying_soul_rip_bh = class({})

function undying_soul_rip_bh:GetCooldown(iLvl)
	local cd = self.BaseClass.GetCooldown(self, iLvl)
	if self:GetCaster():HasTalent("special_bonus_unique_undying_soul_rip_2") then cd = cd - self:GetCaster():FindTalentValue("special_bonus_unique_undying_soul_rip_2") end
	return cd
end

function undying_soul_rip_bh:OnAbilityPhaseStart()
	EmitSoundOn("Hero_Undying.SoulRip.Cast", self:GetCaster() )
	return true
end

function undying_soul_rip_bh:OnAbilityPhaseInterrupted()
	StopSoundOn("Hero_Undying.SoulRip.Cast", self:GetCaster() )
end

function undying_soul_rip_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local radius = self:GetTalentSpecialValueFor("")
	local hploss = self:GetTalentSpecialValueFor("")
	local healPUnit = self:GetTalentSpecialValueFor("")
	
	local units = caster:FindAllUnitsInRadius( caster:GetAbsOrigin(), radius )
	local unitCount = #units
	if target:IsSameTeam() then
		EmitSoundOn("Hero_Undying.SoulRip.Ally", target)
		target:HealEvent( unitCount * healPUnit, self, caster )
	else
		EmitSoundOn("Hero_Undying.SoulRip.Enemy", target)
		target:DealDamage( caster, target, unitCount * healPUnit )
	end
	
	for _, unit in ipairs( units ) do
		if not unit:IsSameTeam(caster) or caster:HasTalent("special_bonus_unique_undying_soul_rip_1") then
			unit:DealDamage( caster, unit, hploss, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DAMAGE_FLAGS_HPLOSS})
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(particle, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
			ParticleManager:ClearParticle( particle )
		end
	end
end