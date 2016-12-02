function DeathCoil( event )
	-- Variables
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local damage = ability:GetSpecialValueFor( "target_damage")
	local self_heal = ability:GetSpecialValueFor( "self_heal" )
	local heal = ability:GetSpecialValueFor( "heal_amount" )
	local heal_pct = ability:GetSpecialValueFor( "heal_pct" ) / 100
	local projectile_speed = ability:GetSpecialValueFor( "projectile_speed" )
	local particle_name = "particles/units/heroes/hero_abaddon/abaddon_death_coil.vpcf"

	-- Play the ability sound
	caster:EmitSound("Hero_Abaddon.DeathCoil.Cast")
	target:EmitSound("Hero_Abaddon.DeathCoil.Target")

	-- If the target and caster are on a different team, do Damage. Heal otherwise
	if target:GetTeamNumber() ~= caster:GetTeamNumber() then
		ApplyDamage({ victim = target, attacker = caster, damage = damage,	damage_type = DAMAGE_TYPE_MAGICAL })
	else
		target:Heal( heal + target:GetMaxHealth()*heal_pct, caster)
	end

	-- Self Damage
	caster:Heal(self_heal + caster:GetMaxHealth()*heal_pct, caster)

	local mistCoil = ParticleManager:CreateParticle(particle_name, PATTACH_POINT_FOLLOW, target)
			ParticleManager:SetParticleControlEnt(mistCoil, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(mistCoil, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(mistCoil, 3, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(mistCoil, 9, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

end