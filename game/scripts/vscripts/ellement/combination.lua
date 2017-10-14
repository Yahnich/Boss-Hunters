--[[ ============================================================================================================
    Author: FrenchDeath
    Date: October 18th 2015
    Ellementalist combine his ellement and cas a spell based on the power of each ellement
================================================================================================================= ]]
require( "libraries/Timers" )
require( "ellement/projectile_hit" )
function Cooldown(keys,cooldown)
    if keys.ability:GetCooldownTimeRemaining() <= cooldown and keys.ability:GetCooldownTimeRemaining() > 0.2  then
        keys.ability:StartCooldown(cooldown)
    end
end

function OnUpgrade(keys)
	local caster = keys.caster
	local this_ability = keys.ability		
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_name = keys.sibling
	local ability_handle = caster:FindAbilityByName(ability_name)	
	local ability_level = ability_handle:GetLevel()

	-- Check to not enter a level up loop
	if ability_level ~= this_abilityLevel then
		ability_handle:SetLevel(this_abilityLevel)
	end
end

function On_Spell_Start( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	if keys.caster.invoked_orbs == nil then return end
    print (keys.ability:GetCooldownTimeRemaining())
    
	caster.last_used_skill = "none"
    caster.projectile_table = {}
	caster.invocation_power_fire = 0
	caster.invocation_power_wind = 0
	caster.invocation_power_ice = 0
    keys.ability:ApplyDataDrivenModifier(caster, caster, "cast_animation", {duration = 1})
	local number_of_orb = table.getn(caster.invoked_orbs_particle_attach or {})

	local invoke_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_invoke.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)

	for i=1, number_of_orb, 1 do
		if keys.caster.invoked_orbs[i] ~= nil then
            local orb_name = keys.caster.invoked_orbs[i]:GetName()
            if orb_name == "invoker_wind_ellement" then
                local wind_ability = keys.caster:FindAbilityByName("invoker_wind_ellement")

                local wind_power = wind_ability:GetLevelSpecialValueFor("ellement_power", wind_ability:GetLevel() - 1)
                caster.invocation_power_wind = wind_power + caster.invocation_power_wind 
            elseif orb_name == "invoker_fire_ellement" then
                local fire_ability = keys.caster:FindAbilityByName("invoker_fire_ellement")
                local fire_power = fire_ability:GetLevelSpecialValueFor("ellement_power", fire_ability:GetLevel() - 1)
                caster.invocation_power_fire = fire_power + caster.invocation_power_fire
            elseif orb_name == "invoker_ice_ellement" then
                local ice_ability = keys.caster:FindAbilityByName("invoker_ice_ellement")
                local ice_power = ice_ability:GetLevelSpecialValueFor("ellement_power", ice_ability:GetLevel() - 1)
                caster.invocation_power_ice = ice_power + caster.invocation_power_ice
            end
        end
	end
	local ice_color = Vector(0, 153, 204)
    local wind_color = Vector(204, 0, 153)
    local fire_color = Vector(255, 102, 0)
	ParticleManager:SetParticleControl(invoke_particle_effect, 2, ((ice_color * caster.invocation_power_ice) + (fire_color * caster.invocation_power_fire) + (wind_color * caster.invocation_power_wind)) / (caster.invocation_power_ice + caster.invocation_power_wind + caster.invocation_power_fire))
	local ice = caster.invocation_power_ice
    local wind = caster.invocation_power_wind
    local fire = caster.invocation_power_fire

    --Skill with Main ellement : Fire
    if fire > (ice + wind)*1.5 then --Very High Damage + DoT
		if fire > 2.51 and fire <= 5 then
			caster.last_used_skill = "fire_spear"
            Cooldown(keys,5)
			projectile_fire_spear( keys )
		elseif fire > 5 and fire <= 10 then
            caster.last_used_skill = "multiple_fire_spear"
            Cooldown(keys,5)
			projectile_multiple_fire_spear( keys , fire)
		elseif fire > 10 then
			caster.last_used_skill = "explosive_fire_spear"
            Cooldown(keys,5)
            projectile_fire_spear( keys )
		else
			poweraura( keys , fire)
		end
	elseif wind > (ice+fire)*1.5 then --medium/High damage + slow + knockback
		if wind >= 2.51 and wind <= 5 then
            caster.last_used_skill = "wind_stream"
            Cooldown(keys,5)
			wind_stream(keys,wind)
		elseif wind >= 5 and wind <= 10 then
            caster.last_used_skill = "Turnado"
            Cooldown(keys,5)
			Turnado(keys,wind)
		elseif wind > 10 then
            caster.last_used_skill = "Tempest"
            Cooldown(keys,5)
			Tempest(keys,wind)
		else
			speedaura( keys , wind)
		end
	elseif ice > (wind + fire)*1.5 then --Low Damage , Slow/disable
		if ice >= 2.51 and ice <= 5 then
			Cooldown(keys,5)
			ice_spike(keys , ice)
		elseif ice > 5 and ice <= 10 then
			Cooldown(keys,5)
			frost_spike(keys , ice)
		elseif ice > 10 then
			Cooldown(keys,5)
			frost_kiss( keys, ice)
		else
			Cooldown(keys,2)
			frosttouch( keys )
		end
	elseif ice + fire > 2*wind then 
		if fire >= 1.5*ice then 
			if ice + fire >= 10 then --high Damage
                caster.last_used_skill = "steam_tempest"
                Cooldown(keys,5)
				steam_tempest(keys,ice,fire)
			else
                caster.last_used_skill = "steam_trail"
                Cooldown(keys,5)
				steam_trail(keys,ice,fire)
			end
		elseif ice >= 1.5*fire then --Slow + DoT , medium damage
			if ice + fire >= 10 then
                caster.last_used_skill = "IceFlame_Ball"
                Cooldown(keys,5)
                IceFlame_Ball(keys,ice,fire)
			else
                Explosive_IceFlame(keys,ice,fire)
			end
		else 
			if ice + fire >= 10 then --Disable/slow , medium damage
                caster.last_used_skill = "water_tempest"
                Cooldown(keys,5)
				water_tempest(keys,ice,fire)
			else
                caster.last_used_skill = "water_stream"
                Cooldown(keys,5)
				water_stream(keys,ice,fire)
			end
		end
	elseif ice + wind > 2*fire then --Medium/Low damage ,High slow and disable
		if ice >= 1.5*wind then
                caster.last_used_skill = "Heavy_Ice_Projectile"
                Cooldown(keys,5)
                Heavy_Ice_Projectile(keys,ice,wind)
		elseif wind >= 1.5*ice then
			if ice + wind >= 10 then
			    caster.last_used_skill = "Blizzard"
                Cooldown(keys,5)
                Blizzard(keys,wind,ice)
            else
                caster.last_used_skill = "Ice_Tornado"
                Cooldown(keys,5)
                Ice_Tornado(keys,wind,fire)
			end
		else
			if ice + wind >= 10 then
				caster.last_used_skill = "iceshard2"
                Cooldown(keys,2)
				projectile_iceshard2(keys , ice, wind, fire)
			else 
				caster.last_used_skill = "iceshard1"
                Cooldown(keys,2)
				projectile_iceshard1(keys , ice, wind, fire)
			end
		end
	elseif wind + fire > 2* ice then --Very High Damage and DoT
		if fire >= 1.5*wind then
                caster.last_used_skill = "fire_ball"
                Cooldown(keys,5)
				fire_ball(keys,wind,fire)
		elseif wind >= 1.5*fire then
			if fire + wind >= 10 then
				Fire_Explosion(keys,wind,fire)
			end
		else 
			if fire + wind >= 10 then
                caster.last_used_skill = "Fire_Tempest"
                Cooldown(keys,5)
				Fire_Tempest(keys,wind,fire)
			else
                caster.last_used_skill = "Fire_Tornado"
                Cooldown(keys,5)
				Fire_Turnado(keys,wind,fire)
			end
		end
	else
		if fire + wind + ice >= 7.5 and fire + wind + ice < 12 then
			global_heal( keys, fire, ice, wind)
		elseif fire + wind + ice >= 12 then
            caster.last_used_skill = "arcana_laser"
            arcana_laser(keys,ice,fire,wind)
            Cooldown(keys,15)
            for itemSlot = 0, 5, 1 do
                local Item = caster:GetItemInSlot( itemSlot )
                if Item ~= nil and Item:GetName() == "item_element_refresher" then
                    Item:StartCooldown(15)
                end
            end
		else
			personal_heal( keys, fire, ice, wind)
		end
	end
