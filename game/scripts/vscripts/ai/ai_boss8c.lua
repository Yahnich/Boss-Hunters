--[[
Broodking AI
]]
TECHIES_BEHAVIOR_SEEK_AND_DESTROY = 1
TECHIES_BEHAVIOR_ROAM_AND_MINE = 2
require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 1 )
	thisEntity.suicide = thisEntity:FindAbilityByName("boss_suicide")
	thisEntity.mine = thisEntity:FindAbilityByName("boss_proximity")
	thisEntity.behavior = RandomInt(1,2)
end


function AIThink()
	if not thisEntity:IsDominated() then
		if thisEntity:IsChanneling() then return 0.25 end
		local boom = AICore:NearestEnemyHeroInRange( thisEntity, 500, true )
		if boom then 
			if thisEntity.suicide:IsFullyCastable() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = boom:GetOrigin(),
					AbilityIndex = thisEntity.suicide:entindex()
				})
				return 0.25
			end
		end
		if thisEntity.mine:IsFullyCastable() and not AICore:SpecificAlliedUnitsInRange( thisEntity, "npc_dota_techies_land_mine", 450 ) then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				Position = thisEntity:GetOrigin(),
				AbilityIndex = thisEntity.mine:entindex()
			})
			return 0.25
		end
		if thisEntity.behavior == TECHIES_BEHAVIOR_SEEK_AND_DESTROY then
			AICore:RunToTarget( thisEntity, AICore:NearestEnemyHeroInRange( thisEntity, 9999, true ) )
		elseif thisEntity.behavior == TECHIES_BEHAVIOR_ROAM_AND_MINE then
			AICore:RunToRandomPosition( thisEntity, 50 )
		end
		return 0.25
	else return 0.25 end
end