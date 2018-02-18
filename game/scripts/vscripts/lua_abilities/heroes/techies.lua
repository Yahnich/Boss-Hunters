--[[Author: Pizzalol
    Date: 24.03.2015.
    Creates the land mine and keeps track of it]]
function LandMinesPlant( keys )
    local caster = keys.caster
    local target_point = keys.target_points[1]
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1

    -- Initialize the count and table
    caster.land_mine_count = caster.land_mine_count or 0
    caster.land_mine_table = caster.land_mine_table or {}

    -- Modifiers
    local modifier_land_mine = keys.modifier_land_mine
    local modifier_tracker = keys.modifier_tracker
    local modifier_caster = keys.modifier_caster
    local modifier_land_mine_invisibility = keys.modifier_land_mine_invisibility

    -- Ability variables
    local activation_time = ability:GetTalentSpecialValueFor("activation_time") 
    local max_mines = ability:GetTalentSpecialValueFor("max_mines") 
    local fade_time = ability:GetTalentSpecialValueFor("fade_time")
	local model_scale = ability:GetTalentSpecialValueFor("model_scale") / 100

    -- Create the land mine and apply the land mine modifier
    local land_mine = CreateUnitByName("npc_dota_techies_remote_mine", target_point, false, nil, nil, caster:GetTeamNumber())
	if caster:HasTalent("special_bonus_unique_techies_4") then land_mine:SetBaseMoveSpeed( caster:FindTalentValue("special_bonus_unique_techies_4") ) end
    ability:ApplyDataDrivenModifier(caster, land_mine, modifier_land_mine, {})
	land_mine:SetModelScale(1.7 + model_scale)

    -- Update the count and table
    caster.land_mine_count = caster.land_mine_count + 1
    table.insert(caster.land_mine_table, land_mine)

    -- If we exceeded the maximum number of mines then kill the oldest one
    if caster.land_mine_count > max_mines then
        caster.land_mine_table[1]:ForceKill(true)
    end

    -- Increase caster stack count of the caster modifier and add it to the caster if it doesnt exist
    if not caster:HasModifier(modifier_caster) then
        ability:ApplyDataDrivenModifier(caster, caster, modifier_caster, {})
    end

    caster:SetModifierStackCount(modifier_caster, ability, caster.land_mine_count)

    -- Apply the tracker after the activation time
    Timers:CreateTimer(activation_time, function()
        ability:ApplyDataDrivenModifier(caster, land_mine, modifier_tracker, {})
    end)

    -- Apply the invisibility after the fade time
    Timers:CreateTimer(fade_time, function()
        ability:ApplyDataDrivenModifier(caster, land_mine, modifier_land_mine_invisibility, {})
    end)
end

function LandMinesDamage( keys )
	local caster = keys.caster
	local unit = keys.unit
	local target = keys.target
	local ability = keys.ability
	ApplyDamage({ victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType(), ability = ability })
	local distance = ability:GetTalentSpecialValueFor("knockback_max_distance") - (target:GetAbsOrigin() - unit:GetAbsOrigin()):Length2D()
	ApplyKnockback({duration = ability:GetTalentSpecialValueFor("knockback_duration"), distance = distance, caster = unit, target = target, height = 250, modifier = "modifier_land_mine_knockback", ability = ability})
end

--[[Author: Pizzalol
    Date: 24.03.2015.
    Stop tracking the mine and create vision on the mine area]]
function LandMinesDeath( keys )
    local caster = keys.caster
	local target = keys.target
    local unit = keys.unit
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1

    -- Ability variables
    local modifier_caster = keys.modifier_caster
    local vision_radius = ability:GetTalentSpecialValueFor("vision_radius") 
    local vision_duration = ability:GetTalentSpecialValueFor("vision_duration")
			
    -- Find the mine and remove it from the table
    for i = 1, #caster.land_mine_table do
        if caster.land_mine_table[i] == unit then
            table.remove(caster.land_mine_table, i)
            caster.land_mine_count = caster.land_mine_count - 1
            break
        end
    end
	
			-- Dummy Unit to attach FX
	local dummyModifierName = "modifier_land_mine_dummy_vfx_datadriven"
	local dummy = CreateUnitByName( "npc_dummy_unit", unit:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber() )
    ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {} )
	Timers:CreateTimer(5, function()
			dummy:Destroy()
			return nil
			end
		)
		
    -- Create vision on the mine position
    ability:CreateVisibilityNode(unit:GetAbsOrigin(), vision_radius, vision_duration)

    -- Update the stack count
    caster:SetModifierStackCount(modifier_caster, ability, caster.land_mine_count)
    if caster.land_mine_count < 1 then
        caster:RemoveModifierByNameAndCaster(modifier_caster, caster) 
    end
