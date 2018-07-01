if IsServer() then
	require( "ai/ai_core" )
	function Spawn( entityKeyValues )
		AITimers:CreateTimer(function()
			if thisEntity and not thisEntity:IsNull() then
				return AIThink(thisEntity)
			end
		end)
		thisEntity.thread = thisEntity:FindAbilityByName("boss15_thread_of_life")
		thisEntity.peel = thisEntity:FindAbilityByName("boss15_peel_the_veil")
		thisEntity.exorcise = thisEntity:FindAbilityByName("boss15_exorcise")
		AITimers:CreateTimer(0.1, function()
			if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
				thisEntity.thread:SetLevel(1)
				thisEntity.peel:SetLevel(1)
				thisEntity.exorcise:SetLevel(1)
			elseif  math.floor(GameRules.gameDifficulty + 0.5) == 2 then 
				thisEntity.thread:SetLevel(2)
				thisEntity.peel:SetLevel(2)
				thisEntity.exorcise:SetLevel(2)
			else
				thisEntity.thread:SetLevel(3)
				thisEntity.peel:SetLevel(3)
				thisEntity.exorcise:SetLevel(3)
			end
		end)
	end


	function AIThink(thisEntity)
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
			local target = AICore:GetHighestPriorityTarget(thisEntity)
			if target and not target:IsNull() then
				if thisEntity:GetHealthPercent() < 66 and thisEntity:GetHealthPercent() > 33 then
					if #thisEntity.thread:GetTethers() < 1 and thisEntity.thread:IsFullyCastable() then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
							TargetIndex = target:entindex(),
							AbilityIndex = thisEntity.thread:entindex()
						})
						return AI_THINK_RATE
					end
				else
					if thisEntity.thread:IsFullyCastable() then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
							TargetIndex = target:entindex(),
							AbilityIndex = thisEntity.thread:entindex()
						})
						return AI_THINK_RATE
					end
				end
				if thisEntity.exorcise:IsFullyCastable() and AICore:EnemiesInLine(thisEntity, thisEntity.exorcise:GetSpecialValueFor("distance"), thisEntity.exorcise:GetSpecialValueFor("width_end"), false) then
					local targetPos = thisEntity:GetAbsOrigin() + CalculateDirection(target, thisEntity) * 100
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = targetPos,
						AbilityIndex = thisEntity.exorcise:entindex()
					})
					return AI_THINK_RATE
				end
				if thisEntity.peel:IsFullyCastable() and thisEntity.peel:GetGhostCount() < 25 then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.peel:entindex()
					})
					return AI_THINK_RATE
				end
			end
			AICore:AttackHighestPriority( thisEntity )
			return AI_THINK_RATE
		else return AI_THINK_RATE end
	end
end