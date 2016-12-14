function Reflection( event )
	print("Reflection Start")

	----- Conjure Image  of the target -----
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local unit_name = target:GetUnitName()
	local origin = target:GetAbsOrigin() + RandomVector(100)
	local duration = ability:GetTalentSpecialValueFor( "illusion_duration")
	local outgoingDamage = ability:GetTalentSpecialValueFor( "illusion_outgoing_damage")

	-- handle_UnitOwner needs to be nil, else it will crash the game.
	local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())

	-- Set the unit as an illusion
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
	illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = 0 })
	illusion:AddNewModifier(caster, ability, "modifier_terrorblade_conjureimage", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = 0 })
	
	-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
	illusion:MakeIllusion()

	-- Apply Invulnerability modifier
	ability:ApplyDataDrivenModifier(caster, illusion, "modifier_reflection_invulnerability", nil)

	-- Force Illusion to attack Target
	illusion:SetForceAttackTarget(target)

	-- Emit the sound, so the destroy sound is played after it dies
	illusion:EmitSound("Hero_Terrorblade.Reflection")

end

--[[Author: Noya
	Date: 11.01.2015.
	Shows the Cast Particle, which for TB is originated between each weapon, in here both bodies are linked because not every hero has 2 weapon attach points
]]
function ReflectionCast( event )

	local caster = event.caster
	local target = event.target
	local particleName = "particles/units/heroes/hero_terrorblade/terrorblade_reflection_cast.vpcf"

	local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, caster )
	ParticleManager:SetParticleControl(particle, 3, Vector(1,0,0))
	
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
end