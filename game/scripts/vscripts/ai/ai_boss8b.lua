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
	thisEntity.rockets = thisEntity:FindAbilityByName("boss_rockets")
	thisEntity.march = thisEntity:FindAbilityByName("boss_march")
	thisEntity.rearm = thisEntity:FindAbilityByName("boss_rearm")
	if  math.floor(GameRules.gameDifficulty + 0.5) > 3 then
		thisEntity.rockets:SetLevel(4)
		thisEntity.march:SetLevel(4)
		thisEntity.rearm:SetLevel(4)
	elseif  math.floor(GameRules.gameDifficulty + 0.5) == 3 then
		thisEntity.rockets:SetLevel(3)
		thisEntity.march:SetLevel(3)
		thisEntity.rearm:SetLevel(3)
	elseif  math.floor(GameRules.gameDifficulty + 0.5) == 2 then
		thisEntity.rockets:SetLevel(2)
		thisEntity.march:SetLevel(2)
		thisEntity.rearm:SetLevel(2)
	else
		thisEntity.rockets:SetLevel(1)
		thisEntity.march:SetLevel(1)
		thisEntity.rearm:SetLevel(1)
	end
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		if thisEntity:IsChanneling() then return AI_THINK_RATE end
		local danger = AICore:NearestEnemyHeroInRange( thisEntity, 900, true )
		if danger then 
			if thisEntity.march:IsFullyCastable() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = thisEntity:GetOrigin(),
					AbilityIndex = thisEntity.march:entindex()
				})
				return AI_THINK_RATE
			elseif thisEntity.rearm:IsCooldownReady() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.rearm:entindex()
				})
				return thisEntity.rearm:GetCastPoint() + 0.1
			elseif RollPercentage(50) then
				AICore:BeAHugeCoward ( thisEntity, 900 )
				return AI_THINK_RATE
			elseif thisEntity.rockets:IsFullyCastable() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.rockets:entindex()
				})
				return AI_THINK_RATE
			else
				AICore:RunToRandomPosition( thisEntity, 10 )
				return AI_THINK_RATE
			end
		else
			if thisEntity.rockets:IsFullyCastable() and AICore:NearestEnemyHeroInRange( thisEntity, 2500, false ) then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.rockets:entindex()
				})
				return AI_THINK_RATE
			elseif not thisEntity.rockets:IsCooldownReady() and thisEntity.rearm:IsCooldownReady() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.rearm:entindex()
				})
				return thisEntity.rearm:GetCastPoint() + 0.1
			else
				AICore:RunToRandomPosition( thisEntity, 10 )
				return AI_THINK_RATE
			end
		end
		return AI_THINK_RATE
	else return AI_THINK_RATE end
end