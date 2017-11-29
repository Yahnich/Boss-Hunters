--[[
    Mystic flare Author: kritth
    Date: 09.01.2015.
    Deal constant interval damage shared in the radius
]]

function mystic_flare_scepter_check(keys)
	local caster = keys.caster
	local ability = keys.ability
	local scepter_cooldown = ability:GetTalentSpecialValueFor( "scepter_cooldown")
	if HasCustomScepter(caster) == true or caster:HasScepter() and ability:GetCooldownTimeRemaining() > scepter_cooldown*get_octarine_multiplier(caster) then
		ability:EndCooldown()
		ability:StartCooldown(scepter_cooldown*get_octarine_multiplier(caster))
	end

end


function mystic_flare_start( keys )
    -- Variables
    local ability = keys.ability
    local caster = keys.caster
    local current_instance = 0
    local dummyModifierName = "modifier_mystic_flare_dummy_vfx_datadriven"
    local duration = ability:GetTalentSpecialValueFor( "duration")
    local interval = ability:GetTalentSpecialValueFor( "damage_interval")
    local max_instances = math.floor( duration / interval )
    local radius = ability:GetTalentSpecialValueFor( "radius")
    local target = keys.target_points[1]
    local total_damage = ability:GetTalentSpecialValueFor( "damage")
    local targetTeam = ability:GetAbilityTargetTeam() -- DOTA_UNIT_TARGET_TEAM_ENEMY
    local targetType = ability:GetAbilityTargetType() -- DOTA_UNIT_TARGET_HERO
    local targetFlag = ability:GetAbilityTargetFlags() -- DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
    local damageType = ability:GetAbilityDamageType() -- DAMAGE_TYPE_MAGICAL
    local soundTarget = "Hero_SkywrathMage.MysticFlare.Target"
	if HasCustomScepter(caster) == true or caster:HasScepter() then
		local current_instance_scepter = 0
		damageType = DAMAGE_TYPE_PURE
		local search_radius = ability:GetTalentSpecialValueFor( "search_radius_scepter")
		local target_scepter = caster:GetOrigin() + RandomVector(search_radius)
		local target_scepter_units = FindUnitsInRadius(caster:GetTeam(),
								  target,
								  caster,
								  search_radius,
								  DOTA_UNIT_TARGET_TEAM_ENEMY,
								  DOTA_UNIT_TARGET_ALL,
								  DOTA_UNIT_TARGET_FLAG_NONE,
								  FIND_ANY_ORDER,
								  false)
		for _,unit in pairs(target_scepter_units) do
			if (unit:GetOrigin() - target):Length2D() > radius then
				target_scepter = unit:GetOrigin()
			end
		end
		local dummy_scepter = CreateUnitByName( "npc_dummy_unit", target_scepter, false, caster, caster, caster:GetTeamNumber() )
		ability:ApplyDataDrivenModifier( caster, dummy_scepter, dummyModifierName, {} )
		
		-- Referencing total damage done per interval
		local damage_per_interval = total_damage / max_instances
		
		-- Deal damage per interval equally
		Timers:CreateTimer( function()
				local units = FindUnitsInRadius(caster:GetTeam(),
								  target_scepter,
								  caster,
								  radius,
								  DOTA_UNIT_TARGET_TEAM_ENEMY,
								  DOTA_UNIT_TARGET_ALL,
								  DOTA_UNIT_TARGET_FLAG_NONE,
								  FIND_ANY_ORDER,
								  false)
				if #units > 0 then
					local damage_per_hero = damage_per_interval/(#units)
					for k, v in pairs( units ) do
						-- Apply damage
						local damageTable = {
									victim = v,
									attacker = caster,
									damage = damage_per_hero,
									damage_type = damageType,
									ability = ability
								}
						ApplyDamage(damageTable)
						
						-- Fire sound
						StartSoundEvent( soundTarget, v )
					end
				end
				
				current_instance_scepter = current_instance_scepter + 1
				
				-- Check if maximum instances reached
				if current_instance_scepter >= max_instances then
					dummy_scepter:Destroy()
					return nil
				else
					return interval
				end
			end
		)
	end
	
    
    -- Create for VFX particles on ground
    local dummy = CreateUnitByName( "npc_dummy_unit", target, false, caster, caster, caster:GetTeamNumber() )
    ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {} )
    
    -- Referencing total damage done per interval
    local damage_per_interval = total_damage / max_instances
    
    -- Deal damage per interval equally
    Timers:CreateTimer( function()
            local units = FindUnitsInRadius(caster:GetTeam(),
                              target,
                              caster,
                              radius,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
            if #units > 0 then
                local damage_per_hero = damage_per_interval/(#units)
                for k, v in pairs( units ) do
                    -- Apply damage
                    local damageTable = {
                                victim = v,
                                attacker = caster,
                                damage = damage_per_hero,
                                damage_type = damageType,
								ability = ability
                            }
                    ApplyDamage(damageTable)
                    
                    -- Fire sound
                    StartSoundEvent( soundTarget, v )
                end
            end
            
            current_instance = current_instance + 1
            
            -- Check if maximum instances reached
            if current_instance >= max_instances then
                dummy:Destroy()
                return nil
            else
                return interval
            end
        end
    )
end


function concussive_shot_seek_target( keys )
    -- Variables
    local caster = keys.caster
    local ability = keys.ability
    local particle_name = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot.vpcf"
    local radius = ability:GetTalentSpecialValueFor( "launch_radius")
	if caster:HasTalent("special_bonus_unique_skywrath_4") then radius = -1 end
    local speed = ability:GetTalentSpecialValueFor( "speed")
    local targetTeam = ability:GetAbilityTargetTeam() -- DOTA_UNIT_TARGET_TEAM_ENEMY
    local targetType = ability:GetAbilityTargetType() -- DOTA_UNIT_TARGET_HERO
    local targetFlag = ability:GetAbilityTargetFlags() -- DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
	local targets = 1
	if caster:HasScepter() then targets = 2 end
    
    -- pick up x nearest target heroes and create tracking projectile targeting the number of targets
    local units = FindUnitsInRadius(caster:GetTeam(),
                              caster:GetAbsOrigin(),
                              caster,
                              radius,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_CLOSEST, 
                              false
    )
    
    -- Seek out target
    for k, v in pairs( units ) do
        local projTable = {
            EffectName = particle_name,
            Ability = ability,
            Target = v,
            Source = caster,
            bDodgeable = true,
            bProvidesVision = true,
            vSpawnOrigin = caster:GetAbsOrigin(),
            iMoveSpeed = speed,
            iVisionRadius = radius,
            iVisionTeamNumber = caster:GetTeamNumber(),
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
        }
		targets = targets - 1
        ProjectileManager:CreateTrackingProjectile( projTable )
		if targets == 0 then return end
    end
end

--[[
    Author: kritth
    Date: 8.1.2015.
    Give post attack vision
]]
function concussive_shot_damage( keys )
    local ability = keys.ability
	ApplyDamage({ victim = keys.target, attacker = keys.caster, damage = keys.damage, damage_type = ability:GetAbilityDamageType(), ability = ability })
end