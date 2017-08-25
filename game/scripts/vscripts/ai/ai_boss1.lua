--[[
Broodking AI
]]
if IsServer() then
	require( "ai/ai_core" )
	
	AI_STATE_CLOSE_COMBAT = 1
	AI_STATE_CHASING = 2
	AI_STATE_STEALTH = 3
	
	function Spawn( entityKeyValues )
		thisEntity:SetContextThink( "AIThinker", AIThink, 0.25 )
		thisEntity.rush = thisEntity:FindAbilityByName("boss1a_rushdown")
		thisEntity.blink = thisEntity:FindAbilityByName("boss1a_blink_strike")
		thisEntity.vanish = thisEntity:FindAbilityByName("boss1a_vanish")
		if  math.floor(GameRules.gameDifficulty + 0.5) > 2 then
			thisEntity.vanish:SetLevel(2)
			thisEntity.blink:SetLevel(2)
			thisEntity.rush:SetLevel(2)
		else
			thisEntity.vanish:SetLevel(1)
			thisEntity.blink:SetLevel(1)
			thisEntity.rush:SetLevel(1)
		end
		thisEntity.AIbehavior = RandomInt(1,3)
	end


	function AIThink()
		if not thisEntity:IsDominated() and not thisEntity:IsCommandRestricted() then
			EvaluateBehavior(thisEntity)
			if thisEntity.AIstate == AI_STATE_CLOSE_COMBAT then
				if thisEntity.AIbehavior == AI_BEHAVIOR_AGGRESSIVE then -- uses all abilities without concern of options
					if thisEntity:IsAttacking() and not thisEntity:IsInvisible() then
						local target = thisEntity:GetAttackTarget()
						if target then
							if thisEntity.vanish:IsFullyCastable() then
								ExecuteOrderFromTable({
									UnitIndex = thisEntity:entindex(),
									OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
									AbilityIndex = thisEntity.vanish:entindex()
								})
								return 0.25
							elseif thisEntity.blink:IsFullyCastable() then
								local targetPos = AICore:OptimalHitPosition(thisEntity, CalculateDistance(target:GetAbsOrigin(), thisEntity), thisEntity.blink:GetSpecialValueFor("strike_radius"), true)
								ExecuteOrderFromTable({
									UnitIndex = thisEntity:entindex(),
									OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
									Position = targetPos,
									AbilityIndex = thisEntity.blink:entindex()
								})
							elseif thisEntity.rush:IsFullyCastable() then
								if AICore:NumEnemiesInLine(thisEntity, thisEntity.rush:GetTrueCastRange(), 175, true) >= 2 then
									ExecuteOrderFromTable({
										UnitIndex = thisEntity:entindex(),
										OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
										Position = AICore:FindFarthestEnemyInLine(thisEntity, thisEntity.rush:GetTrueCastRange(), 175, true):GetAbsOrigin(),
										AbilityIndex = thisEntity.rush:entindex()
									})
									return 0.25
								end
							end
						end
					else
						local target = AICore:GetHighestPriorityTarget(thisEntity)
						if target then
							local distance = CalculateDistance(thisEntity, target)
							local pathLength = GridNav:FindPathLength(thisEntity:GetAbsOrigin(), target:GetAbsOrigin())
							if (pathLength < 0 or AICore:NumEnemiesInLine(thisEntity, thisEntity.rush:GetTrueCastRange(), 175, true) < 2) and thisEntity.blink:IsFullyCastable() then
								local targetPos = AICore:OptimalHitPosition(thisEntity, distance, thisEntity.blink:GetSpecialValueFor("strike_radius"), true)
								ExecuteOrderFromTable({
									UnitIndex = thisEntity:entindex(),
									OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
									Position = targetPos,
									AbilityIndex = thisEntity.blink:entindex()
								})
							elseif pathLength > distance and thisEntity.rush:IsFullyCastable() then
								ExecuteOrderFromTable({
									UnitIndex = thisEntity:entindex(),
									OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
									Position = AICore:FindFarthestEnemyInLine(thisEntity, thisEntity.rush:GetTrueCastRange(), 175, true):GetAbsOrigin(),
									AbilityIndex = thisEntity.rush:entindex()
								})
							end
						end
					end
				elseif thisEntity.AIbehavior == AI_BEHAVIOR_HARRASSING then -- uses abilities to get in and out
				elseif thisEntity.AIbehavior == AI_BEHAVIOR_PERSISTENT then -- tries to use mobility and invis to focus a target down and runs if it gets attacked by others, unless if it has no other choice
				end

			elseif thisEntity.AIstate == AI_STATE_CHASING then
				local target = AICore:GetHighestPriorityTarget(thisEntity)
			elseif thisEntity.AIstate == AI_STATE_STEALTH then
				local target = AICore:GetHighestPriorityTarget(thisEntity)
			end
			AICore:AttackHighestPriority( thisEntity )
			return 0.25
		else return 0.25 end
	end
	
	function EvaluateBehavior(entity)
		if AICore:IsNearEnemyUnit(entity, 1500) then
			if AICore:IsNearEnemyUnit(entity, entity:GetAttackRange() + entity:GetIdealSpeed() * 0.2 ) then
				entity.AIstate = AI_STATE_CLOSE_COMBAT
			else
				entity.AIstate = AI_STATE_CHASING
			end
		else
			entity.AIstate = AI_STATE_STEALTH
		end
	end
end