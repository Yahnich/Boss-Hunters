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
	thisEntity.fire = thisEntity:FindAbilityByName("creature_fire_breath")
	thisEntity.crush = thisEntity:FindAbilityByName("creature_slithereen_crush")
	AITimers:CreateTimer(0.1, function()
		if  math.floor(GameRules.gameDifficulty + 0.5) <= 2 then
			thisEntity.fire:SetLevel(1)
			thisEntity.crush:SetLevel(1)
		else
			thisEntity.fire:SetLevel(2)
			thisEntity.crush:SetLevel(2)
		end
	end)
	thisEntity.idle = GameRules:GetGameTime()
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		if not thisEntity:IsChanneling() then
			local radius = thisEntity.crush:GetSpecialValueFor("crush_radius")
			if thisEntity.crush then
				if AICore:TotalNotDisabledEnemyHeroesInRange( thisEntity, radius, false ) >= math.floor(AICore:TotalEnemyHeroesInRange( thisEntity, radius )/2) 
				and AICore:TotalEnemyHeroesInRange( thisEntity, radius ) ~= 0
				and thisEntity.crush:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.crush:entindex()
					})
					return AI_THINK_RATE
				end
			end
			if thisEntity.fire:IsFullyCastable() then
				target = AICore:NearestDisabledEnemyHeroInRange( thisEntity, thisEntity.fire:GetCastRange(), false )
				if target then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = target:GetOrigin(),
						AbilityIndex = thisEntity.fire:entindex()
					})
					thisEntity.idle = GameRules:GetGameTime()
					return thisEntity.fire:GetChannelTime()
				end
			end
			-- FORCE CAST AFTER SET DURATION --
			if thisEntity.idle + 10 < GameRules:GetGameTime() and thisEntity.fire:IsFullyCastable() then
				target = AICore:HighestThreatHeroInRange(thisEntity, 99999, 0, true)
				if target then
					ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
							Position = target:GetOrigin(),
							AbilityIndex = thisEntity.fire:entindex()
					})
					thisEntity.idle = GameRules:GetGameTime()
					return thisEntity.fire:GetChannelTime()
				end
			end
			AICore:AttackHighestPriority( thisEntity )
			return AI_THINK_RATE
		else
			return 0.5
		end
	else return AI_THINK_RATE end
end