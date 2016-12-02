--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 1 )
	if thisEntity:GetUnitName() == "npc_dota_boss27_h" then 
		thisEntity.suffix = "_h"
		thisEntity.extra = 1
	elseif thisEntity:GetUnitName() == "npc_dota_boss27_vh" then
		thisEntity.suffix = "_vh"
		thisEntity.extra = 2
	else
		thisEntity.suffix = ""
		thisEntity.extra = 0
	end
	thisEntity.summon1 = thisEntity:FindAbilityByName("boss_summon_beast"..thisEntity.suffix)
end


function AIThink()
	if not thisEntity:IsDominated() then
		if not thisEntity:IsChanneling() then
			if (AICore:SpecificAlliedUnitsAlive( thisEntity, "npc_dota_boss26"..thisEntity.suffix ) < (1 + thisEntity.extra) or AICore:SpecificAlliedUnitsAlive( thisEntity, "npc_dota_boss26_mini"..thisEntity.suffix ) < (3 + thisEntity.extra)) and thisEntity.summon1:IsFullyCastable() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.summon1:entindex()
				})
				return thisEntity.summon1:GetChannelTime()+0.1
			end
			AICore:AttackHighestPriority( thisEntity )
			return 0.25
		else return 0.5 end
	else return 0.25 end
end