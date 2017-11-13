require("libraries/utility")

function FlashFire( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.modifier
	local radius = ability:GetTalentSpecialValueFor("radius")
	local chance = ability:GetTalentSpecialValueFor("chance")
	if caster:IsIllusion() then return end
	if not ability.burning_spears then 
		ability.burning_spears = caster:FindAbilityByName("huskar_burning_spear")
		ability.spearlevel = ability.burning_spears:GetLevel()
	end
	if not ability.damage then 
		ability.damage = ability.burning_spears:GetAbilityDamage() 
	elseif ability.burning_spears:GetLevel() > ability.spearlevel then 
		ability.damage = ability.burning_spears:GetAbilityDamage() 
	end
	if not ability.prng then ability.prng = 0 end
	if ability:IsCooldownReady() and math.random(100-ability.prng) < chance then
		ability:StartCooldown(ability:GetCooldown(-1)*get_octarine_multiplier(caster))
		ability:ApplyDataDrivenModifier(caster,caster,modifier,{})
		ability.prng = 0
	else
		ability.prng = ability.prng + 1
	end
end

function FlashFireDamage( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetTalentSpecialValueFor("radius")
	local target = keys.target
	local stacks = target:GetModifierStackCount("modifier_huskar_burning_spear_debuff", ability.burning_spears)

	local particle_ground = ParticleManager:CreateParticle("particles/huskar_flashfire_hit.vpcf", PATTACH_ABSORIGIN, target)
    
	ParticleManager:SetParticleControl(particle_ground, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_ground, 1, Vector(radius,radius,radius)) --radius
    ParticleManager:SetParticleControl(particle_ground, 3, target:GetAbsOrigin())
	
	local units = FindUnitsInRadius(caster:GetTeam(),
                              target:GetAbsOrigin(),
                              nil,
                              radius,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
	if stacks == 0 then stacks = 1 end
	if not ability.damage then ability.damage = 0 end
	for _,unit in pairs(units) do
		ApplyDamage({ victim = unit, attacker = caster, damage = stacks*ability.damage, damage_type = ability:GetAbilityDamageType(), ability = ability })
		unit:AddNewModifier(caster, ability.burning_spears,"modifier_huskar_burning_spear_counter", {duration = ability.burning_spears:GetLevel(), damage = ability.burning_spears:GetAbilityDamage()})
		local hitspark = ParticleManager:CreateParticle("particles/huskar_flashfire_spark.vpcf", PATTACH_ABSORIGIN, target)
			ParticleManager:SetParticleControl(hitspark, 0, unit:GetAbsOrigin())
			ParticleManager:SetParticleControl(hitspark, 1, unit:GetAbsOrigin()) --radius
			ParticleManager:SetParticleControl(hitspark, 3, unit:GetAbsOrigin())
	end
end