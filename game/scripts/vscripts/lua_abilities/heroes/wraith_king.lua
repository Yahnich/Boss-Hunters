function VampiricHeal(keys)
	local caster = keys.caster
	local target = keys.attacker
	local ability = keys.ability
	
	print(target:GetName())
	local hpMax = target:GetMaxHealth()
	local hpPerc = ability:GetSpecialValueFor("aura_lifesteal") / 100
	target:Heal(hpMax*hpPerc, caster)
end

function VampiricActiveHeal(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local healPerc = ability:GetSpecialValueFor("life_leeched") / 100
	local heal = ability:GetAbilityDamage() * healPerc
	if caster:GetHealth() + heal > caster:GetMaxHealth() then
		local difference = caster:GetMaxHealth() - caster:GetHealth()
		caster:Heal(difference, caster)
		local particle1 = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(particle1, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true) 
		ParticleManager:SetParticleControlEnt(particle1, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true) 
		local spreadheal = heal - difference
		local allies = FindUnitsInRadius(caster:GetTeam(),
                              caster:GetAbsOrigin(),
                              caster,
                              ability:GetSpecialValueFor("aura_radius"),
                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
		for _, ally in pairs(allies) do
			if spreadheal > 0 then
				if ally:GetHealth() < ally:GetMaxHealth() then
					if ally:GetHealth() + spreadheal > ally:GetMaxHealth() then
						local consumed = ally:GetMaxHealth() - ally:GetHealth()
						ally:Heal(consumed, caster)
						local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
						ParticleManager:SetParticleControlEnt(particle2, 0, ally, PATTACH_POINT_FOLLOW, "attach_hitloc", ally:GetAbsOrigin(), true) 
						ParticleManager:SetParticleControlEnt(particle2, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true) 
						spreadheal = heal - consumed
					else
						ally:Heal(spreadheal, caster)
						local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
						ParticleManager:SetParticleControlEnt(particle2, 0, ally, PATTACH_POINT_FOLLOW, "attach_hitloc", ally:GetAbsOrigin(), true) 
						ParticleManager:SetParticleControlEnt(particle2, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true) 
						break
					end
				end
			else
				break
			end
		end
	else
		caster:Heal(heal, caster)
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true) 
		ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true) 
	end
	ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType(), ability = ability})
end