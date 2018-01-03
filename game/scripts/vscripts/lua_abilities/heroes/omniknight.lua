omniknight_purification_ebf = class({})

function omniknight_purification_ebf:GetAOERadius()
	return self:GetTalentSpecialValueFor("area_of_effect")
end

function omniknight_purification_ebf:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local damage = self:GetTalentSpecialValueFor("damage")
	local heal = self:GetTalentSpecialValueFor("heal")
	local radius = self:GetTalentSpecialValueFor("area_of_effect")
	
	EmitSoundOn("Hero_Omniknight.Purification", caster)
	ParticleManager:FireParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", PATTACH_POINT_FOLLOW, target, {[1] = Vector(radius, radius, radius)})
	
	target:HealEvent(heal, self, caster)
	
	local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), radius)
	for _, enemy in ipairs(enemies) do
		ParticleManager:FireParticle("particles/units/heroes/hero_omniknight/omniknight_purification_hit.vpcf", PATTACH_POINT_FOLLOW, enemy)
		ApplyDamage({victim = enemy, attacker = caster, damage = damage, damage_type = self:GetAbilityDamageType(), ability = self})
	end
end

function CheckOmniScepter(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.modifier
	local sceptermodifier = keys.sceptermodifier
	local targetTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY
    local targetType = DOTA_UNIT_TARGET_ALL
    local targetFlag = ability:GetAbilityTargetFlags()
	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, FIND_UNITS_EVERYWHERE, targetTeam, targetType, ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
    for _,unit in pairs( units ) do
		if caster:HasScepter() or HasCustomScepter(caster) then
		local duration_scepter = ability:GetTalentSpecialValueFor("duration_scepter")
		ability:ApplyDataDrivenModifier(caster, unit, sceptermodifier, {duration = duration_scepter})
		else
		local duration = ability:GetTalentSpecialValueFor("duration")
		ability:ApplyDataDrivenModifier(caster, unit, modifier, {duration = duration})
		end
	end
end