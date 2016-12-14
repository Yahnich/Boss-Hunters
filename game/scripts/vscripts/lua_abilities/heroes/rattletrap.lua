function DeflectorProc(keys)
	local caster = keys.caster
	local ability = keys.ability
	local attacker = keys.attacker
	
	local healPct = ability:GetTalentSpecialValueFor("heal_pct")
	local duration = ability:GetTalentSpecialValueFor("buff_duration")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_aegis_deflector_proc", {duration = duration})
	ApplyKnockback({duration = ability:GetTalentSpecialValueFor("push_duration"), distance = ability:GetTalentSpecialValueFor("push_length"), caster = caster, target = attacker, height = 0, modifier = "modifier_aegis_deflector_knockback", ability = ability})
	ApplyDamage({ victim = attacker, attacker = caster, damage = ability:GetTalentSpecialValueFor("mana_damage"), damage_type = ability:GetAbilityDamageType(), ability = ability })
	local zap = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_cog_attack.vpcf", PATTACH_POINT_FOLLOW, attacker)
			ParticleManager:SetParticleControlEnt(zap, 0, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(zap, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	attacker:EmitSound("Hero_Rattletrap.Power_Cogs_Impact")
end