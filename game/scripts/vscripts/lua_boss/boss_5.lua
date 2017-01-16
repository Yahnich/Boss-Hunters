function RainOfArrows(keys)
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability
	
	local radius = ability:GetSpecialValueFor("radius")
	local base_damage = ability:GetSpecialValueFor("damage")
	local damage_hero = ability:GetSpecialValueFor("damage_per_hero")
	local damage_nonhero = ability:GetSpecialValueFor("damage_per_unit")
	local speed_hero = ability:GetSpecialValueFor("bonus_speed_heroes")
	local speed_nonhero = ability:GetSpecialValueFor("bonus_speed_creeps")
	local illusion_dmg = ability:GetSpecialValueFor("illusion_dmg_pct") / 100
	local duration = ability:GetSpecialValueFor("duration")
	local arrows = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_odds.vpcf", PATTACH_ABSORIGIN , caster)
			ParticleManager:SetParticleControl(arrows, 0, target)
			ParticleManager:SetParticleControl(arrows, 1, target)
			ParticleManager:SetParticleControl(arrows, 3, target)
			ParticleManager:SetParticleControl(arrows, 4, Vector(radius,0,0) )
			ParticleManager:SetParticleControl(arrows, 5, Vector(radius,0,0) )
			ParticleManager:SetParticleControl(arrows, 6, target)
			ParticleManager:SetParticleControl(arrows, 7, target)
			ParticleManager:SetParticleControl(arrows, 8, target)
	ParticleManager:ReleaseParticleIndex(arrows)
	local units = FindUnitsInRadius(caster:GetTeam(), target, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
	local damageToApply = 0
	local ms_stacks = 0
	for _,unit in pairs(units) do -- check units
		if unit:IsHero() then
			damageToApply = damageToApply + damage_hero
			if unit:IsIllusion() then
				local illuDamage = unit:GetMaxHealth() * illusion_dmg
				if illuDamage < unit:GetHealth() then
					unit:SetHealth(unit:GetHealth() - illuDamage)
				else
					unit:ForceKill(true)
				end
			else
				ms_stacks = ms_stacks + speed_hero
			end
		else
			damageToApply = damageToApply + damage_nonhero
			ms_stacks = ms_stacks + speed_nonhero
			if unit:IsSummoned() then
				local illuDamage = unit:GetMaxHealth() * illusion_dmg
				if illuDamage < unit:GetHealth() then
					unit:SetHealth(unit:GetHealth() - illuDamage)
				else
					unit:ForceKill(true)
				end
			end
		end
	end
	for _,unit in pairs(units) do -- deal damage
		ApplyDamage({victim = unit, attacker = caster, damage = damageToApply, damage_type = ability:GetAbilityDamageType(), ability = ability})
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_legion_commander_overwhelming_odds_buff", {duration = duration})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_legion_commander_overwhelming_odds_buff_stacks", {duration = duration})
	caster:SetModifierStackCount("modifier_legion_commander_overwhelming_odds_buff_stacks", caster, ms_stacks)
end

function PreParticles(keys)
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")
		
	local cast = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_odds_cast.vpcf", PATTACH_ABSORIGIN , caster)
			ParticleManager:SetParticleControlEnt(cast, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(cast, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(cast)
	local thinker = ParticleManager:CreateParticle("particles/econ/generic/generic_aoe_shockwave_1/generic_aoe_shockwave_1.vpcf", PATTACH_ABSORIGIN , caster)
			ParticleManager:SetParticleControl(thinker, 0, target)
			ParticleManager:SetParticleControl(thinker, 2, Vector(6,0,1))
			ParticleManager:SetParticleControl(thinker, 1, Vector(radius,0,0))
			ParticleManager:SetParticleControl(thinker, 3, Vector(255,0,0))
			ParticleManager:SetParticleControl(thinker, 4, Vector(0,0,0))
	ParticleManager:ReleaseParticleIndex(thinker)
end