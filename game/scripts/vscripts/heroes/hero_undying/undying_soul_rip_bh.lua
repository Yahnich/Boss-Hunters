undying_soul_rip_bh = class({})

function undying_soul_rip_bh:GetCooldown(iLvl)
	local cd = self.BaseClass.GetCooldown(self, iLvl)
	-- if self:GetCaster():HasTalent("special_bonus_unique_undying_soul_rip_2") then cd = cd - self:GetCaster():FindTalentValue("special_bonus_unique_undying_soul_rip_2") end
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
	
	local radius = self:GetTalentSpecialValueFor("range")
	local hploss = self:GetTalentSpecialValueFor("enemy_hp_loss")
	local healPUnit = self:GetTalentSpecialValueFor("health_per_unit")
	
	local units = caster:FindAllUnitsInRadius( caster:GetAbsOrigin(), radius )
	local unitCount = 0
	
	local ripFX = "particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf"
	if not target:IsSameTeam(caster) then
		ripFX = "particles/units/heroes/hero_undying/undying_soul_rip_damage.vpcf"
	end
	
	for _, unit in ipairs( units ) do
		if not unit:IsSameTeam(caster) or caster:HasTalent("special_bonus_unique_undying_soul_rip_1") then
			self:DealDamage( caster, unit, hploss, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DAMAGE_FLAGS_HPLOSS})
		end
		unitCount = unitCount + 1
		if not unit:IsMinion() or unit:IsRealHero() then
			unitCount = unitCount + 1
		end
		ParticleManager:FireRopeParticle(ripFX, PATTACH_ABSORIGIN_FOLLOW, target, unit)
	end
	
	
	if target:IsSameTeam(caster) then
		EmitSoundOn("Hero_Undying.SoulRip.Ally", target)
		target:HealEvent( unitCount * healPUnit, self, caster )
	else
		EmitSoundOn("Hero_Undying.SoulRip.Enemy", target)
		self:DealDamage( caster, target, unitCount * healPUnit )
		ripFX = "particles/units/heroes/hero_undying/undying_soul_rip_damage.vpcf"
	end
	
	if caster:HasTalent("special_bonus_unique_undying_soul_rip_2") then
		target:AddNewModifier(caster, self, "modifier_undying_soul_rip_bh_talent", {duration = caster:FindTalentValue("special_bonus_unique_undying_soul_rip_2", "duration")})
	end
end

modifier_undying_soul_rip_bh_talent = class({})
LinkLuaModifier("modifier_undying_soul_rip_bh_talent", "heroes/hero_undying/undying_soul_rip_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_soul_rip_bh_talent:OnCreated()
	self.as = self:GetCaster():FindTalentValue("special_bonus_unique_undying_soul_rip_2")
	if not self:GetCaster():IsSameTeam( self:GetParent() ) then
		self.as = self.as / (-2)
	end
end

function modifier_undying_soul_rip_bh_talent:GetModifierAttackSpeedBonus()
	return self.as
end