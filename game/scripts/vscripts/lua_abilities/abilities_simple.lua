require( "libraries/Timers" )
require( "lua_abilities/Check_Aghanim" )
require("libraries/utility")


if abilities_simple == nil then
    abilities_simple = {} -- Creates an array to let us beable to index abilities_simple when creating new functions
    abilities_simple.__index = abilities_simple
end
 
function abilities_simple:new() -- Creates the new class
    o = o or {}
    setmetatable( o, abilities_simple )
    return o
end

function abilities_simple:start() -- Runs whenever the abilities_simple.lua is ran
end

function gold_rain(caster,total_gold,exp,gold_bag)
        if exp == nil then exp = 0 end
        if total_gold == nil then return end
        if gold_bag == nil then gold_bag = 1 end
        for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
            if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
                unit:AddExperience (exp,false,false)
            end
        end
        local PlayerNumber = PlayerResource:GetTeamPlayerCount() 
        local GoldMultiplier = (((PlayerNumber)+0.56)/1.8)*0.17
        local gold = (total_gold * GoldMultiplier) / (gold_bag)
        local bag_created = 0
        Timers:CreateTimer(0.1,function()
            local newItem = CreateItem( "item_bag_of_gold", nil, nil )
            newItem:SetPurchaseTime( 0 )
            newItem:SetCurrentCharges( gold )
            local drop = CreateItemOnPositionSync( caster:GetAbsOrigin(), newItem )
            local dropTarget = caster:GetAbsOrigin() + RandomVector( RandomFloat( 50, 350 ) )
            newItem:LaunchLoot( true, 300, 0.75, dropTarget )
            if bag_created <= gold_bag then
                return 0.25
            end 
        end)
end

--[[Author: Pizzalol
    Date: 26.02.2015.
    Purges positive buffs from the target]]
function DoomPurge( keys )
    local target = keys.target

    -- Purge
    local RemovePositiveBuffs = true
    local RemoveDebuffs = false
    local BuffsCreatedThisFrameOnly = false
    local RemoveStuns = false
    local RemoveExceptions = false
    target:Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)
end

--[[Author: Pizzalol
    Date: 26.02.2015.
    The deny check is run every frame, if the target is within deny range then apply the deniable state for the
    duration of 2 frames]]