end

function Heavy_Ice_Projectile(keys,ice,wind)
    local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
    local caster = keys.caster

    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/ice_spear_heavy.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = 1000,
        fStartRadius = 200 + (wind + ice)*5,
        fEndRadius = 200 + (wind + ice)*5,
        fExpireTime = GameRules:GetGameTime() + 2,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * 500
    }
    Ice_projectile = ProjectileManager:CreateLinearProjectile( projectileTable )
    caster.projectile_table[1] = Ice_projectile
    local fv = caster:GetForwardVector()
    Timers:CreateTimer(2.00,function()
                            local explosion_position = (casterPoint+(fv * 1300))
                            StartSoundEventFromPosition("Hero_Crystal.CrystalNova",explosion_position)
                            local caster = keys.caster 
                            local damage_AoE = (keys.caster:GetLevel()^0.5)*(ice + wind)^4 + (ice + wind)*600 + (1000 * 2^ability_level)
							print("Heavy_Ice_Projectile", damage_AoE)
                            local radius = ice*25 + 400
                            local nearbyUnits = FindUnitsInRadius(caster:GetTeam(),
                                                      explosion_position,
                                                      nil,
                                                      radius,
                                                      DOTA_UNIT_TARGET_TEAM_ENEMY,
                                                      DOTA_UNIT_TARGET_ALL,
                                                      DOTA_UNIT_TARGET_FLAG_NONE,
                                                      FIND_ANY_ORDER,
                                                      false)
                            for _,unit in pairs(nearbyUnits) do
                                    local damageTableAoe = {victim = unit,
                                                attacker = caster,
                                                damage = damage_AoE,
                                                damage_type = DAMAGE_TYPE_MAGICAL,
												ability = keys.ability
                                                }
                                    ApplyDamage(damageTableAoe)
                        
                                    keys.ability:ApplyDataDrivenModifier(keys.caster, unit, "ice_freeze_display", {duration = (ice/5)})
                                    keys.ability:ApplyDataDrivenModifier(keys.caster, unit, "ice_freeze", {duration = (ice/5)})
                                    local ice_freeze_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf", PATTACH_ABSORIGIN  , unit)
                                    ParticleManager:SetParticleControl(ice_freeze_effect, 0, unit:GetAbsOrigin())
                                    ParticleManager:SetParticleControl(ice_freeze_effect, 1, unit:GetAbsOrigin())
                                    Timers:CreateTimer((ice/5),function()
                                        ParticleManager:DestroyParticle(ice_freeze_effect, false)
                                    end)

                            end
                            local ice_explosion_effect = ParticleManager:CreateParticle("particles/crystal_spike_aoe.vpcf", PATTACH_ABSORIGIN  , keys.caster)
                            ParticleManager:SetParticleControl(ice_explosion_effect, 0, explosion_position)
                            ParticleManager:SetParticleControl(ice_explosion_effect, 1, explosion_position)
                            Timers:CreateTimer(3,function()
                                            ParticleManager:DestroyParticle(ice_explosion_effect, false)
                                        end)
                end)
end

