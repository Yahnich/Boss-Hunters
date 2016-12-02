--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 1 )
	if thisEntity:GetUnitName() == "npc_dota_boss32_trueform_h" then 
		thisEntity.suffix = "_h"
	elseif thisEntity:GetUnitName() == "npc_dota_boss32_trueform_vh" then
		thisEntity.suffix = "_vh"
	else
		thisEntity.suffix = ""
	end
	thisEntity.fire = thisEntity:FindAbilityByName("boss_melee_fire_orb"..thisEntity.suffix)
	thisEntity.meteor = thisEntity:FindAbilityByName("boss_meteor")
end


function AIThink()
	if not thisEntity:IsDominated() then
		local radius = thisEntity.fire:GetCastRange()/2
		if AICore:TotalEnemyHeroesInRange( thisEntity, radius ) >= 1 and thisEntity.fire:IsFullyCastable() then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				Position = thisEntity:GetOrigin(),
				AbilityIndex = thisEntity.fire:entindex()
			})
			return 0.25
		end
		if thisEntity.meteor:IsFullyCastable() then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				Position = thisEntity:GetOrigin(),
				AbilityIndex = thisEntity.meteor:entindex()
			})
			return 0.25
		end
		AICore:AttackHighestPriority( thisEntity )
		return 0.25
	else
		return 0.25
	end
end