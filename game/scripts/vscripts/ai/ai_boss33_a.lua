--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 1 )
	if thisEntity:GetUnitName() == "npc_dota_boss33_a_h" then 
		thisEntity.suffix = "_h"
	elseif thisEntity:GetUnitName() == "npc_dota_boss33_a_vh" then
		thisEntity.suffix = "_vh"
	else
		thisEntity.suffix = ""
	end
	thisEntity.cloud = thisEntity:FindAbilityByName("boss_demoniac_cloud"..thisEntity.suffix)
	thisEntity.orb = thisEntity:FindAbilityByName("boss_shadows_orb"..thisEntity.suffix)
end


function AIThink()
	if not thisEntity:IsDominated() then
		local radius = thisEntity.orb:GetCastRange()/2
		if AICore:TotalEnemyHeroesInRange( thisEntity, radius ) >= 1 and thisEntity.orb:IsFullyCastable() then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				Position = thisEntity:GetOrigin(),
				AbilityIndex = thisEntity.orb:entindex()
			})
			return 0.25
		end
		if thisEntity.cloud:IsFullyCastable() then
			local target = AICore:WeakestEnemyHeroInRange( thisEntity, thisEntity.cloud:GetCastRange(), false )
			if target then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = target:GetOrigin(),
					AbilityIndex = thisEntity.cloud:entindex()
				})
				return 0.25
			end
		end
		AICore:AttackHighestPriority( thisEntity )
		return 0.25
	else
		return 0.25
	end
end