function Explosive_IceFlame(keys,ice,fire)
        local caster = keys.caster 
		local ability_level = keys.ability:GetLevel() - 1
        local damage_AoE = ((keys.caster:GetLevel()^0.5)*(ice + fire)^4*1.25 + (ice + fire)*1500  + (1000 * 2^ability_level))*2
        print("Explosive_IceFlame", damage_AoE, (1000 * 2^ability_level))
		local radius = ice*25 + 400
        local nearbyUnits = FindUnitsInRadius(caster:GetTeam(),
                                  caster:GetAbsOrigin(),
                                  nil,
                                  radius,
                                  DOTA_UNIT_TARGET_TEAM_ENEMY,
                                  DOTA_UNIT_TARGET_ALL,
                                  DOTA_UNIT_TARGET_FLAG_NONE,
                                  FIND_ANY_ORDER,
                                  false)
        for _,unit in pairs(nearbyUnits) do
                local damageTableAoe = {victim = unit,
                            attacker = caster,
                            damage = damage_AoE,
                            damage_type = DAMAGE_TYPE_MAGICAL,
							ability = keys.ability
                            }
                ApplyDamage(damageTableAoe)
                Fire_Dot(keys, caster, unit,math.floor((fire/2)^2*((keys.caster:GetLevel()^0.6/2))*25 + (333 * 2^ability_level)))
                keys.ability:ApplyDataDrivenModifier(keys.caster, unit, "iceflame_display", {duration = 5})
                keys.ability:ApplyDataDrivenModifier(keys.caster, unit, "slow_modifier", {duration = 5})
                unit:SetModifierStackCount( "slow_modifier", keys.ability, math.floor(ice*(20) ) )

                ice_flame_debuff_effect = ParticleManager:CreateParticle("particles/ice_flame_debuff.vpcf", PATTACH_ABSORIGIN , unit)
                ParticleManager:SetParticleControl(ice_flame_debuff_effect, 0, unit:GetAbsOrigin())
                ParticleManager:SetParticleControl(ice_flame_debuff_effect, 1, unit:GetAbsOrigin())

                Timers:CreateTimer(5,function()
                        ParticleManager:DestroyParticle( ice_flame_debuff_effect, false)
                end)

        end
        fire_explosion_effect = ParticleManager:CreateParticle("particles/ice_ball_explosion.vpcf", PATTACH_ABSORIGIN , caster)
        caster:EmitSound("Hero_Techies.Suicide")
        ParticleManager:SetParticleControl(fire_explosion_effect, 0, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(fire_explosion_effect, 5, caster:GetAbsOrigin())
		Timers:CreateTimer(5,function()
                        ParticleManager:DestroyParticle( fire_explosion_effect, false)
                end)
end

function IceFlame_Ball(keys,ice,fire)
    local ability = keys.ability
    local caster = keys.caster

    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/ice_ball_final.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = (ice + fire)*200 + 100,
        fStartRadius = 20 + (ice + fire)*5,
        fEndRadius = 20 + (ice + fire)*5,
        fExpireTime = GameRules:GetGameTime() + 5,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * 1000,
        vAcceleration = caster:GetForwardVector() * 200
    }
    iceflame_ball_projectile = ProjectileManager:CreateLinearProjectile( projectileTable )
    caster.projectile_table[1] = iceflame_ball_projectile
end


function arcana_laser(keys,ice,fire)
    local ability = keys.ability
    local caster = keys.caster
    local begin_time = GameRules:GetGameTime()
    local casterPoint = caster:GetAbsOrigin()
    keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_arcana_laser_charge", {duration = 5})


    local pathStartPos = caster:GetAbsOrigin() * Vector( 1, 1, 0 )
    local pathEndPos = pathStartPos + caster:GetForwardVector() * 2000

    Timers:CreateTimer(2.45,function()
            caster:EmitSound("Hero_Phoenix.SunRay.Cast")
            caster:EmitSound("Hero_Phoenix.SunRay.Loop")
            arcana_laser_effect = ParticleManager:CreateParticle( "particles/arcana_laser.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster )
            ParticleManager:SetParticleControlEnt( arcana_laser_effect, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )
    end)
	Timers:CreateTimer(5,function()
                        ParticleManager:DestroyParticle( arcana_laser_effect, false)
                end)


    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/econ/items/luna/luna_lucent_ti5_gold/luna_eclipse_cast_moonlight_glow04_ti_5_gold.vpcf",
        --EffectName = "particles/laser_test.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = 2000,
        fStartRadius = 50,
        fEndRadius = 50,
        fExpireTime = GameRules:GetGameTime() + 10,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * 10000,
        vAcceleration = caster:GetForwardVector() * 10
    }
    local created_projectile = 0
    Timers:CreateTimer(2.5, function()
        if GameRules:GetGameTime() <= begin_time+10 then
            projectileTable.vSpawnOrigin = caster:GetAbsOrigin()
            projectileTable.vVelocity = caster:GetForwardVector() * 10000
            water_projectile = ProjectileManager:CreateLinearProjectile( projectileTable )

            local laser_position = caster:GetAbsOrigin() + 2000*caster:GetForwardVector()
            laser_position = GetGroundPosition( laser_position, nil )
            laser_position.z = laser_position.z + 92
            ParticleManager:SetParticleControl( arcana_laser_effect, 1, laser_position )
            return 0.015
        else 
            StopSoundEvent( "Hero_Phoenix.SunRay.Cast", caster )
            StopSoundEvent( "Hero_Phoenix.SunRay.Loop", caster )
            ParticleManager:DestroyParticle(arcana_laser_effect, false)
			ParticleManager:ReleaseParticleIndex(arcana_laser_effect)
            return
        end
    end)
end

