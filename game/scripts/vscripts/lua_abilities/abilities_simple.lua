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

function spawn_unit( keys )
    local caster = keys.caster
    local unit = keys.unit_to_spawn
    local ability
    local abilityname = {}
    if keys.number_of_unit==nil then keys.number_of_unit=1 end
    for i = 1, keys.number_of_unit do
        if caster:GetOwnerEntity() and caster:GetOwnerEntity().IsRealHero and caster:GetOwnerEntity():IsRealHero() then
            caster:GetOwnerEntity():CreateSummon(unit, caster:GetAbsOrigin() + RandomVector(RandomInt(250,500)), 30)
        else
            local entUnit = CreateUnitByName( unit, caster:GetAbsOrigin() + RandomVector(RandomInt(250,500)), true, nil, nil, caster:GetTeamNumber() )
			entUnit.unitIsRoundBoss = true
        end
    end
end

function KillTarget(keys)
    local target = keys.target
    if not keys.caster:IsAlive() then return end
    if target:GetUnitName() ~= "npc_dota_boss36" then
        target:AttemptKill(keys.ability, keys.caster)
    else 
        target:SetHealth(60)
    end
end

function KillCaster(keys)
    local caster = keys.caster
    caster:AttemptKill(keys.ability, caster)
end