function DoomDenyCheck( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1

    local deny_pct = ability:GetTalentSpecialValueFor("deniable_pct")
    local modifier = keys.modifier

    local target_hp = target:GetHealth()
    local target_max_hp = target:GetMaxHealth()
    local target_hp_pct = (target_hp / target_max_hp) * 100

    if target_hp_pct <= deny_pct then
        ability:ApplyDataDrivenModifier(caster, target, modifier, {duration = 0.06})
    end
end

function spawn_unit_arround( caster , unitname , radius , unit_number ,playerID,core)
    if radius == nil then radius = 400 end
    if core == nil then core = false end
    if unit_number == nil then unit_number = 1 end
	if caster:IsNull() or not caster:IsAlive() then return end
    for i = 0, unit_number-1 do
        PrecacheUnitByNameAsync( unitname, function() 
			local unit = CreateUnitByName( unitname ,caster:GetAbsOrigin() + RandomVector(RandomInt(radius,radius)), true, nil, nil, DOTA_TEAM_BADGUYS )
				if GetMapName() == "epic_boss_fight_boss_master" then
					Timers:CreateTimer(0.03,function()
						if playerID ~= nil and PlayerResource:IsValidPlayerID( playerID ) then
							unit:SetOwner(PlayerResource:GetSelectedHeroEntity(playerID))
							unit:SetControllableByPlayer(playerID,true)
						end
						if core == true then
							unit.Holdout_IsCore = true
						end
					end)
				end
				if string.match(unit:GetUnitName(), "npc_dota_boss35") and (GameRules.gameDifficulty < 3 or GetMapName() == "epic_boss_fight_hard") then
					unit:RemoveAbility("boss_hell_tempest")
				end
			end,
        nil)
    end
end

function evil_core_charge(keys)
    local caster = keys.caster
    local wait = 15
    
        Timers:CreateTimer(0.25,function()
            if caster.dead ~= true and caster ~= nil then
                if caster.Charge < caster:GetMaxMana() and caster.weakness then
                    caster.Charge = caster.Charge + caster:GetMaxMana()/(wait*5)
                    return 0.2
                elseif caster.Charge >= caster:GetMaxMana() then
                    evil_core_summon(keys)
                end
            end
        end)
    
end

function evil_core_summon(keys)
    local caster = keys.caster
	for _,unit in pairs ( Entities:FindAllByName( "npc_dota_creature")) do
		if unit:GetUnitName() == "npc_dota_boss36_guardian" then
			return nil
		end
	end
	caster.UnitSpawned = caster.UnitSpawned or 0
	caster.UnitSpawned = caster.UnitSpawned + 1
    caster.Charge = 0
    for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
        if PlayerResource:IsValidPlayer( nPlayerID ) and PlayerResource:GetTeam(nPlayerID) == DOTA_TEAM_BADGUYS then
            local boss_master_id = nPlayerID
        end
    end
	if caster.dead then return end
    local sfx=""
        if GetMapName() == "epic_boss_fight_impossible" then 
            sfx="_vh" 
        elseif GetMapName() == "epic_boss_fight_hard" and GameRules.gameDifficulty > 2 then
            sfx="_h"  
        end

    local number = 1

    if GameRules.gameDifficulty >= 4 then 
        number = 2
    end

    local health_percent = (caster:GetHealth()/caster:GetMaxHealth())*100
	
    if health_percent <= 10 then
        spawn_unit_arround( caster , "npc_dota_boss35"..sfx , 500 , number , boss_master_id )
        spawn_unit_arround( caster , "npc_dota_boss34"..sfx , 500 , 1 ,boss_master_id)
    elseif health_percent <= 20 then
        spawn_unit_arround( caster , "npc_dota_boss35"..sfx , 500 , 1 ,boss_master_id)
        spawn_unit_arround( caster , "npc_dota_boss33_a"..sfx , 500 , number ,boss_master_id)
        spawn_unit_arround( caster , "npc_dota_boss33_b"..sfx , 500 , number ,boss_master_id)
    elseif health_percent <= 30 then
        spawn_unit_arround( caster , "npc_dota_boss34"..sfx , 500 , 1 ,boss_master_id)
        spawn_unit_arround( caster , "npc_dota_boss32_trueform"..sfx , 500 , number ,boss_master_id)
    elseif health_percent <= 50 then
        spawn_unit_arround( caster , "npc_dota_boss33_a"..sfx , 500 , 1 ,boss_master_id)
        spawn_unit_arround( caster , "npc_dota_boss33_b"..sfx , 500 , 1 ,boss_master_id)
        spawn_unit_arround( caster , "npc_dota_boss31"..sfx , 500 , number ,boss_master_id)
    elseif health_percent <= 70 then
        spawn_unit_arround( caster , "npc_dota_boss31"..sfx , 500 , number ,boss_master_id)
        spawn_unit_arround( caster , "npc_dota_boss32_trueform"..sfx , 500 , number ,boss_master_id)
    elseif health_percent <= 90 then
        spawn_unit_arround( caster , "npc_dota_boss31"..sfx , 500 , number ,boss_master_id)
    else
        spawn_unit_arround( caster , "npc_dota_boss31"..sfx , 500 , 1 ,boss_master_id)
    end
end


function boss_evil_core_spawn(keys)
    local caster = keys.caster
    caster.Charge = 0
	caster.UnitSpawned = caster.UnitSpawned or 0
    caster.weakness = false
    Timers:CreateTimer(0.25,function()
            if not caster:IsNull() then
                caster:SetMana(caster.Charge)
                return 0.2
            end
    end)
    local origin = Vector(0,0,0)
    for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
        if PlayerResource:IsValidPlayer( nPlayerID ) and PlayerResource:GetTeam(nPlayerID) == DOTA_TEAM_BADGUYS then
            local boss_master_id = nPlayerID
        end
    end
    Timers:CreateTimer(0.03,function()
        caster:SetAbsOrigin(origin)
        local size = Vector(200,200,0)
        FindClearSpaceForUnit(caster, origin, true)
        caster.have_shield = true
        caster.shield_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_chronosphere.vpcf", PATTACH_ABSORIGIN  , keys.caster)
        ParticleManager:SetParticleControl(caster.shield_particle, 0, origin)
        ParticleManager:SetParticleControl(caster.shield_particle, 1, size)
        ParticleManager:SetParticleControl(caster.shield_particle, 6, origin)
        ParticleManager:SetParticleControl(caster.shield_particle, 10, origin)

        local sfx=""
        Timers:CreateTimer(0.06,function()
            caster:SetHealth(3500)
            if GetMapName() == "epic_boss_fight_impossible" and GameRules.gameDifficulty > 2 then 
                sfx="_vh" 
                caster:SetMaxHealth(5000)
                caster:SetHealth(5000)
            elseif ((GetMapName() == "epic_boss_fight_hard" or GetMapName() == "epic_boss_fight_boss_master") and GameRules.gameDifficulty < 2) or (GetMapName() == "epic_boss_fight_impossible" and GameRules.gameDifficulty < 2) then
                sfx="_h"  
                caster:SetMaxHealth(4250)
                caster:SetHealth(4250)
            end
        end)
        spawn_unit_arround( caster , "npc_dota_boss31"..sfx , 500 , 1 , boss_master_id )
        spawn_unit_arround( caster , "npc_dota_boss32_trueform"..sfx , 500 , 1 , boss_master_id )
        Timers:CreateTimer(0.25,function()
                if not caster:IsNull() and caster:IsAlive() then
                    local weakness = true
                    for _,unit in pairs ( Entities:FindAllByName( "npc_dota_creature")) do
                        if unit:GetUnitName() ~= "npc_dota_boss36" and unit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
                            weakness = false
                        end
                    end
                    if weakness == true then 
                        if caster.weakness == false then
                            caster.weakness = true
                            caster.have_shield = false
                            local messageinfo = {
                                message = "Evil core is now weak !",
                                duration = 2
                            }
                            FireGameEvent("show_center_message",messageinfo)  
                            ParticleManager:DestroyParticle( caster.shield_particle, true)
                            evil_core_charge(keys)
                        end
                    else
                        if caster.weakness == true then
                            caster.weakness = false
                            caster.have_shield = true
                            caster.shield_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_chronosphere.vpcf", PATTACH_ABSORIGIN  , keys.caster)
                                ParticleManager:SetParticleControl(caster.shield_particle, 0, origin)
                                ParticleManager:SetParticleControl(caster.shield_particle, 1, size)
                                ParticleManager:SetParticleControl(caster.shield_particle, 6, origin)
                                ParticleManager:SetParticleControl(caster.shield_particle, 10, origin)
                        end
                    end
                    return 0.25
                end  
        end)
    end)
end

function boss_hell_guardian_death(keys)
    gold_rain(caster,100000,2500000,25)
end

function boss_evil_core_take_damage(keys)
    local caster = keys.caster
    if caster:IsNull() then 
        return
    end
	local base = GameRules.BasePlayers
    caster.failed_attack = caster.failed_attack or 0
    if caster.weakness == true then
        local increasedDamage = math.floor((5+caster.UnitSpawned) * ((base + 1 - PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS))/base))
		caster:SetHealth( caster:GetHealth() - 5+caster.UnitSpawned - increasedDamage )
        caster.failed_attack = 0
    else
        caster.failed_attack = caster.failed_attack + 1
        if caster.failed_attack > 20 then
            caster.failed_attack = 0
            local messageinfo = {
            message = "The boss invulnerable, kill his summon!",
            duration = 2
            }
            FireGameEvent("show_center_message",messageinfo)  
        end
    end
