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

function spawn_unit_arround( caster , unitname , radius , unit_number ,playerID,core)
    if radius == nil then radius = 400 end
    if core == nil then core = false end
    if unit_number == nil then unit_number = 1 end
    if caster:IsNull() or not caster:IsAlive() then return end
    for i = 0, unit_number-1 do
        PrecacheUnitByNameAsync( unitname, function()
            local unit = CreateUnitByName( unitname ,caster:GetAbsOrigin() + RandomVector(RandomInt(radius,radius)), true, nil, nil, caster:GetTeam() )
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
            end,
        nil)
    end
end

function boss_hell_guardian_death(keys)
    gold_rain(caster,100000,2500000,25)
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
        if GameRules.gameDifficulty > 2 then timer = 5.0 else timer = 6.0 end
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
        fStartRadius = 50,
        fEndRadius = 50,
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
        if GameRules.gameDifficulty <= 2 then
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
                if GameRules.gameDifficulty > 2 then
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
            local damage = creep:GetBaseDamageMin() + 2*creep:GetBaseDamageMin()*caster:GetLevel()/80
            
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
    if GameRules.gameDifficulty > 2 then
        delay = 5
    elseif GameRules.gameDifficulty <= 2 then
        delay = 6
    else
        delay = 7
    end
    local messageinfo = {
    message = "The boss is casting Hell Tempest, get in the water!",
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
            fStartRadius = 100,
            fEndRadius = 100,
            fExpireTime = GameRules:GetGameTime() + 10,
            Source = caster,
            bHasFrontalCone = true,
            bReplaceExisting = false,
            bProvidesVision = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO,
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
    Timers:CreateTimer(0.1,function() 
        if target:GetHealth() > target:GetMaxHealth() * 0.025 * GameRules.gameDifficulty and GameRules:GetGameTime() <= time + 10 then
            target:SetHealth( math.max(1, target:GetHealth()*(1 - 0.0075*GameRules.gameDifficulty)) )
            return 0.5
        else
            if GameRules:GetGameTime() <= time + 10 and caster:IsAlive() then
                target:KillTarget()
            end
        end
    end)
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
        for k,v in pairs(GameRules._Elites) do -- make splintered units elites
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
        if caster:GetOwnerEntity() and caster:GetOwnerEntity().IsRealHero and caster:GetOwnerEntity():IsRealHero() then
            caster:GetOwnerEntity():CreateSummon(unit, caster:GetAbsOrigin() + RandomVector(RandomInt(250,500)), 30)
        else
            local entUnit = CreateUnitByName( unit, caster:GetAbsOrigin() + RandomVector(RandomInt(250,500)), true, nil, nil, caster:GetTeamNumber() )
        end
        if entUnit then
            if #abilityname > 0 and RollPercentage(100/i) then
                entUnit.elite = true
                entUnit.eliteAb = abilityname
            end
        end
    end
end

function KillTarget(keys)
    local target = keys.target
    if not keys.caster:IsAlive() then return end
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
            local curr_curr     = keys.target:GetHealth()
            local reduction = keys.ability:GetTalentSpecialValueFor( "health_bonus_perstack")
            keys.target:SetHealth(curr_curr - reduction)
            keys.target:SetMaxHealth(curr_max - reduction)
            keys.target:SetBaseMaxHealth(curr_max - reduction)
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
    keys.target:SetBaseMaxHealth(curr_max + reduction)
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

function StopSound( keys )
    local target = keys.target
    local sound = keys.sound

    StopSoundEvent(sound, target)
end

function givegemtruesight(keys)
    local caster = keys.caster
    caster:AddNewModifier(caster, nil, "modifier_truesight", {})
end