function Fire_Explosion(keys,wind,fire)
        local caster = keys.caster 
		local ability_level = keys.ability:GetLevel() - 1
        local damage_AoE = (keys.caster:GetLevel()^0.5)*(wind + fire)^4*2 + (wind + fire)*2000 + (1000 * 2^ability_level)
        print("Fire_Explosion", damage_AoE)
		local radius = wind*25 + 400
        local nearbyUnits = FindUnitsInRadius(caster:GetTeam(),
                                  caster:GetAbsOrigin(),
                                  nil,
                                  radius,
                                  DOTA_UNIT_TARGET_TEAM_ENEMY,
                                  DOTA_UNIT_TARGET_ALL,
                                  DOTA_UNIT_TARGET_FLAG_NONE,
                                  FIND_ANY_ORDER,
                                  false)
        for _,unit in pairs(nearbyUnits) do
                local damageTableAoe = {victim = unit,
                            attacker = caster,
                            damage = damage_AoE,
                            damage_type = DAMAGE_TYPE_MAGICAL,
							ability = keys.ability
                            }
                ApplyDamage(damageTableAoe)
                keys.ability:ApplyDataDrivenModifier(caster, unit, "fire_dot_display", {duration = 5+1})
                Fire_Dot(keys, caster, unit,math.floor((fire/2)^2*((keys.caster:GetLevel()^0.6/2))*25 + (333 * 2^ability_level)))
        end
        fire_explosion_effect = ParticleManager:CreateParticle("particles/fire_ball_explosion.vpcf", PATTACH_ABSORIGIN , caster)
        caster:EmitSound("Hero_Techies.Suicide")
        ParticleManager:SetParticleControl(fire_explosion_effect, 0, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(fire_explosion_effect, 5, caster:GetAbsOrigin())
		Timers:CreateTimer(5,function()
                        ParticleManager:DestroyParticle( fire_explosion_effect, false)
                end)
end

function fire_ball(keys,wind,fire)
    local ability = keys.ability
    local caster = keys.caster

    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/fire_ball_final.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = (wind + fire)*200 + 100,
        fStartRadius = 20 + (wind + fire)*5,
        fEndRadius = 20 + (wind + fire)*5,
        fExpireTime = GameRules:GetGameTime() + 5,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * 1000,
        vAcceleration = caster:GetForwardVector() * 200
    }
    fire_ball_projectile = ProjectileManager:CreateLinearProjectile( projectileTable )
    caster.projectile_table[1] = fire_ball_projectile
end


function steam_trail(keys,ice,fire)
    local ability = keys.ability
    local caster = keys.caster
	caster.projectilesElementalist = (math.floor(ice + fire)*3)
    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/stream_wave.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = (ice + fire)*200 + 100,
        fStartRadius = 200 + (ice + fire)*20,
        fEndRadius = 200 + (ice + fire)*20,
        fExpireTime = GameRules:GetGameTime() + 5,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * 1000,
        vAcceleration = caster:GetForwardVector() * 200
    }
    local created_projectile = 0
    Timers:CreateTimer(0.03, function()
        created_projectile = created_projectile + 1
        projectileTable.vSpawnOrigin = caster:GetAbsOrigin()
        water_projectile = ProjectileManager:CreateLinearProjectile( projectileTable )
        if created_projectile <= caster.projectilesElementalist then
            return 0.03
        end
    end)
end

function steam_tempest(keys,ice,fire)
    local ability = keys.ability
    local caster = keys.caster
    local fv = caster:GetForwardVector()
    local casterPoint = caster:GetAbsOrigin()
	caster.projectilesElementalist = (math.floor(ice + fire)*3)
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/water_wave.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = (ice + fire)*200 + 100,
        fStartRadius = 200 + (ice + fire)*20,
        fEndRadius = 200 + (ice + fire)*20,
        fExpireTime = GameRules:GetGameTime() + 5,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * 1000,
        vAcceleration = caster:GetForwardVector() * 200
    }
    local created_projectile = 0
    Timers:CreateTimer(0.03, function()
        created_projectile = created_projectile + 1
        angle = (created_projectile*360)/caster.projectilesElementalist
        projectileTable.vSpawnOrigin = caster:GetAbsOrigin()
        projectileTable.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,angle-60,0), fv) * 600
        water_projectile = ProjectileManager:CreateLinearProjectile( projectileTable )
        if created_projectile <= caster.projectilesElementalist then
            return 0.03
        end
    end)
end

function water_tempest(keys,ice,fire)
    local ability = keys.ability
    local caster = keys.caster
	caster.projectilesElementalist = math.floor(ice + fire)
    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/morphling_waveform_test.vpcf",
        EffectName = "particles/units/heroes/hero_morphling/morphling_waveform.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = (ice + fire)*200 + 400,
        fStartRadius = 200 + (ice + fire)*20,
        fEndRadius = 200 + (ice + fire)*20,
        fExpireTime = GameRules:GetGameTime() + 5,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * 1000,
        vAcceleration = caster:GetForwardVector() * 200
    }
    local created_projectile = 0
    Timers:CreateTimer(0.05, function()
        created_projectile = created_projectile + 1
        angle = (created_projectile*90)/caster.projectilesElementalist
        projectileTable.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,angle-60,0), caster:GetForwardVector()) * 600
        water_projectile = ProjectileManager:CreateLinearProjectile( projectileTable )
        if created_projectile <= caster.projectilesElementalist then
            return 0.05
        end
    end)
end

function water_stream(keys,ice,fire)
    local ability = keys.ability
    local caster = keys.caster

    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
	caster.projectilesElementalist = 1
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/units/heroes/hero_morphling/morphling_waveform.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = (ice + fire)*200 + 400,
        fStartRadius = 200 + (ice + fire)*20,
        fEndRadius = 200 + (ice + fire)*20,
        fExpireTime = GameRules:GetGameTime() + 5,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * 1000,
        vAcceleration = caster:GetForwardVector() * 200
    }
    wind_stream_projectile = ProjectileManager:CreateLinearProjectile( projectileTable )
end


function Ice_Tornado(keys,wind,ice)
    local ability = keys.ability
    local caster = keys.caster

    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/ice_tornado.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = wind*500 + 300,
        fStartRadius = 150 + wind*20,
        fEndRadius = 150 + wind*20,
        fExpireTime = GameRules:GetGameTime() + 5,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * 1000,
        vAcceleration = caster:GetForwardVector() * 200
    }
    ice_tornado_projectile = ProjectileManager:CreateLinearProjectile( projectileTable )
