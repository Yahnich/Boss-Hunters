function CounterHelix( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local helix_modifier = keys.helix_modifier

    -- If the caster has the helix modifier then do not trigger the counter helix
    -- as its considered to be on cooldown
    if target == caster and not caster:HasModifier(helix_modifier) then
        ability:ApplyDataDrivenModifier(caster, caster, helix_modifier, {})
		ability:StartCooldown(ability:GetCooldown(-1))
    end
end

function CounterHelixDamage( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
	
	local armor = caster:GetPhysicalArmorValue()
	local armor_to_damage = ability:GetSpecialValueFor("armor_to_damage") * armor
    ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage() + armor_to_damage, damage_type = ability:GetAbilityDamageType(), ability = ability})
end


function axe_culling_blade_fct(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local ability_level = ability:GetLevel() - 1
    local kill_threshold = ability:GetLevelSpecialValueFor( "kill_threshold", ability_level ) / 100
	local damageType = DAMAGE_TYPE_PHYSICAL
    local damage = ability:GetLevelSpecialValueFor( "damage", ability_level ) / 100
	if caster:HasScepter() then
		kill_threshold = ability:GetLevelSpecialValueFor( "kill_threshold_scepter", ability_level ) / 100
		damageType = DAMAGE_TYPE_MAGICAL
	end
    if target:GetUnitName() ~= "npc_dota_boss36" then
        if target:GetHealth() <= kill_threshold * target:GetMaxHealth() then
            StartSoundEvent("Hero_Axe.Culling_Blade_Success", target )
            local kill_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_ABSORIGIN , target)
            ParticleManager:SetParticleControl(kill_effect, 0, target:GetAbsOrigin())
            ParticleManager:SetParticleControl(kill_effect, 1, target:GetAbsOrigin())
            ParticleManager:SetParticleControl(kill_effect, 2, target:GetAbsOrigin())
            ParticleManager:SetParticleControl(kill_effect, 3, target:GetAbsOrigin())
            ParticleManager:SetParticleControl(kill_effect, 4, target:GetAbsOrigin())
            target:ForceKill(true)
            ability:EndCooldown()
        else
            local damageTable = {
                victim = target,
                attacker = caster,
                damage = damage * target:GetMaxHealth()/get_aether_multiplier(caster),
                ability = keys.ability,
                damage_type = damageType
            }
            ApplyDamage(damageTable)
            StartSoundEvent("Hero_Axe.Culling_Blade_Fail", target )
        end
    else
        ability:EndCooldown()
    end
	ability:ApplyDataDrivenModifier( caster, caster, "axe_culling_boost", {duration = keys.duration} )
end

function AxeSteeledTemper(keys)
	local caster = keys.caster
    local ability = keys.ability
	
	local strength = caster:GetStrength()
	
	caster:SetModifierStackCount("modifier_axe_steeled_temper", caster, strength)
end