end

function boss_evil_core_death(keys)
	keys.caster.dead = true
	local ticker = 1 -- fuck this gay earth
	Timers:CreateTimer(0.1,function()
            for _,unit in pairs ( Entities:FindAllByName( "npc_dota_creature")) do
				if unit:GetTeamNumber() == DOTA_TEAM_BADGUYS and unit:GetUnitName() ~= "npc_dota_boss36" and unit:GetUnitName() ~= "npc_dota_boss36_guardian" then
					unit:ForceKill(true)
				end
			end
			ticker = ticker - 0.1
			if ticker > 0 then
				return 0.1
			end
        end)
	local dummy = CreateUnitByName( "npc_dota_boss36_guardian" , keys.caster:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS )
	keys.ability:ApplyDataDrivenModifier(keys.caster, dummy, "modifier_spawn_timer", {duration = 5})
	for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
        if PlayerResource:IsValidPlayer( nPlayerID ) then
            local player = PlayerResource:GetPlayer(nPlayerID)
            if player ~= nil then
                local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
                if hero ~=nil then
                    if not hero:IsAlive() then
                        hero:RespawnUnit()
                    end
                    hero:SetHealth( hero:GetMaxHealth() )
                    hero:SetMana( hero:GetMaxMana() )
                end
            end
        end
    end
end


function projectile_cloud( keys )
    local ability = keys.ability
    local caster = keys.caster

    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/units/heroes/hero_shadow_demon/shadow_demon_shadow_poison_projectile.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = 1000,
        fStartRadius = 300,
        fEndRadius = 500,
        fExpireTime = GameRules:GetGameTime() + 5,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * 300,
    }
    projectile = ProjectileManager:CreateLinearProjectile(projectileTable)
end
function projectile_spear( keys )
    local ability = keys.ability
    local caster = keys.caster

    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/light_spear.vpcf",
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
    projectile = ProjectileManager:CreateLinearProjectile(projectileTable)
end

function projectile_lol_orbs( keys )
    local ability = keys.ability
    local caster = keys.caster
    local count = 0
    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
    local direction = caster:GetForwardVector()
    local projectileTable = {}
    Timers:CreateTimer(0.1,function()
        count = count +1
        if count <= 70 then
            projectileTable = {
                Ability = ability,
                EffectName = "particles/boss/boss_shadows_orb.vpcf",
                vSpawnOrigin = casterPoint,
                fDistance = 5000,
                fStartRadius = 80,
                fEndRadius = 80,
                fExpireTime = GameRules:GetGameTime() + 5,
                Source = caster,
                bHasFrontalCone = true,
                bReplaceExisting = false,
                bProvidesVision = false,
                iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
                iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                iUnitTargetType = DOTA_UNIT_TARGET_ALL,
                vVelocity = caster:GetForwardVector() * 500,
            }
            projectile = ProjectileManager:CreateLinearProjectile(projectileTable)
            return 0.08
        end
    end)
end

function ShadowrazePoint( event )
    local caster = event.caster
    local fv = caster:GetForwardVector()
    local origin = caster:GetAbsOrigin()
    local distance = event.distance
    
    local front_position = origin + fv * distance
    local result = {}
    table.insert(result, front_position)

    return result

end

function Shadowraze_effect( event )
    local caster = event.caster
    local fv = caster:GetForwardVector()
    local origin = caster:GetAbsOrigin()
    local distance = 900
    
    local front_position = origin + fv * distance

    local ability = keys.ability

    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf",
        vSpawnOrigin = front_position,
        fDistance = 5,
        fStartRadius = 250,
        fEndRadius = 250,
        fExpireTime = GameRules:GetGameTime() + 5,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * 0,
    }
    projectile = ProjectileManager:CreateLinearProjectile(projectileTable)
end


function boss_death_time( keys )
    local caster = keys.caster
    local origin = caster:GetAbsOrigin()
    local ability = keys.ability
    local timer = 6.0
    local Death_range = ability:GetTalentSpecialValueFor("radius")
    local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
    local targetType = DOTA_UNIT_TARGET_ALL
    local targetFlag = ability:GetAbilityTargetFlags()
    local check = false
    local blink_ability = caster:FindAbilityByName("boss_blink_on_far")
	local death_position = caster:GetAbsOrigin()
    local units = FindUnitsInRadius(
        caster:GetTeamNumber(), origin, caster, FIND_UNITS_EVERYWHERE, targetTeam, targetType, targetFlag, FIND_CLOSEST, false)
    for _,unit in pairs( units ) do
        local particle = ParticleManager:CreateParticle("particles/generic_aoe_persistent_circle_1/death_timer_glow_rev.vpcf",PATTACH_POINT_FOLLOW,unit)
        if GetMapName() == "epic_boss_fight_impossible" or GetMapName() == "epic_boss_fight_boss_master" then timer = 5.0 else timer = 6.0 end
        ability:ApplyDataDrivenModifier( caster, unit, "target_warning", {duration = timer} )
		blink_ability:StartCooldown(timer+1)
        Timers:CreateTimer(timer,function()
            local vDiff = unit:GetAbsOrigin() - death_position
			caster:RemoveModifierByName("caster_chrono_fx")
            if vDiff:Length2D() < Death_range and caster:IsAlive() then
				unit:RemoveModifierByName("modifier_tauntmail")
                unit.NoTombStone = true
                unit:KillTarget()
                Timers:CreateTimer(timer,function()
                    unit.NoTombStone = false
                end)
            end
        end)
        break
    end