end

function Blizzard(keys,wind,ice)
    local ability = keys.ability
    local caster = keys.caster
    print ("Blizzard")

    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/ice_tornado.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = wind*500 + 300,
        fStartRadius = 150 + wind*20,
        fEndRadius = 150 + wind*20,
        fExpireTime = GameRules:GetGameTime() + 5,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * 1000,
        vAcceleration = caster:GetForwardVector() * 200
    }
    local created_projectile = 0
    Timers:CreateTimer(0.05, function()
        created_projectile = created_projectile + 1
        angle = (created_projectile*90)/math.floor(wind)
        projectileTable.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,angle-60,0), caster:GetForwardVector()) * 600
        ice_tornado_projectile = ProjectileManager:CreateLinearProjectile( projectileTable )
        if created_projectile <= math.floor(wind) then
            return 0.05
        end
    end)
end

function Fire_Turnado(keys,wind,fire)
    local ability = keys.ability
    local caster = keys.caster

    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/fire_tornado.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = wind*500 + 300,
        fStartRadius = 150 + wind*20,
        fEndRadius = 150 + wind*20,
        fExpireTime = GameRules:GetGameTime() + 5,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * 1000,
        vAcceleration = caster:GetForwardVector() * 200
    }
    fire_tornado_projectile = ProjectileManager:CreateLinearProjectile( projectileTable )
end

function Fire_Tempest(keys,wind,fire)
    local ability = keys.ability
    local caster = keys.caster

    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/fire_tornado.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = wind*500 + 300,
        fStartRadius = 150 + wind*20,
        fEndRadius = 150 + wind*20,
        fExpireTime = GameRules:GetGameTime() + 5,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * 1000,
        vAcceleration = caster:GetForwardVector() * 200
    }
    local created_projectile = 0
    Timers:CreateTimer(0.05, function()
        created_projectile = created_projectile + 1
        angle = (created_projectile*90)/math.floor(wind)
        projectileTable.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,angle-60,0), caster:GetForwardVector()) * 600
        fire_tornado_projectile = ProjectileManager:CreateLinearProjectile( projectileTable )
        if created_projectile <= math.floor(wind) then
            return 0.05
        end
    end)
end

function Tempest(keys,wind)
    local ability = keys.ability
    local caster = keys.caster

    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/units/heroes/hero_invoker/invoker_tornado.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = wind*250 + 300,
        fStartRadius = 200 + wind*20,
        fEndRadius = 200 + wind*20,
        fExpireTime = GameRules:GetGameTime() + 5,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * 1000,
        vAcceleration = caster:GetForwardVector() * 200
    }
    local created_projectile = 0
    Timers:CreateTimer(0.05, function()
        created_projectile = created_projectile + 1
        angle = (created_projectile*90)/math.floor(wind/2)
        projectileTable.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,angle-60,0), caster:GetForwardVector()) * 600
        turnado_projectile = ProjectileManager:CreateLinearProjectile( projectileTable )
        if created_projectile <= math.floor(wind/2) then
            return 0.05
        end
    end)
    
end

function Turnado(keys,wind)
    local ability = keys.ability
    local caster = keys.caster

    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/units/heroes/hero_invoker/invoker_tornado.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = wind*250 + 300,
        fStartRadius = 150 + wind*20,
        fEndRadius = 150 + wind*20,
        fExpireTime = GameRules:GetGameTime() + 5,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * 1000,
        vAcceleration = caster:GetForwardVector() * 200
    }
    turnado_projectile = ProjectileManager:CreateLinearProjectile( projectileTable )
end

function wind_stream(keys,wind)
    local ability = keys.ability
    local caster = keys.caster

    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/units/heroes/hero_drow/drow_silence_wave.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = wind*200,
        fStartRadius = 200 + wind*20,
        fEndRadius = 200 + wind*20,
        fExpireTime = GameRules:GetGameTime() + 5,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * 1000,
        vAcceleration = caster:GetForwardVector() * 200
    }
    wind_stream_projectile = ProjectileManager:CreateLinearProjectile( projectileTable )
end

function ice_spike(keys,ice)
	local caster = keys.caster
	local ability_level = keys.ability:GetLevel() - 1
    local fv = keys.caster:GetForwardVector()
    local location = keys.caster:GetAbsOrigin() + fv*800
    local ice_explosion_effect = ParticleManager:CreateParticle("particles/crystal_spike_aoe_front.vpcf", PATTACH_ABSORIGIN  , keys.caster)
    ParticleManager:SetParticleControl(ice_explosion_effect, 0, location)
    ParticleManager:SetParticleControl(ice_explosion_effect, 1, location)
    ParticleManager:SetParticleControl(ice_explosion_effect, 2, location)
    ParticleManager:SetParticleControl(ice_explosion_effect, 3, location)
    Timers:CreateTimer(3,function()
                    ParticleManager:DestroyParticle(ice_explosion_effect, false)
                end)

    keys.caster:EmitSound("Hero_Crystal.CrystalNova")
    local radius = 100 + 25*ice
    local damage_AoE =  (keys.caster:GetLevel()^0.7)*ice^4*4 + (1000 * 2^ability_level)
    print("ice_spike", damage_AoE)
	local nearbyUnits = FindUnitsInRadius(keys.caster:GetTeam(),
                                  location,
                                  nil,
                                  radius,
                                  DOTA_UNIT_TARGET_TEAM_ENEMY,
                                  DOTA_UNIT_TARGET_ALL,
                                  DOTA_UNIT_TARGET_FLAG_NONE,
                                  FIND_ANY_ORDER,
                                  false)
    for _,unit in pairs(nearbyUnits) do
        if unit ~= keys.caster then
                local damageTableAoe = {victim = unit,
                            attacker = keys.caster,
                            damage = damage_AoE,
                            damage_type = DAMAGE_TYPE_MAGICAL,
							ability = keys.ability
                            }
                ApplyDamage(damageTableAoe)
                keys.ability:ApplyDataDrivenModifier(keys.caster, unit, "slow_modifier_display", {duration = 5})
                keys.ability:ApplyDataDrivenModifier(keys.caster, unit, "slow_modifier", {duration = 5})
                unit:SetModifierStackCount( "slow_modifier", keys.ability, math.floor(ice*(20) ) )
                local ice_freeze_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf", PATTACH_ABSORIGIN  , unit)
                ParticleManager:SetParticleControl(ice_freeze_effect, 0, unit:GetAbsOrigin())
                ParticleManager:SetParticleControl(ice_freeze_effect, 1, unit:GetAbsOrigin())
                Timers:CreateTimer((ice/5),function()
                    ParticleManager:DestroyParticle(ice_freeze_effect, false)
                end)
        end
    end
