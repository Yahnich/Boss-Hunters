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