end
function Chronosphere( keys )
    -- Variables
    local caster = keys.caster
    local ability = keys.ability

    -- Special Variables
    local duration = 5
    if GetMapName() == "epic_boss_fight_impossible" or GetMapName() == "epic_boss_fight_boss_master" then duration = 5.0 else duration = 6.0 end

    -- Dummy
    local dummy_modifier = keys.dummy_aura
    local dummy = CreateUnitByName("npc_dummy_unit", caster, false, caster, caster, caster:GetTeam())
    dummy:AddNewModifier(caster, nil, "modifier_phased", {})
    ability:ApplyDataDrivenModifier(caster, dummy, dummy_modifier, {duration = duration})


    -- Timer to remove the dummy
    Timers:CreateTimer(duration, function() dummy:RemoveSelf() end)
end


function boss_blink_on_far( keys )
    local caster = keys.caster
	local target = keys.target
    local origin = caster:GetAbsOrigin()
    local ability = keys.ability
	
    ProjectileManager:ProjectileDodge(keys.caster)  --Disjoints disjointable incoming projectiles.
    
    ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, keys.caster)
    keys.caster:EmitSound("DOTA_Item.BlinkDagger.Activate")
	FindClearSpaceForUnit(caster, target:GetAbsOrigin(), true)
end

--[[ 
     Author: Noya
     Date: 26 September 2015
     Creates projectiles in 360 degrees with a time interval between them
--]]
function projectile_dark_orbs( event )
    local caster = event.caster
    local ability = event.ability
    local origin = caster:GetAbsOrigin()
    local projectile_count = 80 --ability:GetTalentSpecialValueFor("projectile_count") -- If you want to make it more powerful with levels
    local speed = 700
    local time_interval = 0.05 -- Time between each launch

    local info = {
        EffectName =  "particles/boss/boss_shadows_orb.vpcf",
        Ability = ability,
        vSpawnOrigin = origin,
        fDistance = 1250,
        fStartRadius = 75,
        fEndRadius = 75,
        Source = caster,
        bHasFrontalCone = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        --fMaxSpeed = 5200,
        bReplaceExisting = false,
        bProvidesVision = false,
        fExpireTime = GameRules:GetGameTime() + 7,
        vVelocity = 0.0, --vVelocity = caster:GetForwardVector() * 1800,
        iMoveSpeed = speed,
    }

    origin.z = 0
    info.vVelocity = origin:Normalized() * speed

    --Creates the projectiles in 1440 degrees
    Timers:CreateTimer(1.0,function()
        local projectiles_created = 0
        for i=-720,720,(1440/projectile_count) do
            local time = projectiles_created * time_interval
            projectiles_created = projectiles_created + 1

            --EmitSoundOn("", caster) --Add a sound if you wish!
            Timers:CreateTimer(time, function()
                info.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), caster:GetForwardVector()) * speed
                projectile = ProjectileManager:CreateLinearProjectile( info )
            end)
        end
    end)
end

function projectile_death_orbs( event )
    local caster = event.caster
    local ability = event.ability
    local origin = caster:GetAbsOrigin()
    local projectile_count = 3 --ability:GetTalentSpecialValueFor("projectile_count") -- If you want to make it more powerful with levels
    local speed = 700
    local time_interval = 0.05 -- Time between each launch

    local info = {
        EffectName =  "particles/death_spear.vpcf",
        Ability = ability,
        vSpawnOrigin = origin,
        fDistance = 3000,
        fStartRadius = 75,
        fEndRadius = 75,
        Source = caster,
        bHasFrontalCone = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        --fMaxSpeed = 5200,
        bReplaceExisting = false,
        bProvidesVision = false,
        fExpireTime = GameRules:GetGameTime() + 7,
        vVelocity = 0.0, --vVelocity = caster:GetForwardVector() * 1800,
        iMoveSpeed = speed,
    }

    origin.z = 0
    info.vVelocity = origin:Normalized() * speed

    --Creates the projectiles in 1440 degrees
    local projectiles_launched = 0
    local projectiles_to_launch = 7
    Timers:CreateTimer(0.5,function()
        projectiles_launched = projectiles_launched + 1
        for angle=-90,90,(180/projectile_count) do
            for i=0,projectile_count,1 do
                angle = (projectiles_launched-1)*2 + angle
                info.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,angle,0), caster:GetForwardVector()) * speed
                projectile = ProjectileManager:CreateLinearProjectile( info )
            end
        end
        if projectiles_launched <= projectiles_to_launch then return 0.5 end
    end)
end
function projectile_death_orbs_hit( event )
    local target = event.target
	if not event.caster:IsAlive() then return end
    if target:GetHealth() <= target:GetMaxHealth()/4 then 
        target.NoTombStone = true
        target:KillTarget()
        Timers:CreateTimer(1.0,function()
            target.NoTombStone = false
        end)
    else 
        if (GetMapName() == "epic_boss_fight_impossible" or GetMapName() == "epic_boss_fight_boss_master" ) and GameRules.gameDifficulty > 1 then
            target:SetHealth(target:GetHealth()*0.2 + 1)
        elseif (GetMapName() == "epic_boss_fight_hard" and GameRules.gameDifficulty > 2) or (GetMapName() == "epic_boss_fight_impossible" and GameRules.gameDifficulty < 1) then
            target:SetHealth(target:GetHealth()*0.3 + 1)
        else 
            target:SetHealth(target:GetHealth()*0.5 + 1)
        end
    end  