end

--[[Author: Pizzalol
    Date: 24.03.2015.
    Tracks if any enemy units are within the mine radius]]
function LandMinesTracker( keys )
    local target = keys.target
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1

    -- Ability variables
    local trigger_radius = ability:GetTalentSpecialValueFor("radius") 
    local explode_delay = ability:GetTalentSpecialValueFor("explode_delay") 

    -- Target variables
    local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
    local target_types = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING
    local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES

    -- Find the valid units in the trigger radius
    local units = FindUnitsInRadius(target:GetTeamNumber(), target:GetAbsOrigin(), nil, trigger_radius, target_team, target_types, target_flags, FIND_CLOSEST, false) 

    -- If there is a valid unit in range then explode the mine
    if #units > 0 then
        Timers:CreateTimer(explode_delay, function()
            if target:IsAlive() then
                target:ForceKill(true) 
            end
        end)
    end
end

function OnDeath( keys )
	local unit = keys.unit
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local minesToDrop = ability:GetTalentSpecialValueFor("mines_dropped")
	local level = caster:FindAbilityByName("techies_land_mines"):GetLevel()
	local dummyModifierName = "modifier_death_dummy"
	local dummy = CreateUnitByName( "npc_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber() )
    ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {} )
	
	local mine = dummy:AddAbility("techies_land_mines")
	mine:SetLevel(level)
	for i = 1, minesToDrop do
		dummy:SetCursorPosition( caster:GetAbsOrigin() + RandomVector(150))
		mine:OnSpellStart()
	end
	Timers:CreateTimer(ability:GetTalentSpecialValueFor("mines_duration"), function()
			for _,mine in pairs ( Entities:FindAllByName( "npc_dota_techies_mines")) do
				if mine:GetUnitName() == "npc_dota_techies_land_mine" and mine:GetOwnerEntity() == dummy then
					mine:RemoveSelf()
				end
			end
			dummy:Destroy()
			return nil
			end
		)
end


function NukePerDamage( keys )	
		local caster = keys.caster
		local unit = keys.unit
		local target = keys.target
		local ability = keys.ability
		
		local maxhpdamage = ability:GetTalentSpecialValueFor("max_health_damage") * target:GetMaxHealth()
		local maxhpdamage2 = maxhpdamage / 100
		local truedamage = maxhpdamage2 / caster:GetSpellDamageAmp()
		ApplyDamage({ victim = target, attacker = caster, damage = truedamage, damage_type = ability:GetAbilityDamageType(), ability = ability })
end

function NukeDoTDamage( keys )	
		local caster = keys.caster
		local unit = keys.unit
		local target = keys.target
		local ability = keys.ability
		
		local maxhpdamage = ability:GetTalentSpecialValueFor("nuke_dot_damage") * target:GetMaxHealth()
		local maxhpdamage2 = maxhpdamage / 100
		local truedamage = maxhpdamage2 / caster:GetSpellDamageAmp()
		ApplyDamage({ victim = target, attacker = caster, damage = truedamage, damage_type = ability:GetAbilityDamageType(), ability = ability })
end

function NukeInitialDamage( keys )
	local caster = keys.caster
	local unit = keys.unit
	local target = keys.target
	local ability = keys.ability
		ApplyDamage({ victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType(), ability = ability })
end

function NukeDummy( keys )
	local unit = keys.unit
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability
	local dummyModifierName = "modifier_nuke_dummy_vfx_datadriven"
	local dummy = CreateUnitByName( "npc_dummy_unit", target, false, caster, caster, caster:GetTeamNumber() )
    ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {} )
	Timers:CreateTimer(ability:GetTalentSpecialValueFor("nuke_fallout_duration"), function()
			dummy:Destroy()
			return nil
			end
		)
end