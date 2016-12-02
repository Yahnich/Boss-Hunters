--[[ ============================================================================================================
    Author: Rook
    Date: April 06, 2015
    Called when Chaos Meteor is cast.
    Additional parameters: keys.LandTime, keys.TravelSpeed, keys.VisionDistance, keys.EndVisionDuration, and
        keys.BurnDuration

    modified by FrenchDeath to the actual stage for Boss usage
================================================================================================================= ]]
if boss_meteor == nil then
    print ( '[boss_meteor] creating boss_meteor' )
    boss_meteor = {} -- Creates an array to let us beable to index boss_meteor when creating new functions
    boss_meteor.__index = boss_meteor
    boss_meteor.midas_gold_on_round = 0
    boss_meteor._round = 1
end

function boss_meteor:SetRoundNumer(round)
    boss_meteor._round = round
    print (boss_meteor._round)
end

function meteor_on_spell_start(keys)
    local caster_point = keys.caster:GetAbsOrigin()
    local target_point = keys.target_points[1]
    local caster = keys.caster
    
    local caster_point_temp = Vector(caster_point.x, caster_point.y, 0)
    local target_point_temp = Vector(target_point.x, target_point.y, 0)
    
    local point_difference_normalized = (target_point_temp - caster_point_temp):Normalized()
    local velocity_per_second = point_difference_normalized * keys.TravelSpeed
    

    --Create a particle effect consisting of the meteor falling from the sky and landing at the target point.
    local meteor_fly_original_point = (target_point - (velocity_per_second * keys.LandTime)) + Vector (0, 0, 500)  --Start the meteor in the air in a place where it'll be moving the same speed when flying and when rolling.
    local chaos_meteor_fly_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf", PATTACH_ABSORIGIN, keys.caster)
    ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 0, meteor_fly_original_point)
    ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 1, target_point)
    ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 2, Vector(1.3, 0, 0))
    
    --Chaos Meteor's travel distance is dependent on the level of Wex.  This value is stored now since leveling up Wex while the meteor is in midair should have no effect.
    local travel_distance = keys.ability:GetLevelSpecialValueFor("travel_distance", 0)
    
    --Spawn the rolling meteor after the delay.
    Timers:CreateTimer({
        endTime = keys.LandTime,
        callback = function()
            --Create a dummy unit will follow the path of the meteor, providing flying vision, sound, damage, etc.          
            local chaos_meteor_dummy_unit = CreateUnitByName("npc_dummy_blank", target_point, false, nil, nil, keys.caster:GetTeam())
            chaos_meteor_dummy_unit:AddAbility("boss_meteor")
            local chaos_meteor_unit_ability = chaos_meteor_dummy_unit:FindAbilityByName("boss_meteor")
            if chaos_meteor_unit_ability ~= nil then
                chaos_meteor_unit_ability:SetLevel(1)
                chaos_meteor_unit_ability:ApplyDataDrivenModifier(chaos_meteor_dummy_unit, chaos_meteor_dummy_unit, "meteor_property", {duration = -1})
            end

            local fire_aura_duration = 5
            if GetMapName() == "epic_boss_fight_impossible" or GetMapName() == "epic_boss_fight_challenger" or GetMapName() == "epic_boss_fight_hard" then
                fire_aura_duration = 7
            end
            for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
                if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
                    unit:SetHealth(unit:GetHealth()/2)
                    if unit:GetHealth()<=0 then unit:ForceKill(true) end
                    keys.ability:ApplyDataDrivenModifier(caster, unit, "fire_aura_debuff", {duration = fire_aura_duration})
                end
            end
            
            --Store the damage to deal in a variable attached to the dummy unit, so leveling Exort after Meteor is cast will have no effect.
            chaos_meteor_dummy_unit.invoker_chaos_meteor_parent_caster = keys.caster
        
            local chaos_meteor_duration = 0.1
            
            --It would seem that the Chaos Meteor projectile needs to be attached to a particle in order to move and roll and such.
            local projectile_information =  
            {
                EffectName = "particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf",
                Ability = chaos_meteor_unit_ability,
                vSpawnOrigin = target_point,
                fDistance = travel_distance,
                fStartRadius = 0,
                fEndRadius = 0,
                Source = chaos_meteor_dummy_unit,
                bHasFrontalCone = false,
                iMoveSpeed = keys.TravelSpeed,
                bReplaceExisting = false,
                bProvidesVision = true,
                iVisionTeamNumber = keys.caster:GetTeam(),
                iVisionRadius = keys.VisionDistance,
                bDrawsOnMinimap = false,
                bVisibleToEnemies = true, 
                iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
                iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
                iUnitTargetType = DOTA_UNIT_TARGET_NONE ,
                fExpireTime = GameRules:GetGameTime() + chaos_meteor_duration,
            }
            local endTime = GameRules:GetGameTime() + chaos_meteor_duration
            Timers:CreateTimer({
                callback = function()
                    if GameRules:GetGameTime() > endTime then
                    
                        --Have the dummy unit linger in the position the meteor ended up in, in order to provide vision.
                        Timers:CreateTimer({
                            endTime = keys.EndVisionDuration,
                            callback = function()
                                chaos_meteor_dummy_unit:SetDayTimeVisionRange(0)
                                chaos_meteor_dummy_unit:SetNightTimeVisionRange(0)
                                chaos_meteor_dummy_unit:ForceKill(true)
                                --Remove the dummy unit after the burn damage modifiers are guaranteed to have all expired.

                            end
                        })
                        return 
                    else 
                        return .03
                    end
                end
            })
        end
    })
end

function money_and_exp_gain(keys)
    if boss_meteor._round < 35 then
        if keys.caster:GetUnitName() == "npc_dota_boss32_trueform" or keys.caster:GetUnitName() == "npc_dota_boss32_trueform_h" or keys.caster:GetUnitName() == "npc_dota_boss32_trueform_vh" then
            for _,unit in pairs ( Entities:FindAllByName( "npc_dummy_blank")) do
                if unit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
                    unit:ForceKill(true)
                end
            end
            local caster = keys.caster
            for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
                if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
                    if GetMapName() == "epic_boss_fight_impossible" or GetMapName() == "epic_boss_fight_challenger" then
                        unit:AddExperience (200000,false,false)
                        if GameRules._NewGamePlus == true then
                            unit:AddExperience (2500000,false,false)
                        end
                    else
                        unit:AddExperience (400000,false,false)
                        if GameRules._NewGamePlus == true then
                            unit:AddExperience (5000000,false,false)
                        end
                    end
                end
            end

            local gold = 0
            local PlayerNumber = PlayerResource:GetTeamPlayerCount() 
            local GoldMultiplier = (((PlayerNumber)+0.56)/1.8)*0.17
            if GetMapName() == "epic_boss_fight_impossible" or GetMapName() == "epic_boss_fight_challenger" then
                gold = 4000 * GoldMultiplier
            else
                gold = 8000 * GoldMultiplier
            end
            for i=0,10,1 do
                local newItem = CreateItem( "item_bag_of_gold", nil, nil )
                newItem:SetPurchaseTime( 0 )
                newItem:SetCurrentCharges( gold )
                local drop = CreateItemOnPositionSync( caster:GetAbsOrigin(), newItem )
                local dropTarget = caster:GetAbsOrigin() + RandomVector( RandomFloat( 50, 350 ) )
                newItem:LaunchLoot( true, 300, 0.75, dropTarget )
            end
        end
    end
end