end


function hell_tempest_hit( event )
    local target = event.target
    if target.InWater ~= true and event.caster:IsAlive() then
        if target:GetUnitName()~="npc_dota_courier" and target:GetUnitName()~="npc_dota_flying_courier" then
            target:KillTarget()
        end
    end
end

function hell_tempest_charge_damage( event )
    local caster = event.caster
    caster.charge = caster.charge + 1
    if caster.charge>=caster:GetMaxMana() then caster.charge = caster:GetMaxMana() end

end

function hell_tempest_charge( event )
    local caster = event.caster
    if caster.charge == nil then
        caster.charge = 0
        caster:SetMana(0) 
    elseif caster.charge < 0 then
        caster.charge = 0
    else
        return
    end
    
    Timers:CreateTimer(0.1,function() 
            if caster.charge < caster:GetMaxMana() then
                caster.charge = caster.charge + 0.25
                caster:SetMana(math.ceil(caster.charge)) 
                if GetMapName() == "epic_boss_fight_impossible" or GetMapName() == "epic_boss_fight_boss_master" then
                    return 0.03
                else
                    return 0.1
                end
            else
                caster:SetMana(math.ceil(caster.charge)) 
                return 0.03
            end
        end)

end

function createAOEDamage(keys,particlesname,location,size,damage,damage_type,duration,sound)
    if duration == nil then
        duration = 3
    end
    if damage == nil then
        damage = 5000
    end
    if size == nil then
        size = 250
    end
    if damage_type == nil then
        damage_type = DAMAGE_TYPE_MAGICAL
    end
    if sound ~= nil then
        StartSoundEventFromPosition(sound,location)
    end

    local AOE_effect = ParticleManager:CreateParticle(particlesname, PATTACH_ABSORIGIN  , keys.caster)
    ParticleManager:SetParticleControl(AOE_effect, 0, location)
    ParticleManager:SetParticleControl(AOE_effect, 1, location)
    Timers:CreateTimer(duration,function()
        ParticleManager:DestroyParticle(AOE_effect, false)
    end)

    local nearbyUnits = FindUnitsInRadius(keys.caster:GetTeam(),
                                  location,
                                  nil,
                                  size,
                                  DOTA_UNIT_TARGET_TEAM_ENEMY,
                                  DOTA_UNIT_TARGET_ALL,
                                  DOTA_UNIT_TARGET_FLAG_NONE,
                                  FIND_ANY_ORDER,
                                  false)

    for _,unit in pairs(nearbyUnits) do
        if unit ~= keys.caster then
                if unit:GetUnitName()~="npc_dota_courier" and unit:GetUnitName()~="npc_dota_flying_courier" then
                    local damageTableAoe = {victim = unit,
                                attacker = keys.caster,
                                damage = damage,
                                damage_type = damage_type,
                                ability = keys.ability,
                                }
                    ApplyDamage(damageTableAoe)
                end
        end
    end
end

LinkLuaModifier( "modifier_neutral_power_passive", "scripts/vscripts/lua_abilities/heroes/modifiers/modifier_neutral_power_passive.lua" ,LUA_MODIFIER_MOTION_NONE )

function CreepScaling(keys)
	Timers:CreateTimer(0.03,function() 
		local caster = keys.caster:GetOwnerEntity()
		local creep = keys.caster
		if not caster then caster = creep end
		local treant = caster:FindAbilityByName("furion_force_of_nature")
		if treant then
			creep:AddNewModifier(creep, keys.ability, "modifier_neutral_power_passive", {})
			local damage = creep:GetBaseDamageMin() + creep:GetBaseDamageMin()*caster:GetLevel()^0.4*treant:GetLevel()*GameRules._roundnumber^0.5
			if caster:HasTalent("special_bonus_unique_furion") then damage = damage * caster:FindTalentValue("special_bonus_unique_furion") end
			creep:SetBaseDamageMin(damage)
		else 
			local damage = creep:GetBaseDamageMin()*GameRules._roundnumber^0.5
			
			if caster:HasTalent("special_bonus_unique_venomancer") then damage = damage * caster:FindTalentValue("special_bonus_unique_venomancer") end
			creep:SetBaseDamageMin(damage) 
		end
		creep:SetBaseDamageMax(creep:GetBaseDamageMin())
		creep:SetHealth(creep:GetMaxHealth())
	end)
end

function doom_raze( event )
    local caster = event.caster
    local ability = event.ability
    local fv = caster:GetForwardVector()
    local rv = caster:GetRightVector()
    local location = caster:GetAbsOrigin() + fv*200
    caster.charge = caster.charge - 50
    if caster.charge < 0 then caster.Charge = 0 end
    local damage = ability:GetTalentSpecialValueFor("damage")
    location = location - caster:GetRightVector() * 1000
    if GameRules._NewGamePlus == true then damage = damage*10 end
    local created_line = 0
    Timers:CreateTimer(0.25,function() 
            created_line = created_line + 1
            for i=1,8,1 do
                createAOEDamage(event,"particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf",location,250,damage,DAMAGE_TYPE_PURE,2,"soundevents/game_sounds_heroes/game_sounds_nevermore.vsndevts")
                location = location + rv* 250
            end
            location = location - rv * 2000 + fv * 400
            if created_line <= 4 then
                return 1.0
            end
        end)
    
