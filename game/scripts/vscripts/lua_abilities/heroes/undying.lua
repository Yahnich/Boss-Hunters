
function ZombieLeech(keys)
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local damage = ability:GetAbilityDamage()
	ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType(), ability = ability})
	caster:Heal(damage * get_aether_multiplier(caster),caster)
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	EmitSoundOn("Hero_Bane.Enfeeble.Cast", caster)
	Timers:CreateTimer(0.3,function()
        StopSoundOn("Hero_Bane.Enfeeble.Cast", caster)
    end)
	
		-- Set Control Point 1 for the backstab particle; this controls where it's positioned in the world. In this case, it should be positioned on the victim.
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true) 
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true) 
end

function decay( keys )
    -- Variables
    local ability = keys.ability
    local caster = keys.caster
    local unit_number_decay = 0
    local modifierName = "decay_bonus_health"
    local modifierName_display = "decay_bonus_display"
	local previous_stack_count = 0
	if caster:HasModifier(modifierName_display) then
		previous_stack_count = caster:GetModifierStackCount(modifierName_display, keys.caster)
			
		--We have to remove and replace the modifier so the duration will refresh.
		caster:RemoveModifierByNameAndCaster(modifierName_display, keys.caster)
	end
	
    local dummyModifierName = "modifier_mystic_flare_dummy_vfx_datadriven"
    local radius = ability:GetTalentSpecialValueFor( "radius")
    local duration = ability:GetTalentSpecialValueFor( "duration")
    local target = keys.target_points[1]
    local damage = ability:GetTalentSpecialValueFor( "damage")
    local bonus_health = ability:GetTalentSpecialValueFor( "health_bonus_per_unit")
    -- Create for VFX particles on ground
    local dummy = CreateUnitByName( "npc_dummy_unit", target, false, caster, caster, caster:GetTeamNumber() )
    ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {} )
    
    local units = FindUnitsInRadius(caster:GetTeam(),
                              target,
                              caster,
                              radius,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
							  
							  
	EmitSoundOn("Hero_Undying.Decay.Cast", caster)
    for _,unit in pairs(units) do
		EmitSoundOn("Hero_Undying.Decay.Transfer", unit)
		EmitSoundOn("Hero_Undying.Decay.Target", unit)
        local damageTable = {
                                victim = unit,
                                attacker = caster,
                                damage = damage,
                                ability = keys.ability,
                                damage_type = DAMAGE_TYPE_MAGICAL
                            }
        ApplyDamage( damageTable )
		if caster:GetHealth() < caster:GetMaxHealth() then
			caster:SetHealth(caster:GetHealth()+bonus_health)
		else
			caster:SetHealth(caster:GetMaxHealth())
		end
        unit_number_decay = unit_number_decay + 1
		if caster:HasScepter() then
			modifierName = "decay_bonus_strength"
		end
		ability:ApplyDataDrivenModifier( caster, caster, modifierName, {duration = duration})
		
    end
	local cooldown = ability:GetCooldownTimeRemaining()
	ability:EndCooldown()
	ability:StartCooldown( math.floor(cooldown - caster:FindTalentValue("special_bonus_unique_undying_2") * #units) )
	print(cooldown, caster:FindTalentValue("special_bonus_unique_undying_2") , #units )
	ability:ApplyDataDrivenModifier(caster, caster, modifierName_display, {duration = duration})
	caster:SetModifierStackCount(modifierName_display, caster, previous_stack_count + unit_number_decay)
end

function decayBuffOnDestroy(keys)
	if keys.caster:HasModifier("decay_bonus_display") then
		local previous_stack_count = keys.caster:GetModifierStackCount("decay_bonus_display", keys.caster)
		if previous_stack_count > 1 then
			keys.caster:SetModifierStackCount("decay_bonus_display", keys.caster, previous_stack_count - 1)
		else
			keys.caster:RemoveModifierByNameAndCaster("decay_bonus_display", keys.caster)
		end
	end
end


function Soul_Rip(keys)
    local target = keys.target
    local caster = keys.caster
    local ability = keys.ability
    local health = ability:GetTalentSpecialValueFor("health_per_unit")
    local radius = ability:GetTalentSpecialValueFor("range")
    local kill_rand = math.random(1,100)
    local unit_number = 0
    local nearbyUnits = FindUnitsInRadius(target:GetTeam(),
                              target:GetAbsOrigin(),
                              nil,
                              radius,
                              DOTA_UNIT_TARGET_TEAM_BOTH,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
	EmitSoundOn("Hero_Undying.SoulRip.Cast", caster)
    for _,unit in pairs(nearbyUnits) do
		if unit:GetTeamNumber() ~= caster:GetTeamNumber() then
			ApplyDamage( { victim = unit, attacker = caster, damage = health, ability = keys.ability, damage_type = DAMAGE_TYPE_PURE} )
		end
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true) 
		ParticleManager:SetParticleControlEnt(particle, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true) 
        unit_number = unit_number + 1
    end
    Timers:CreateTimer(0.3,function()
        if target:IsAlive() then
            target:SetHealth(target:GetHealth() + (unit_number*health*get_aether_multiplier(caster)) )
			EmitSoundOn("Hero_Undying.SoulRip.Ally", caster)
            if target:GetHealth() >= target:GetMaxHealth() then target:SetHealth(target:GetMaxHealth()) end
        end
    end)

end