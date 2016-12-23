--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 1 )
	thisEntity.rockets = thisEntity:FindAbilityByName("boss_rockets")
	thisEntity.march = thisEntity:FindAbilityByName("boss_march")
	thisEntity.rearm = thisEntity:FindAbilityByName("boss_rearm")
end


function AIThink()
	if not thisEntity:IsDominated() then
		if thisEntity:IsChanneling() then return 0.25 end
		local danger = AICore:NearestEnemyHeroInRange( thisEntity, 900, true )
		if danger then 
			if thisEntity.march:IsFullyCastable() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = thisEntity:GetOrigin(),
					AbilityIndex = thisEntity.march:entindex()
				})
				return 0.25
			else
				AICore:BeAHugeCoward( thisEntity, 900 )
				return 0.25
			end
		else
			if thisEntity.rockets:IsFullyCastable() and AICore:NearestEnemyHeroInRange( thisEntity, 2500, false ) then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.rockets:entindex()
				})
				return 0.25
			elseif not thisEntity.rockets:IsCooldownReady() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.rearm:entindex()
				})
				return thisEntity.rearm:GetChannelTime() + 0.1
			else
				AICore:RunToRandomPosition( thisEntity, 10 )
				return 0.25
			end
		end
		return 0.25
	else return 0.25 end
end