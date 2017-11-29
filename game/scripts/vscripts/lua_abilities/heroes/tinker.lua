function rearm_start( keys )
    local caster = keys.caster
    local ability = keys.ability
    local abilityLevel = ability:GetLevel()-1
    if abilityLevel <= 3 then 
        ability:ApplyDataDrivenModifier( caster, caster, "modifier_rearm_level_1_datadriven", {} )
    elseif abilityLevel <= 5 then 
        ability:ApplyDataDrivenModifier( caster, caster, "modifier_rearm_level_2_datadriven", {} )
    else
        ability:ApplyDataDrivenModifier( caster, caster, "modifier_rearm_level_3_datadriven", {} )
    end
end

function rearm_refresh_cooldown( keys )
    local caster = keys.caster
    local ability = keys.ability
    -- Reset cooldown for abilities
    for i = 0, caster:GetAbilityCount() - 1 do
        local ability = caster:GetAbilityByIndex( i )
        if ability and ability ~= keys.ability then
            ability:Refresh()
        end
    end

    local no_refresh_item = {["item_ressurection_stone"] = true,
							 ["item_refresher"] = true,
							 ["item_bahamut_chest"]= true,
							 ["item_asura_plate"]= true,
							 ["item_octarine_core4"] = true,
							 ["item_octarine_core5"] = true,
							 ["item_asura_core"] = true,
							 ["item_lifesteal2"] = true,
							 ["item_lifesteal3"] = true,
							 ["item_lifesteal4"] = true,}
	local half_refresh_item = {["item_chronos_shard"] = true, 
							   ["item_blade_mail"] = true,
							   ["item_blade_mail2"] = true,
							   ["item_blade_mail3"] = true,
							   ["item_blade_mail4"] = true,
							   ["item_pixels_guard"] = true,
							   ["item_sheepstick_2"] = true,}
	
    for i = 0, 5 do
        local item = caster:GetItemInSlot( i )
		if item then
			local cd = item:GetCooldownTimeRemaining()
			if not no_refresh_item[ item:GetAbilityName() ] then
				item:Refresh()
			end
			if cd > 1 and half_refresh_item[ item:GetAbilityName() ] then
				item:StartCooldown(cd/2)
			end
		end
    end
end

function heat_seeking_missile_seek_targets( keys )
    -- Variables
    local caster = keys.caster
    local ability = keys.ability
    local particleName = "particles/units/heroes/hero_tinker/tinker_missile.vpcf"
    local modifierDudName = "modifier_heat_seeking_missile_dud"
    local projectileSpeed = 900
    local radius = ability:GetTalentSpecialValueFor( "radius")
    local max_targets = ability:GetTalentSpecialValueFor( "targets")
    local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
    local targetType = DOTA_UNIT_TARGET_ALL
    local targetFlag = ability:GetAbilityTargetFlags() -- DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
    local projectileDodgable = false
    local projectileProvidesVision = false
     if HasCustomScepter(caster) == true or caster:HasScepter() then
		radius = ability:GetTalentSpecialValueFor( "radius_scepter")
		max_targets = ability:GetTalentSpecialValueFor( "targets_scepter")
	end
    -- pick up x nearest target heroes and create tracking projectile targeting the number of targets
    local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, targetTeam, targetType, targetFlag, FIND_CLOSEST, false)  
    -- Seek out target
    local count = 0
    for k, v in pairs( units ) do
        if count < max_targets then
            local projTable = {
                Target = v,
                Source = caster,
                Ability = ability,
                EffectName = particleName,
                bDodgeable = projectileDodgable,
                bProvidesVision = projectileProvidesVision,
                iMoveSpeed = projectileSpeed, 
                vSpawnOrigin = caster:GetAbsOrigin()
            }
            ProjectileManager:CreateTrackingProjectile( projTable )
            count = count + 1
        else
            break
        end
    end
    
    -- If no unit is found, fire dud
    if count == 0 then
        ability:ApplyDataDrivenModifier( caster, caster, modifierDudName, {} )
    end
end

function heat_seeking_missile_seek_damage( keys )
    -- Variables
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local damage = ability:GetAbilityDamage() 
	if HasCustomScepter(caster) == true or caster:HasScepter() then
        damage = ability:GetTalentSpecialValueFor("damage_scepter")
    end
	
    local damageTable = {
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
		ability = ability
    }
    ApplyDamage( damageTable )
    if caster:HasTalent("special_bonus_unique_tinker_3") then
		target:AddNewModifier(caster, ability, "modifier_stunned_generic", {duration = caster:FindTalentValue("special_bonus_unique_tinker_3")})
	end
    -- pick up x nearest target heroes and create tracking projectile targeting the number of targets
end
