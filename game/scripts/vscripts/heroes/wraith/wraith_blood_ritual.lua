wraith_blood_ritual = class({})

function wraith_blood_ritual:OnAbilityPhaseStart()
	EmitSoundOn("Hero_Undying.SoulRip.Cast", self:GetCaster())
	return true
end

function wraith_blood_ritual:OnAbilityPhaseInterrupted(bInterrupt)
	StopSoundOn("Hero_Undying.SoulRip.Cast", self:GetCaster())
end

function wraith_blood_ritual:CastFilterResultTarget(target)
	if IsServer() then
		local caster = self:GetCaster()
		if caster:HasTalent("wraith_blood_ritual_talent_1") then
			return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, caster:GetTeamNumber())
		else
			return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, caster:GetTeamNumber())
		end
	end
end

function wraith_blood_ritual:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local baseHeal = self:GetSpecialValueFor("heal")
	local pctHeal = (self:GetSpecialValueFor("heal_pct") / 100)
	
	if target:IsSameTeam(caster) then
		local enemies = caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self:GetSpecialValueFor("search_radius") )
		local spreadCount = #enemies + 1
		for _, enemy in ipairs( enemies ) do
			self:DealDamage(caster, enemy, heal/spreadCount, {damage_type = DAMAGE_TYPE_PURE})
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_undying/undying_soul_rip_damage.vpcf", PATTACH_POINT_FOLLOW, caster, enemy)
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_POINT_FOLLOW, target, enemy)
		end
		self:DealDamage(caster, caster, heal/spreadCount, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL})
		ParticleManager:FireRopeParticle("particles/units/heroes/hero_undying/undying_soul_rip_damage.vpcf", PATTACH_POINT_FOLLOW, caster, caster)
		ParticleManager:FireRopeParticle("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_POINT_FOLLOW, target, caster)
		
		EmitSoundOn("Hero_Undying.SoulRip.Ally", target)
		target:HealEvent(baseHeal + pctHeal * target:GetMaxHealth(), self, caster)
	else
		local allies = caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), self:GetSpecialValueFor("search_radius") )
		local spreadCount = #allies + 1
		for _, ally in ipairs( allies ) do
			ally:HealEvent( (baseHeal + pctHeal * ally:GetMaxHealth()) / spreadCount, self, caster)
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_undying/undying_soul_rip_damage.vpcf", PATTACH_POINT_FOLLOW, target, ally)
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_POINT_FOLLOW, caster, ally)
		end
		
		EmitSoundOn("Hero_Undying.SoulRip.Enemy", target)

		self:DealDamage(caster, target, baseHeal + pctHeal * caster:GetMaxHealth(), {damage_type = DAMAGE_TYPE_PURE})
	end
end
