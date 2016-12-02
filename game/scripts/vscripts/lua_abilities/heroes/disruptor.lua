function ApplyTeslaEffects(keys)
	local caster = keys.caster
	local ability = keys.ability
	local unit = keys.unit
	ApplyDamage({ victim = unit, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType(), ability = ability })
	ability:ApplyDataDrivenModifier(caster, unit, keys.modifier, {duration = ability:GetSpecialValueFor("silence_duration")})
	local AOE_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_rhasta/rhasta_spell_forked_lightning.vpcf", PATTACH_POINT_FOLLOW  , caster)
		ParticleManager:SetParticleControlEnt(AOE_effect, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(AOE_effect, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
end

function ApplyTeslaEffectsNearest(keys)
	local caster = keys.caster
	local ability = keys.ability
	local usedability = keys.event_ability
	if usedability:GetCooldown(-1) <= 1 or usedability:GetName() == "item_shadow_amulet" or usedability:GetName() == "item_bottle" then return end
	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, ability:GetCastRange(), ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	for _,unit in pairs(units) do
		local AOE_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_rhasta/rhasta_spell_forked_lightning.vpcf", PATTACH_POINT_FOLLOW  , caster)
		ParticleManager:SetParticleControlEnt(AOE_effect, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(AOE_effect, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
		ApplyDamage({ victim = unit, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType(), ability = ability })
		ability:ApplyDataDrivenModifier(caster, unit, keys.modifier, {duration = ability:GetSpecialValueFor("silence_duration")})
	end
end