--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	Timers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	if thisEntity:GetUnitName() == "npc_dota_boss35_h" then 
		thisEntity.suffix = "_h"
	elseif thisEntity:GetUnitName() == "npc_dota_boss35_vh" then
		thisEntity.suffix = "_vh"
	else
		thisEntity.suffix = ""
	end
	thisEntity.doom = thisEntity:FindAbilityByName("boss_doom_bring")
	thisEntity.raze = thisEntity:FindAbilityByName("boss_doomraze"..thisEntity.suffix)
	thisEntity.tempest = thisEntity:FindAbilityByName("boss_hell_tempest")
	thisEntity.isCoreSpawn = IsEvilCorePresent(thisEntity)
end

function IsEvilCorePresent(thisEntity)
	local enemies = thisEntity:FindFriendlyUnitsInRadius( thisEntity:GetAbsOrigin(), -1 )
	print(#enemies)
	for _, enemy in ipairs ( enemies ) do
		print( enemy:GetUnitName() )
		if enemy:GetUnitName() == "npc_dota_boss36" then
			return true
		end
	end
	return false
end

function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		if thisEntity.raze:IsFullyCastable() then
			local width = 300
			local range = 1000
			local target = AICore:FarthestEnemyHeroInRange( thisEntity, range, false )
			if target and AICore:EnemiesInLine(thisEntity, range, width, false)  then
				local distance = (target:GetOrigin() - thisEntity:GetOrigin()):Length2D()
				if distance < range then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.raze:entindex()
					})
					return 1.25
				end
			end
		end
		if thisEntity.doom:IsFullyCastable() then
			local target = AICore:HighestThreatHeroInRange(thisEntity, thisEntity.doom:GetCastRange(), 10, true)
			if not target then target = AICore:StrongestEnemyHeroInRange( thisEntity, thisEntity.doom:GetCastRange(), true ) end
			if target then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
					TargetIndex = target:entindex(),
					AbilityIndex = thisEntity.doom:entindex()
				})
				return 1
			end
		end
		if not thisEntity.isCoreSpawn and AICore:TotalEnemyHeroesInRange( thisEntity, 1000 ) >= 1 and thisEntity.tempest:IsFullyCastable() then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.tempest:entindex()
			})
			return 2
		else
			AICore:AttackHighestPriority( thisEntity )
			return 0.25
		end
		return 0.25
	else
		return 0.25
	end
end