end

function frost_spike(keys,ice)
	local caster = keys.caster
	local ability_level = keys.ability:GetLevel() - 1
    local ice_explosion_effect = ParticleManager:CreateParticle("particles/crystal_spike_aoe_2.vpcf", PATTACH_ABSORIGIN  , keys.caster)
    ParticleManager:SetParticleControl(ice_explosion_effect, 0, keys.caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(ice_explosion_effect, 1, keys.caster:GetAbsOrigin())
    Timers:CreateTimer(3,function()
                    ParticleManager:DestroyParticle(ice_explosion_effect, false)
                end)

    keys.caster:EmitSound("Hero_Crystal.CrystalNova")
    local radius = 300 + 25*ice
    local damage_AoE = (keys.caster:GetLevel()^0.5)*ice^4*3 + (1000 * 2^ability_level)
    print("frost_spike", damage_AoE)
	local nearbyUnits = FindUnitsInRadius(keys.caster:GetTeam(),
                                  keys.caster:GetAbsOrigin(),
                                  nil,
                                  radius,
                                  DOTA_UNIT_TARGET_TEAM_ENEMY,
                                  DOTA_UNIT_TARGET_ALL,
                                  DOTA_UNIT_TARGET_FLAG_NONE,
                                  FIND_ANY_ORDER,
                                  false)
    for _,unit in pairs(nearbyUnits) do
        if unit ~= keys.caster then
                local damageTableAoe = {victim = unit,
                            attacker = keys.caster,
                            damage = damage_AoE,
                            damage_type = DAMAGE_TYPE_MAGICAL,
							ability = keys.ability
                            }
                ApplyDamage(damageTableAoe)
                keys.ability:ApplyDataDrivenModifier(keys.caster, unit, "slow_modifier_display", {duration = 5})
                keys.ability:ApplyDataDrivenModifier(keys.caster, unit, "slow_modifier", {duration = 5})
                unit:SetModifierStackCount( "slow_modifier", keys.ability, math.floor(ice*(20) ) )
                local ice_freeze_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf", PATTACH_ABSORIGIN  , unit)
                ParticleManager:SetParticleControl(ice_freeze_effect, 0, unit:GetAbsOrigin())
                ParticleManager:SetParticleControl(ice_freeze_effect, 1, unit:GetAbsOrigin())

                Timers:CreateTimer((ice/5),function()
                    ParticleManager:DestroyParticle(ice_freeze_effect, false)
                end)
        end
    end
end


function frost_kiss(keys,ice) -- 6 ICE
	local caster = keys.caster
	local ability_level = keys.ability:GetLevel() - 1
    local ice_explosion_effect = ParticleManager:CreateParticle("particles/crystal_spike_aoe.vpcf", PATTACH_ABSORIGIN  , keys.caster)
    ParticleManager:SetParticleControl(ice_explosion_effect, 0, keys.caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(ice_explosion_effect, 1, keys.caster:GetAbsOrigin())
    Timers:CreateTimer(3,function()
                    ParticleManager:DestroyParticle(ice_explosion_effect, false)
                end)

    keys.caster:EmitSound("Hero_Crystal.CrystalNova")
    local radius = 300 + 25*ice
    local damage_AoE = (keys.caster:GetLevel()^0.5)*ice^4*0.25 + (1000 * 2^ability_level)
    print("frost_kiss", damage_AoE)
	local nearbyUnits = FindUnitsInRadius(keys.caster:GetTeam(),
                                  keys.caster:GetAbsOrigin(),
                                  nil,
                                  radius,
                                  DOTA_UNIT_TARGET_TEAM_ENEMY,
                                  DOTA_UNIT_TARGET_ALL,
                                  DOTA_UNIT_TARGET_FLAG_NONE,
                                  FIND_ANY_ORDER,
                                  false)
    for _,unit in pairs(nearbyUnits) do
        if unit ~= keys.caster then
                local damageTableAoe = {victim = unit,
                            attacker = keys.caster,
                            damage = damage_AoE,
                            damage_type = DAMAGE_TYPE_MAGICAL,
							ability = keys.ability
                            }
                ApplyDamage(damageTableAoe)
                keys.ability:ApplyDataDrivenModifier(keys.caster, unit, "ice_freeze_display", {duration = (ice/5)})
                keys.ability:ApplyDataDrivenModifier(keys.caster, unit, "ice_freeze", {duration = (ice/5)})
                local ice_freeze_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf", PATTACH_ABSORIGIN  , unit)
                ParticleManager:SetParticleControl(ice_freeze_effect, 0, unit:GetAbsOrigin())
                ParticleManager:SetParticleControl(ice_freeze_effect, 1, unit:GetAbsOrigin())
                Timers:CreateTimer((ice/5),function()
                    ParticleManager:DestroyParticle(ice_freeze_effect, false)
                end)
        end
    end
end

function slow_modifier_caster_hit(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local ice = caster.invocation_power_ice
    ability:ApplyDataDrivenModifier(caster, target, "slow_modifier_display", {duration = 5})
    ability:ApplyDataDrivenModifier(caster, target, "slow_modifier", {duration = 5})
    target:SetModifierStackCount( "slow_modifier", ability, math.floor(ice*(20) ) )
end

function frosttouch( keys ) -- 1 ICE
    local caster = keys.caster
    local ability = keys.ability
    ability:ApplyDataDrivenModifier(caster, caster, "slow_modifier_caster", {duration = 40})
    local frost_bonus_effect = ParticleManager:CreateParticle("particles/alacrity_ice.vpcf", PATTACH_OVERHEAD_FOLLOW  , caster)
                ParticleManager:SetParticleControl(frost_bonus_effect, 0, caster:GetAbsOrigin())
                Timers:CreateTimer(40,function()
                    ParticleManager:DestroyParticle(frost_bonus_effect, false)
                end)
end

function speedaura( keys , wind) -- 1 WIND
    local caster = keys.caster
    local ability = keys.ability
    for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
        if unit:GetTeam() == keys.caster:GetTeam() then
            ability:ApplyDataDrivenModifier(caster, unit, "speed_aura_display", {duration = 40})
            ability:ApplyDataDrivenModifier(caster, unit, "speed_aura", {duration = 40})
            unit:SetModifierStackCount( "speed_aura", ability, math.floor(wind*(75+keys.caster:GetLevel() ) ) )
            local speed_bonus_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_alacrity_buff.vpcf", PATTACH_OVERHEAD_FOLLOW  , unit)
                ParticleManager:SetParticleControl(speed_bonus_effect, 0, unit:GetAbsOrigin())
                Timers:CreateTimer(40,function()
                    ParticleManager:DestroyParticle(speed_bonus_effect, false)
                end)
        end
    end
end

function poweraura( keys , fire) -- 1 FIRE
    local ability = keys.ability
    for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
        if unit:GetTeam() == keys.caster:GetTeam() then
            ability:ApplyDataDrivenModifier(keys.caster, unit, "power_aura_display", {duration = 40})
            ability:ApplyDataDrivenModifier(keys.caster, unit, "power_aura", {duration = 40})
            unit:SetModifierStackCount( "power_aura", ability, math.floor(fire*((keys.caster:GetLevel()/2)^1.3)*50) )
            local speed_bonus_effect = ParticleManager:CreateParticle("particles/alacrity_fire.vpcf", PATTACH_OVERHEAD_FOLLOW , unit)
                ParticleManager:SetParticleControl(speed_bonus_effect, 0,unit:GetAbsOrigin())
                Timers:CreateTimer(40,function()
                    ParticleManager:DestroyParticle(speed_bonus_effect, false)
                end)
        end
    end
end
function ShowPopup( data )
    if not data then return end

    local target = data.Target or nil
    if not target then error( "ShowNumber without target" ) end
    local number = tonumber( data.Number or nil )
    local pfx = data.Type or "miss"
    local player = data.Player or nil
    local color = data.Color or Vector( 255, 255, 255 )
    local duration = tonumber( data.Duration or 1 )
    local presymbol = tonumber( data.PreSymbol or nil )
    local postsymbol = tonumber( data.PostSymbol or nil )

    local path = "particles/msg_fx/msg_" .. pfx .. ".vpcf"
    local particle = ParticleManager:CreateParticle(path, PATTACH_OVERHEAD_FOLLOW, target)
    if player ~= nil then
        local particle = ParticleManager:CreateParticleForPlayer( path, PATTACH_OVERHEAD_FOLLOW, target, player)
    end

    local digits = 0
    if number ~= nil then digits = #tostring( number ) end
    if presymbol ~= nil then digits = digits + 1 end
    if postsymbol ~= nil then digits = digits + 1 end

    ParticleManager:SetParticleControl( particle, 1, Vector( presymbol, number, postsymbol ) )
    ParticleManager:SetParticleControl( particle, 2, Vector( duration, digits, 0 ) )
    ParticleManager:SetParticleControl( particle, 3, color )
end

function personal_heal( keys, fire, ice, wind) -- 1-2 ALL
	local caster = keys.caster
	local percent = (fire + ice + wind)*0.1
	local heal = math.floor(caster:GetMaxHealth()*percent)
	caster:SetHealth(caster:GetHealth() + heal)
                        ShowPopup( {
	                        Target = keys.caster,
	                        PreSymbol = 8,
	                        PostSymbol = 2,
	                        Color = Vector( 0, 255, 33 ),
	                        Duration = 0.5,
	                        Number = heal,
	                        pfx = "heal",
	                        Player = PlayerResource:GetPlayer( caster:GetPlayerID() )
                        } )
end
function global_heal( keys, fire, ice, wind) -- 3 ALL
	local caster = keys.caster
	local percent = (fire + ice + wind)*0.03
	print (percent)
	for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
		if unit:GetTeam() == caster:GetTeam() then
			local heal = math.floor(unit:GetMaxHealth()*percent)
            keys.ability:ApplyDataDrivenModifier(caster, unit, "health_regen_display", {duration = (fire + ice + wind)+3})
            keys.ability:ApplyDataDrivenModifier(caster, unit, "health_regen", {duration = (fire + ice + wind)+3})
            unit:SetModifierStackCount( "health_regen", keys.ability, math.floor(unit:GetMaxHealth()*(fire + ice + wind)*0.01) )
			unit:SetHealth(unit:GetHealth() + heal)
			 ShowPopup( {
	                        Target = keys.unit,
	                        PreSymbol = 8,
	                        PostSymbol = 2,
	                        Color = Vector( 0, 255, 33 ),
	                        Duration = 0.5,
	                        Number = heal,
	                        pfx = "heal",
	                        Player = PlayerResource:GetPlayer( unit:GetPlayerID() )
                        } )
		end
	end
end


function projectile_multiple_fire_spear( keys , fire) -- 3-4 FIRE
    local ability = keys.ability
    local caster = keys.caster

    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/fire_spear.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = 5000,
        fStartRadius = 50,
        fEndRadius = 50,
        fExpireTime = GameRules:GetGameTime() + 5,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * 600,
        vAcceleration = caster:GetForwardVector() * 200
    }
    local created_projectile = 0
    Timers:CreateTimer(0.05, function()
    	created_projectile = created_projectile + 1
    	angle = (created_projectile*90)/fire
        projectileTable.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,angle-60,0), caster:GetForwardVector()) * 600
        fire_spear_simple = ProjectileManager:CreateLinearProjectile( projectileTable )
        if created_projectile <= fire then
            return 0.05
        end
    end)
