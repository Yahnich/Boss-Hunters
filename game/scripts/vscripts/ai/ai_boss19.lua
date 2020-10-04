if IsClient() then return end

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.summon = thisEntity:FindAbilityByName("boss_furion_summon_minor_treants")
	thisEntity.summon2 = thisEntity:FindAbilityByName("boss_furion_summon_greater_treants")
	thisEntity.sprout = thisEntity:FindAbilityByName("boss_furion_sprout")
	local level = RoundManager:GetCurrentRaidTier() + math.floor(GameRules:GetGameDifficulty()/2)
	
	AITimers:CreateTimer(0.1, function() 
		thisEntity.summon:SetLevel( level )
		thisEntity.summon2:SetLevel( level )
		thisEntity.sprout:SetLevel( level )
	end)
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		if not thisEntity:IsChanneling() then
			if thisEntity.summon and thisEntity.summon:IsFullyCastable() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.summon:entindex()
				})
				return thisEntity.summon:GetCastPoint()
			end
			if thisEntity.summon2 and thisEntity.summon2:IsFullyCastable() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.summon2:entindex()
				})
				return thisEntity.summon:GetCastPoint()
			end
			if thisEntity.sprout and thisEntity.sprout:IsFullyCastable() then
				radius = thisEntity:GetAttackRange()+thisEntity:GetAttackRangeBuffer()
				target = AICore:HighestThreatHeroInRange(thisEntity, radius, 0, true)
				if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity, radius, true) end
				if target and target:GetHealth() < target:GetMaxHealth()*0.4 then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = target:GetOrigin(),
						AbilityIndex = thisEntity.sprout:entindex()
					})
					return thisEntity.sprout:GetCastPoint()
				end
			end
			return AICore:AttackHighestPriority( thisEntity )
		else return AI_THINK_RATE end
	else return AI_THINK_RATE end
end