end


function hell_tempest_boss( keys )
    local ability = keys.ability
    local caster = keys.caster
    caster.charge = 0
    local casterPoint = caster:GetAbsOrigin()
    local delay = 0
	if GetMapName() == "epic_boss_fight_impossible" then
		delay = 5
	elseif GetMapName() == "epic_boss_fight_hard" and GameRules.gameDifficulty < 3 then
		delay = 6
	else
		delay = 7
	end
    local messageinfo = {
    message = "The boss is casting Hell Tempest , reach the water !",
    duration = 2
    }
    if caster.warning == nil then messageinfo.duration = 5 caster.warning = true end
    FireGameEvent("show_center_message",messageinfo)  

    -- Spawn projectile
    Timers:CreateTimer(delay, function()
        local projectileTable = {
            Ability = ability,
            EffectName = "particles/fire_tornado.vpcf",
            vSpawnOrigin = casterPoint - caster:GetForwardVector()*4000,
            fDistance = 5000,
            fStartRadius = 1500,
            fEndRadius = 1500,
            fExpireTime = GameRules:GetGameTime() + 10,
            Source = caster,
            bHasFrontalCone = true,
            bReplaceExisting = false,
            bProvidesVision = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            iUnitTargetType = DOTA_UNIT_TARGET_ALL,
            bDeleteOnHit = false,
            vVelocity = caster:GetRightVector() * 1000,
            vAcceleration = caster:GetForwardVector() * 200
        }
        local created_projectile = 0
        Timers:CreateTimer(0.05, function()
            created_projectile = created_projectile + 1
            projectileTable.vSpawnOrigin = projectileTable.vSpawnOrigin + caster:GetForwardVector()*(8000/30)
            projectileTable.vVelocity = caster:GetRightVector() * 1000
            fire_tornado_projectile = ProjectileManager:CreateLinearProjectile( projectileTable )
            if created_projectile <= 15 then
                return 0.05
            end
        end)
        local created_projectile_bis = 0
        Timers:CreateTimer(0.05, function()
            created_projectile_bis = created_projectile_bis + 1
            projectileTable.vSpawnOrigin = projectileTable.vSpawnOrigin + caster:GetForwardVector()*(8000/30)
            projectileTable.vVelocity = caster:GetRightVector() * -1000
            fire_tornado_projectile = ProjectileManager:CreateLinearProjectile( projectileTable )
            if created_projectile_bis <= 15 then
                return 0.05
            end
        end)
    end)
end






function doom_bringer_boss( event )
    local target = event.target
    local caster = event.caster
    local time = GameRules:GetGameTime()
	event.ability:ApplyDataDrivenModifier(caster, target, "fuckingdoomed", {duration = 10})
    if GetMapName() == "epic_boss_fight_impossible" or GetMapName() == "epic_boss_fight_boss_master" then
        Timers:CreateTimer(0.1,function() 
            if target:GetHealth() > target:GetMaxHealth()*0.10 + 0.0125*GameRules.gameDifficulty and GameRules:GetGameTime() <= time + 10 then
                target:SetHealth(target:GetHealth()*(0.95 - 0.025*GameRules.gameDifficulty))
                return 0.5
            else
                if GameRules:GetGameTime() <= time + 10 and caster:IsAlive() then
                    target:KillTarget()
                end
            end
        end)
    elseif GetMapName() == "epic_boss_fight_hard" then
        Timers:CreateTimer(0.1,function() 
            if target:GetHealth() > target:GetMaxHealth()*0.05  + 0.0125*GameRules.gameDifficulty and GameRules:GetGameTime() <= time + 10 then
                target:SetHealth(target:GetHealth()*(0.98 - 0.01*GameRules.gameDifficulty))
                return 0.5
            else
                if GameRules:GetGameTime() <= time + 10 then
                    target:KillTarget()
                end
            end
        end)
    else
        Timers:CreateTimer(0.1,function() 
            if target:GetHealth() > target:GetMaxHealth()*0.01 and GameRules:GetGameTime() <= time + 10 then
                target:SetHealth(target:GetHealth()*(0.95))
                return 0.5
            else
                if GameRules:GetGameTime() <= time + 10 then
                    target:KillTarget()
                end
            end
        end)
    end
end


function storm_projectile_hit( event )
    local target = event.target
    if target.InWater ~= false and caster:IsAlive() then
        target:KillTarget()
    end
end

function Give_Control( keys )
    local target = keys.target
	if target:GetUnitName() == "npc_dota_boss36" then return end
    local caster = keys.caster
    target:Purge(true,true,false,false,false)
    local PlayerID = caster:GetPlayerOwnerID()
    target:SetTeam(caster:GetTeamNumber())
    target:SetControllableByPlayer( PlayerID, false)
end

function Give_ControlBM( keys )
    local target = keys.target
	if target:GetUnitName() == "npc_dota_boss36" then return end
    local caster = keys.caster
    local PlayerID = caster:GetPlayerID()
    target:SetTeam(caster:GetTeamNumber())
    target:SetControllableByPlayer( PlayerID, false)
	target:SetOwner(caster)
	print(PlayerID, caster:GetTeamNumber())
end

