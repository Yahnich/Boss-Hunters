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
	if thisEntity:GetUnitName() == "npc_dota_boss31_h" then 
		thisEntity.suffix = "_h"
	elseif thisEntity:GetUnitName() == "npc_dota_boss31_vh" then
		thisEntity.suffix = "_vh"
	else
		thisEntity.suffix = ""
	end
	thisEntity.fire = thisEntity:FindAbilityByName("boss_melee_fire_orb"..thisEntity.suffix)
end


function AIThink(thisEntity)
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
		AICore:AttackHighestPriority( thisEntity )
		return 0.25
	else
		return 0.25
	end
end