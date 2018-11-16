dazzle_shadow_wave_bh = class({})

function dazzle_shadow_wave_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local prevTarget = caster
	
	local delay = caster:FindTalentValue("special_bonus_unique_dazzle_shadow_wave_2", "delay")
	local bounces = self:GetTalentSpecialValueFor("max_targets") - 1
	local bounceRadius = self:GetTalentSpecialValueFor("bounce_radius")
	local radius = self:GetTalentSpecialValueFor("damage_radius")
	local healdamage = self:GetTalentSpecialValueFor("damage")
	
	local hitUnits = {}
	local talent1 = caster:HasTalent("special_bonus_unique_dazzle_shadow_wave_1")
	local talent2 = caster:HasTalent("special_bonus_unique_dazzle_shadow_wave_2")
	
	self:ApplyEffects( caster, healdamage, radius )
	hitUnits[caster:entindex()] = true
	Timers:CreateTimer(function()
		target:EmitSound("Hero_Dazzle.Shadow_Wave")
		hitUnits[target:entindex()] = true
		self:ApplyEffects( target, healdamage, radius )
		ParticleManager:FireRopeParticle("particles/units/heroes/hero_dazzle/dazzle_shadow_wave.vpcf", PATTACH_POINT_FOLLOW, prevTarget, target)
		prevTarget = target
		bounces = bounces - 1
		if bounces <= 0 then
			return
		end
		for _, unit in ipairs( caster:FindAllUnitsInRadius( target:GetAbsOrigin(), bounceRadius ) ) do
			if (unit:IsSameTeam(caster) or talent1) and (not hitUnits[unit:entindex()] or talent2) then
				target = unit
				return delay
			end
		end
	end)
end

function dazzle_shadow_wave_bh:ApplyEffects( target, fHealDamage, fRadius )
	local caster = self:GetCaster()
	local healdamage = fHealDamage or self:GetTalentSpecialValueFor("damage")
	local radius = fRadius or self:GetTalentSpecialValueFor("damage_radius")
	if target:IsSameTeam( caster ) then
		target:HealEvent( healdamage, self, caster )
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), radius ) ) do
			self:DealDamage( caster, enemy, healdamage )
		end
	else
		self:DealDamage( caster, target, healdamage )
		for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( target:GetAbsOrigin(), radius ) ) do
			ally:HealEvent( healdamage, self, caster )
		end
	end
end