end

function projectile_fire_spear( keys ) -- 2 FIRE
    local ability = keys.ability
    local caster = keys.caster

    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/fire_spear.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = 5000,
        fStartRadius = 50,
        fEndRadius = 50,
        fExpireTime = GameRules:GetGameTime() + 5,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * 600,
        vAcceleration = caster:GetForwardVector() * 200
    }
    fire_spear_simple = ProjectileManager:CreateLinearProjectile(projectileTable)
    print (fire_spear_simple)
    caster.projectile_table[1] = fire_spear_simple
end

function projectile_iceshard1(keys , ice, wind, fire)
    local ability = keys.ability
    local caster = keys.caster
    local distance = 400*(ice+wind)/5 + 400
    local speed = 600 * (fire/5 + 1)
    local forward = caster:GetForwardVector()

    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/crystal_maiden_projectil_spawner_work.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = distance,
        fStartRadius = 100*wind,
        fEndRadius = 300*wind,
        fExpireTime = GameRules:GetGameTime() + 5,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = forward * 300,
    }
    main_projectile = ProjectileManager:CreateLinearProjectile(projectileTable)
end
function projectile_iceshard2(keys , ice, wind, fire)
    local ability = keys.ability
    local caster = keys.caster
    local projectile_count = math.floor((ice+wind)/2 )
    local number_of_source = math.ceil((ice+wind)/4 )
    local delay = 1.0
    local distance = 600*(ice+wind)/5
    local time_interval = 0.20
    local speed = 600 * (fire/5 + 1)
    local forward = caster:GetForwardVector()

    local casterPoint = caster:GetAbsOrigin()
    print (delay)
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/crystal_maiden_projectil_spawner_work.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = 900 + (delay * 300),
        fStartRadius = 150*wind,
        fEndRadius = 150*wind*2,
        fExpireTime = GameRules:GetGameTime() + 6,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = forward * 300,
    }
        main_projectile = ProjectileManager:CreateLinearProjectile(projectileTable)
        caster.projectile_table[1] = main_projectile
    local secondary_projectile = {
        Ability = ability,
        EffectName = "particles/ice_spear.vpcf",
        vSpawnOrigin = casterPoint + forward * 600,
        fDistance = distance,
        fStartRadius = 50,
        fEndRadius = 50,
        fExpireTime = GameRules:GetGameTime() + 10,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = true,
        vVelocity = forward * 600,
    }

    --Creates the projectiles in 360 degrees
    if number_of_source == 1 or number_of_source > 2 then
        Timers:CreateTimer(delay,function()
            local projectiles_created = 0
            for i=-180,180,(180/projectile_count) do
                i = i+180
                local time = projectiles_created * time_interval
                projectiles_created = projectiles_created + 1

                --EmitSoundOn("", caster) --Add a sound if you wish!
                Timers:CreateTimer(time, function()
                    secondary_projectile.vSpawnOrigin = casterPoint + (forward * 300 * time) + forward * 300* delay + forward * 75
                    secondary_projectile.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), forward) * speed
                    small_projectile = ProjectileManager:CreateLinearProjectile( secondary_projectile )
                end)
            end
        end)
    end
    if number_of_source >=2 then
        Timers:CreateTimer(delay,function()
            local projectiles_created = 0
            for i=-180,180,(180/projectile_count) do
                if number_of_source == 3 then
                    i = i - 30
                end
                i = i+90
                local time = projectiles_created * time_interval
                projectiles_created = projectiles_created + 1

                --EmitSoundOn("", caster) --Add a sound if you wish!
                Timers:CreateTimer(time, function()
                    secondary_projectile.vSpawnOrigin = casterPoint + (forward * 300 * time) + forward * 300 * delay + forward * 75
                    secondary_projectile.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), forward) * speed
                    small_projectile = ProjectileManager:CreateLinearProjectile( secondary_projectile )
                end)
            end
        end)
    end
    if number_of_source >=2 then
        Timers:CreateTimer(delay,function()
            local projectiles_created = 0
            for i=-180,180,(180/projectile_count) do
                i = i+270
                if number_of_source == 3 then
                    i = i + 30
                end
                local time = projectiles_created * time_interval
                projectiles_created = projectiles_created + 1

                --EmitSoundOn("", caster) --Add a sound if you wish!
                Timers:CreateTimer(time, function()
                    secondary_projectile.vSpawnOrigin = casterPoint + (forward * 300 * time) + forward * 300* delay + forward * 75
                    secondary_projectile.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), forward) * speed
                    small_projectile = ProjectileManager:CreateLinearProjectile( secondary_projectile )
                end)
            end
        end)
    end
    if number_of_source == 4 then
        Timers:CreateTimer(delay,function()
            local projectiles_created = 0
            for i=-180,180,(180/projectile_count) do
                local time = projectiles_created * time_interval
                projectiles_created = projectiles_created + 1

                --EmitSoundOn("", caster) --Add a sound if you wish!
                Timers:CreateTimer(time, function()
                    secondary_projectile.vSpawnOrigin = casterPoint + (forward * 300 * time) + forward * 300* delay + forward * 75
                    secondary_projectile.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), forward) * speed
                    small_projectile = ProjectileManager:CreateLinearProjectile( secondary_projectile )
                end)
            end
        end)
    end
end