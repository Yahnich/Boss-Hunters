--[[
Broodking AI
]]

require( "ai/ai_core" )
if IsServer() then
	function Spawn( entityKeyValues )
		AITimers:CreateTimer(function()
			if thisEntity and not thisEntity:IsNull() then
				return AIThink(thisEntity)
			end
		end)
		thisEntity.berserk = thisEntity:FindAbilityByName("boss3a_berserk")
		thisEntity.tombstone = thisEntity:FindAbilityByName("boss3a_tombstone")
		AITimers:CreateTimer(0.1, function()
			if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
				thisEntity.berserk:SetLevel(1)
				thisEntity.tombstone:SetLevel(1)
			else
				thisEntity.berserk:SetLevel(2)
				thisEntity.tombstone:SetLevel(2)
			end
		end)
	end


	function AIThink(thisEntity)
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
			local radius = thisEntity:GetAttackRange()+thisEntity:GetAttackRangeBuffer()
			local target = AICore:HighestThreatHeroInRange(thisEntity, radius, 0, true)
			if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity, radius, true) end
			if not target then target = AICore:NearestEnemyHeroInRange( thisEntity, 8000, true) end
			if target then
				if (target:GetOrigin() - thisEntity:GetOrigin()):Length2D() > 500 and thisEntity.berserk:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.berserk:entindex()
					})
					return thisEntity.berserk:GetCastPoint() + 0.1
				end
			end
			if thisEntity:IsAttacking() and thisEntity.berserk:IsFullyCastable() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.berserk:entindex()
				})
				return thisEntity.berserk:GetCastPoint() + 0.1
			end
			if thisEntity.tombstone:IsFullyCastable() and thisEntity:GetHealthPercent() < 5 then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.tombstone:entindex()
				})
				return AI_THINK_RATE
			elseif thisEntity.tombstone:IsFullyCastable() and thisEntity:GetHealthPercent() < 10 then
				if AICore:IsNearEnemyUnit(thisEntity, 600) then
					AICore:BeAHugeCoward( thisEntity, 600 )
					return AI_THINK_RATE
				else
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.tombstone:entindex()
					})
					return AI_THINK_RATE
				end
			end
			AICore:AttackHighestPriority( thisEntity )
			return AI_THINK_RATE
		else return AI_THINK_RATE end
	end
end