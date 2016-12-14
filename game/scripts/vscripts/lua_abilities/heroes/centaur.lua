function DoubleEdgeSelfDamage( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local self_damage = ability:GetTalentSpecialValueFor( "edge_damage" )

	-- Self damage
	ApplyDamage({ victim = caster, attacker = caster, damage = self_damage,	damage_type = ability:GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL })
end

function DoubleEdgeDamage( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetTalentSpecialValueFor( "edge_damage" ) + caster:GetStrength() * ability:GetTalentSpecialValueFor( "edge_str_damage" ) / 100

	ApplyDamage({ victim = target, attacker = caster, damage = damage,	damage_type = ability:GetAbilityDamageType(), ability = ability })
end

function DoubleEdgeParticle( keys )
	local caster = keys.caster
	local target = keys.target

	-- Particle
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_double_edge.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin()) -- Origin
	ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin()) -- Destination
	ParticleManager:SetParticleControl(particle, 5, target:GetAbsOrigin()) -- Hit Glow
end

function CentaurReturn( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local attacker = keys.attacker
	local ability = keys.ability
	local modifier = keys.modifier
	local casterSTR = caster:GetStrength()
	local str_return = ability:GetTalentSpecialValueFor( "strength_pct") * 0.01
	local damage = ability:GetTalentSpecialValueFor( "return_damage")
	local damageType = ability:GetAbilityDamageType()
	local return_damage = damage + ( casterSTR * str_return )

	-- Damage
	ApplyDamage({ victim = attacker, attacker = caster, damage = return_damage, damage_type = damageType, ability = ability })
end