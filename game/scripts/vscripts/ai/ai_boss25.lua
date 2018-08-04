--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	if thisEntity:GetUnitName() == "npc_dota_boss25_h" then 
		thisEntity.suffix = "_h"
		thisEntity.extra = 1
	elseif thisEntity:GetUnitName() == "npc_dota_boss25_vh" then
		thisEntity.suffix = "_vh"
		thisEntity.extra = 2
	else
		thisEntity.suffix = ""
		thisEntity.extra = 0
	end
	thisEntity.summon1 = thisEntity:FindAbilityByName("boss_summon_skeleton_smash"..thisEntity.suffix)
	thisEntity.summon2 = thisEntity:FindAbilityByName("boss_summon_skeleton_archer"..thisEntity.suffix)
	thisEntity.summon3 = thisEntity:FindAbilityByName("boss_summon_skeleton_minion"..thisEntity.suffix)
	thisEntity.smash = thisEntity:FindAbilityByName("creature_melee_smash2"..thisEntity.suffix)
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		if not thisEntity:IsChanneling() then
			local radius = thisEntity.smash:GetCastRange()
			if AICore:TotalNotDisabledEnemyHeroesInRange( thisEntity, radius, true ) <= AICore:TotalEnemyHeroesInRange( thisEntity, radius ) 
			and AICore:TotalEnemyHeroesInRange( thisEntity, radius ) ~= 0 
			and thisEntity.smash:IsFullyCastable() then
				local smashRadius = thisEntity.smash:GetSpecialValueFor("impact_radius")
				local position = AICore:OptimalHitPosition(thisEntity, radius, smashRadius)
				if position then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = position,
						AbilityIndex = thisEntity.smash:entindex()
					})
					return AI_THINK_RATE
				end
			end
			if AICore:SpecificAlliedUnitsAlive( thisEntity, "npc_dota_boss24_stomper"..thisEntity.suffix ) < (2 + thisEntity.extra) and thisEntity.summon1:IsFullyCastable() then
				ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.summon1:entindex()
					})
				return thisEntity.summon1:GetChannelTime()+0.1
			end
			if AICore:SpecificAlliedUnitsAlive( thisEntity, "npc_dota_boss24_archer"..thisEntity.suffix ) < (3 + thisEntity.extra) and thisEntity.summon2:IsFullyCastable() then
				ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.summon2:entindex()
					})
				return thisEntity.summon2:GetChannelTime()+0.1
			end
			if AICore:SpecificAlliedUnitsAlive( thisEntity, "npc_dota_boss24_minion"..thisEntity.suffix ) < (15 + (thisEntity.extra*5)) and thisEntity.summon3:IsFullyCastable() then
				ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.summon3:entindex()
					})
				return thisEntity.summon3:GetChannelTime()+0.1
			end
			return AICore:AttackHighestPriority( thisEntity )
		else return 0.5 end
	else return AI_THINK_RATE end
end