function End_Control( keys )
    local target = keys.target
    local caster = keys.caster
    local level = keys.ability:GetTalentSpecialValueFor( "agh_level" )
	if target:IsNull() or not target then return end
    target:SetTeam(DOTA_TEAM_BADGUYS)
    target:SetControllableByPlayer(-1, false)
	target:SetControllableByPlayer(GameRules.boss_master_id, false)
    local hp_percent = keys.ability:GetTalentSpecialValueFor( "hp_regen" ) * 0.01
    local regen_health = target:GetMaxHealth()*hp_percent
    if caster:HasScepter() then
        if target:GetLevel() <= level then
                target:ForceKill(true)
        else
            regen_health = 0
        end
    end
    target:SetHealth(target:GetHealth()+regen_health)
    if target:GetHealth() > target:GetMaxHealth() then 
        target:SetHealth(target:GetMaxHealth())
    end
end


function spawn_unit( keys )
    local caster = keys.caster
    local unit = keys.unit_to_spawn
	local ability
	local abilityname = {}
	if caster.elite then
		local ability
		local i = 1
		for k,v in pairs(GameRules._Elites)	do -- make splintered units elites
			if not ability then
				ability = caster:FindAbilityByName(k)
				if ability then
					abilityname[i] = k
					i = i + 1
				end
			end
		end
	end
    if keys.number_of_unit==nil then keys.number_of_unit=1 end
    for i = 1, keys.number_of_unit do
        local entUnit = CreateUnitByName( unit ,caster:GetAbsOrigin() + RandomVector(RandomInt(250,500)), true, nil, nil, DOTA_TEAM_BADGUYS )
		if entUnit then
			if #abilityname > 0 and RollPercentage(100/i) then
				entUnit.elite = true
				entUnit.eliteAb = abilityname
			end
		end
    end
end

--[[
    Author: kritth
    Date: 7.1.2015.
    Fire missiles if there are targets, else play dud

    edited by frenchdeath to going with epic boss fight change
]]
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

    local no_refresh_item = {["item_sheepstick_2"] = true,
							 ["item_ressurection_stone"] = true,
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
							   ["item_Dagon_Mystic"] = true,
							   ["item_asura_staff"] = true,
							   ["item_asura_wand"] = true}
	
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


function NecroAura(keys)
	if keys.caster:IsIllusion() then return end
	local ability = keys.ability
	local target = keys.target
	local reduction = ability:GetTalentSpecialValueFor("magical_ress_red")
	local entry_modifier = keys.entry_modifier
	local new_armor_target =  0
	new_armor_target =  math.floor(target:GetBaseMagicalResistanceValue() + reduction*entry_modifier)
	target:SetBaseMagicalResistanceValue(new_armor_target)
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
    
    -- pick up x nearest target heroes and create tracking projectile targeting the number of targets
    
end

function Cooldown_Pure(keys)
    local ability = keys.ability
    local level = ability:GetLevel()-1
    local duration = ability:GetTalentSpecialValueFor("cooldown_duration")
    ability:StartCooldown(duration)
end

function KillTarget(keys)
    local target = keys.target
    if target:GetUnitName() ~= "npc_dota_boss36" then
        target:ForceKill(true)
    else 
        target:SetHealth(60)
    end
end

function KillCaster(keys)
    local caster = keys.caster
    caster:ForceKill(true)
end

function RageFunction(keys)
    local modifierName = "rage"
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local current_stack = target:GetModifierStackCount( modifierName, ability )
    local damagebase = ability:GetTalentSpecialValueFor("bonus_damage_per_stack")
    local damage = damagebase*current_stack
    local damageTable = {victim = target,
                        attacker = caster,
                        damage = damage,
                        ability = keys.ability,
                        damage_type = DAMAGE_TYPE_PHYSICAL,
                        }
    ApplyDamage(damageTable)

    if target:HasModifier( modifierName ) then
        ability:ApplyDataDrivenModifier( caster, target, modifierName, {duration = 30} )
        target:SetModifierStackCount( modifierName, ability, current_stack + 1 )
    else
        ability:ApplyDataDrivenModifier( caster, target, modifierName, {duration = 30})
        target:SetModifierStackCount( modifierName, ability, 1)
    end
end

function pudgeHP_shiftOnAttack(keys)
	if keys.caster:IsIllusion() then return end
		local previous_stack_count = 0
		local threat = keys.ability:GetTalentSpecialValueFor("health_bonus_perstack") / 100
		if keys.target:HasModifier("modifier_hp_shift_datadriven_debuff_counter") then
			previous_stack_count = keys.target:GetModifierStackCount("modifier_hp_shift_datadriven_debuff_counter", keys.caster)
			
			--We have to remove and replace the modifier so the duration will refresh.
			keys.target:RemoveModifierByNameAndCaster("modifier_hp_shift_datadriven_debuff_counter", keys.caster)
		end
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_hp_shift_datadriven_debuff_counter", nil)
		keys.target:SetModifierStackCount("modifier_hp_shift_datadriven_debuff_counter", keys.caster, previous_stack_count + 1)		
		
		--Apply a debuff
		if keys.target:GetUnitName() ~= "npc_dota_boss36" then
			local curr_max = keys.target:GetMaxHealth()
			local curr_curr		= keys.target:GetHealth()
			local reduction = keys.ability:GetTalentSpecialValueFor( "health_bonus_perstack")
			keys.target:SetHealth(curr_curr - reduction)
			keys.target:SetMaxHealth(curr_max - reduction)
		end
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_hp_shift_datadriven_debuff", nil)
		
		--update visible counter modifier's stack count and duration
		previous_stack_count = 0
		if keys.caster:HasModifier("modifier_hp_shift_datadriven_buff_counter") then
			previous_stack_count = keys.caster:GetModifierStackCount("modifier_hp_shift_datadriven_buff_counter", keys.caster)
			
			--We have to remove and replace the modifier so the duration will refresh (so it will show the duration of the latest).
			keys.caster:RemoveModifierByNameAndCaster("modifier_hp_shift_datadriven_buff_counter", keys.caster)
		end
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_hp_shift_datadriven_buff_counter", nil)
		keys.caster:SetModifierStackCount("modifier_hp_shift_datadriven_buff_counter", keys.caster, previous_stack_count + 1)
		
		--Apply buff
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_hp_shift_datadriven_buff", nil)
end


