--[[
Broodking AI
]]
if IsServer() then
	require( "ai/ai_core" )
	
	AI_STATE_CLOSE_COMBAT = 1
	AI_STATE_CHASING = 2
	AI_STATE_STEALTH = 3
	
	function Spawn( entityKeyValues )
		Timers:CreateTimer(function()
			if thisEntity and not thisEntity:IsNull() then
				return AIThink(thisEntity)
			end
		end)
		thisEntity.rush = thisEntity:FindAbilityByName("boss1a_rushdown")
		thisEntity.blink = thisEntity:FindAbilityByName("boss1a_blink_strike")
		thisEntity.vanish = thisEntity:FindAbilityByName("boss1a_vanish")
		Timers:CreateTimer(0.1, function()
			if  math.floor(GameRules.gameDifficulty + 0.5) > 2 then
				thisEntity.vanish:SetLevel(2)
				thisEntity.blink:SetLevel(2)
				thisEntity.rush:SetLevel(2)
			else
				thisEntity.vanish:SetLevel(1)
				thisEntity.blink:SetLevel(1)
				thisEntity.rush:SetLevel(1)
			end
		end)
		thisEntity.AIbehavior = RandomInt(1,3)
	end


	function AIThink(thisEntity)
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
								return AI_THINK_RATE
							elseif thisEntity.blink:IsFullyCastable() then
								local targetPos = AICore:OptimalHitPosition(thisEntity, CalculateDistance(target:GetAbsOrigin(), thisEntity), thisEntity.blink:GetSpecialValueFor("strike_radius"), true)
								ExecuteOrderFromTable({
									UnitIndex = thisEntity:entindex(),
									OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
									Position = targetPos,
									AbilityIndex = thisEntity.blink:entindex()
								})
								return AI_THINK_RATE
							elseif thisEntity.rush:IsFullyCastable() then
								if AICore:NumEnemiesInLine(thisEntity, thisEntity.rush:GetTrueCastRange(), 175, true) >= 2 then
									ExecuteOrderFromTable({
										UnitIndex = thisEntity:entindex(),
										OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
										Position = AICore:FindFarthestEnemyInLine(thisEntity, thisEntity.rush:GetTrueCastRange(), 175, true):GetAbsOrigin(),
										AbilityIndex = thisEntity.rush:entindex()
									})
									return AI_THINK_RATE
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
								return AI_THINK_RATE
							elseif pathLength < thisEntity.rush:GetTrueCastRange() and thisEntity.rush:IsFullyCastable() then
								local rushTarget = AICore:FindFarthestEnemyInLine(thisEntity, thisEntity.rush:GetTrueCastRange(), 175, true)
								local rushPos = target:GetAbsOrigin()
								if rushTarget then rushPos = rushTarget:GetAbsOrigin() end
								rushPos = rushPos + CalculateDirection(rushPos, thisEntity) * thisEntity:GetAttackRange()
								ExecuteOrderFromTable({
									UnitIndex = thisEntity:entindex(),
									OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
									Position = rushPos,
									AbilityIndex = thisEntity.rush:entindex()
								})
								return AI_THINK_RATE
							end
						end
					end
				elseif thisEntity.AIbehavior == AI_BEHAVIOR_CAUTIOUS then -- uses abilities to get in and out
					local target = AICore:GetHighestPriorityTarget(thisEntity)
					if target then
						local hasBothSpells = thisEntity.rush:IsFullyCastable() and thisEntity.blink:IsFullyCastable()
						local hasOneSpell = thisEntity.rush:IsFullyCastable() or thisEntity.blink:IsFullyCastable()
						local attackedByOthers = (AICore:BeingAttacked( thisEntity ) > 1 and target:IsAttackingEntity(thisEntity) )
						if hasBothSpells then
							local distance = CalculateDistance(thisEntity, target)
							local pathLength = GridNav:FindPathLength(thisEntity:GetAbsOrigin(), target:GetAbsOrigin())
							if (pathLength < 0 or AICore:NumEnemiesInLine(thisEntity, thisEntity.rush:GetTrueCastRange(), 175, true) <= math.min(PlayerResource:FindActivePlayerCount(), 2)) and thisEntity.blink:IsFullyCastable() then
								local targetPos = AICore:OptimalHitPosition(thisEntity, distance, thisEntity.blink:GetSpecialValueFor("strike_radius"), true)
								ExecuteOrderFromTable({
									UnitIndex = thisEntity:entindex(),
									OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
									Position = targetPos,
									AbilityIndex = thisEntity.blink:entindex()
								})
								return AI_THINK_RATE
							elseif pathLength > distance and thisEntity.rush:IsFullyCastable() then
								ExecuteOrderFromTable({
									UnitIndex = thisEntity:entindex(),
									OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
									Position = AICore:FindFarthestEnemyInLine(thisEntity, thisEntity.rush:GetTrueCastRange(), 175, true):GetAbsOrigin(),
									AbilityIndex = thisEntity.rush:entindex()
								})
								return AI_THINK_RATE
							end
						elseif hasOneSpell then
							if attackedByOthers then
								local targetPos
								for _, attacker in ipairs( AICore:BeingAttackedBy( thisEntity ) ) do
									targetPos = ((targetPos or attacker:GetAbsOrigin()) + attacker:GetAbsOrigin()) / 2
								end
								local runDir = CalculateDirection(thisEntity, targetPos)
								if thisEntity.blink:IsFullyCastable() then
									ExecuteOrderFromTable({
										UnitIndex = thisEntity:entindex(),
										OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
										Position = thisEntity:GetAbsOrigin() + runDir * thisEntity.blink:GetTrueCastRange(),
										AbilityIndex = thisEntity.blink:entindex()
									})
									return AI_THINK_RATE
								elseif thisEntity.rush:IsFullyCastable() then
									ExecuteOrderFromTable({
										UnitIndex = thisEntity:entindex(),
										OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
										Position = thisEntity:GetAbsOrigin() + runDir * thisEntity.rush:GetTrueCastRange(),
										AbilityIndex = thisEntity.rush:entindex()
									})
									return AI_THINK_RATE
								end
							end
						else
							AICore:BeAHugeCoward( thisEntity, thisEntity:GetIdealSpeed() )
						end
					elseif not thisEntity:IsInvisible() then
						if thisEntity.vanish:IsFullyCastable() then
							ExecuteOrderFromTable({
								UnitIndex = thisEntity:entindex(),
								OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
								AbilityIndex = thisEntity.vanish:entindex()
							})
							return AI_THINK_RATE
						end
					end
				elseif thisEntity.AIbehavior == AI_BEHAVIOR_SAFE then -- tries to use mobility and invis to focus a target down and runs if it gets attacked by others, unless if it has no other choice
					local target = AICore:GetHighestPriorityTarget(thisEntity)
					if target then 
						if (AICore:BeingAttacked( thisEntity ) > 2 and target:IsAttackingEntity(thisEntity) ) or (AICore:BeingAttacked( thisEntity ) > 0 and not target:IsAttackingEntity(thisEntity)) and not thisEntity:IsInvisible() then
							if thisEntity.vanish:IsFullyCastable() then
								ExecuteOrderFromTable({
									UnitIndex = thisEntity:entindex(),
									OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
									AbilityIndex = thisEntity.vanish:entindex()
								})
								return AI_THINK_RATE
							elseif thisEntity.rush:IsFullyCastable() then
								local targetPos = thisEntity:GetAbsOrigin() + CalculateDirection(thisEntity, target) * thisEntity.rush:GetTrueCastRange()
								ExecuteOrderFromTable({
									UnitIndex = thisEntity:entindex(),
									OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
									Position = targetPos,
									AbilityIndex = thisEntity.rush:entindex()
								})
								return AI_THINK_RATE
							elseif thisEntity.blink:IsFullyCastable() then
								local targetPos
								for _, attacker in ipairs( AICore:BeingAttackedBy( thisEntity ) ) do
									targetPos = ((targetPos or attacker:GetAbsOrigin()) + attacker:GetAbsOrigin()) / 2
								end
								targetPos = thisEntity:GetAbsOrigin() + CalculateDirection(thisEntity, targetPos) * CalculateDistance(thisEntity, targetPos)
								ExecuteOrderFromTable({
									UnitIndex = thisEntity:entindex(),
									OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
									Position = targetPos,
									AbilityIndex = thisEntity.blink:entindex()
								})
								return AI_THINK_RATE
							end
						else
							if thisEntity:IsAttacking() and not thisEntity:IsInvisible() then
								if thisEntity.vanish:IsFullyCastable() then
									ExecuteOrderFromTable({
										UnitIndex = thisEntity:entindex(),
										OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
										AbilityIndex = thisEntity.vanish:entindex()
									})
									return AI_THINK_RATE
								elseif thisEntity.blink:IsFullyCastable() then
									ExecuteOrderFromTable({
										UnitIndex = thisEntity:entindex(),
										OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
										Position = target:GetAbsOrigin(),
										AbilityIndex = thisEntity.blink:entindex()
									})
									return AI_THINK_RATE
								elseif thisEntity.rush:IsFullyCastable() then
									ExecuteOrderFromTable({
										UnitIndex = thisEntity:entindex(),
										OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
										Position = target:GetAbsOrigin() + CalculateDirection(target, thisEntity) * (target:GetAttackRange() - 50),
										AbilityIndex = thisEntity.rush:entindex()
									})
									return AI_THINK_RATE
								end
							end
						end
					end
				end
			elseif thisEntity.AIstate == AI_STATE_CHASING then
				local target = AICore:GetHighestPriorityTarget(thisEntity)
				if target then
					local distance = CalculateDistance(thisEntity, target)
					local pathLength = GridNav:FindPathLength(thisEntity:GetAbsOrigin(), target:GetAbsOrigin())
					if (pathLength - 5 > distance and thisEntity.blink:IsFullyCastable()) then
						local distToReach = math.min(thisEntity.blink:GetTrueCastRange(), distance)
						local targetPos = thisEntity:GetAbsOrigin() + CalculateDirection(target, thisEntity) * distToReach
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
							Position = targetPos,
							AbilityIndex = thisEntity.blink:entindex()
						})
						return AI_THINK_RATE
					elseif thisEntity.rush:IsFullyCastable() then
						local distToReach = math.min(thisEntity.rush:GetTrueCastRange(), distance)
						local targetPos = thisEntity:GetAbsOrigin() + CalculateDirection(target, thisEntity) * distToReach
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
							Position = targetPos,
							AbilityIndex = thisEntity.rush:entindex()
						})
						return AI_THINK_RATE
					end
				end
			elseif thisEntity.AIstate == AI_STATE_STEALTH then
				local target = AICore:GetHighestPriorityTarget(thisEntity)
				if thisEntity.vanish:IsFullyCastable() and not thisEntity:IsInvisible() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.vanish:entindex()
					})
					return AI_THINK_RATE
				end
			end
			AICore:AttackHighestPriority( thisEntity )
			return AI_THINK_RATE
		else return AI_THINK_RATE end
	end
	
	function EvaluateBehavior(entity)
		if AICore:IsNearEnemyUnit(entity, 1500) then
			if AICore:IsNearEnemyUnit(entity, entity:GetAttackRange() + entity:GetIdealSpeed() * 0.8 ) then
				entity.AIstate = AI_STATE_CLOSE_COMBAT
			else
				entity.AIstate = AI_STATE_CHASING
			end
		else
			entity.AIstate = AI_STATE_STEALTH
		end
	end
end