--[[ ============================================================================================================
	Called whenever a Flesh Heap debuff on an opponent expires.  Decrements their debuff counter by one.
================================================================================================================= ]]
function pudgeHP_shiftDebuffOnDestroy(keys)
	if keys.target:HasModifier("modifier_hp_shift_datadriven_debuff_counter") then
		local previous_stack_count = keys.target:GetModifierStackCount("modifier_hp_shift_datadriven_debuff_counter", keys.caster)
		if previous_stack_count > 1 then
			keys.target:SetModifierStackCount("modifier_hp_shift_datadriven_debuff_counter", keys.caster, previous_stack_count - 1)
			
		else
			keys.target:RemoveModifierByNameAndCaster("modifier_hp_shift_datadriven_debuff_counter", keys.caster)
		end
	end
	local curr_max = keys.target:GetMaxHealth()
	local reduction = keys.ability:GetTalentSpecialValueFor( "health_bonus_perstack")
	keys.target:SetMaxHealth(curr_max + reduction)
end


--[[ ============================================================================================================
	Called whenever a Flesh Heap buff on Pudge expires.  Decrements his buff counter by one.
================================================================================================================= ]]
function pudgeHP_shiftBuffOnDestroy(keys)
	if keys.caster:HasModifier("modifier_hp_shift_datadriven_buff_counter") then
		local previous_stack_count = keys.caster:GetModifierStackCount("modifier_hp_shift_datadriven_buff_counter", keys.caster)
		if previous_stack_count > 1 then
			keys.caster:SetModifierStackCount("modifier_hp_shift_datadriven_buff_counter", keys.caster, previous_stack_count - 1)
		else
			keys.caster:RemoveModifierByNameAndCaster("modifier_hp_shift_datadriven_buff_counter", keys.caster)
		end
	end
end

function boss_invoke_golem_destroy_skill(keys)
    local caster = keys.caster
    local ability = keys.ability
    caster:RemoveAbility(ability:GetName())
end

function golem_clean(keys)
    for _,unit in pairs ( Entities:FindAllByName( "npc_dota_boss31")) do
        unit:ForceKill(true)
    end
end

--[[Kill wolves on resummon
    Author: Noya
    Date: 20.01.2015.]]

function KillWolves( event )
    local caster = event.caster
    local targets = caster.wolves or {}
    for _,unit in pairs(targets) do 
        if unit and IsValidEntity(unit) then
            unit:ForceKill(true)
            end
        end
    -- Reset table
    caster.wolves = {}
end

--[[
    Author: Noya
    Date: 20.01.2015.
    Gets the summoning forward direction for the new units
]]

function GetSummonPoints( event )

    local caster = event.caster
    local fv = caster:GetForwardVector()
    local origin = caster:GetAbsOrigin()
    local distance = event.distance
-- Gets 2 points facing a distance away from the caster origin and separated from each other at 30 degrees left and right
    ang_right = QAngle(0, -30)
    ang_left = QAngle(0, 30)
local front_position = origin + fv * distance
    point_left = RotatePosition(origin, ang_left, front_position)
    point_right = RotatePosition(origin, ang_right, front_position)
local result = { }
    table.insert(result, point_right)
    table.insert(result, point_left)
return result
end

-- Set the units looking at the same point of the caster
function SetUnitsMoveForward( event )
    local caster = event.caster
    local target = event.target
    local fv = caster:GetForwardVector()
    local origin = caster:GetAbsOrigin()
target:SetForwardVector(fv)
-- Add the target to a table on the caster handle, to find them later
table.insert(caster.wolves, target)
end


--[[
    Author: kritth
    Date: 10.01.2015.
    Init the table
]]
function spiked_carapace_init( keys )
    keys.caster.carapaced_units = {}
end

--[[
    Author: kritth
    Date: 10.01.2015.
    Reflect damage
]]
function spiked_carapace_reflect( keys )
    -- Variables
    local caster = keys.caster
    local attacker = keys.attacker
    local damageTaken = keys.DamageTaken
    local ability = keys.ability
    local damage_multiplier = ability:GetTalentSpecialValueFor( "damage_multplier") * 0.01
	local damage = damageTaken*damage_multiplier
	if damage > attacker:GetMaxHealth() * 0.8 then damage = attacker:GetMaxHealth() * 0.8 end -- no oneshotting, tears-b-gone
	if (attacker:GetName() == "npc_dota_hero_centaur" and not attacker:IsAttacking()) or attacker:IsMagicImmune() then return end
    -- Check if it's not already been hit
    local damageTable = {
                            victim = attacker,
                            attacker = caster,
                            damage = damage,
                            ability = keys.ability,
                            damage_type = DAMAGE_TYPE_PURE
                        }
     if not caster.carapaced_units[ attacker:entindex() ] then
      keys.ability:ApplyDataDrivenModifier( caster, attacker, "modifier_spiked_carapaced_stun_datadriven", { } )
      caster.carapaced_units[ attacker:entindex() ] = attacker
      ApplyDamage(damageTable)
    end

end

-- Stops the sound from playing
function StopSound( keys )
    local target = keys.target
    local sound = keys.sound

    StopSoundEvent(sound, target)
end

function givegemtruesight(keys)
	local caster = keys.caster
	caster:AddNewModifier(caster, nil, "modifier_truesight", {})
end