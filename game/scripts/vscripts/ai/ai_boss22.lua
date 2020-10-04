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
			for i = 0, thisEntity:GetAbilityCount() - 1 do
				local ability = thisEntity:GetAbilityByIndex( i )
				
				if ability then
					ability:SetLevel( math.floor( GameRules.gameDifficulty/2 + 0.5) )
				end
			end
		end)
	end


	function AIThink(thisEntity)
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
			local target = AICore:GetHighestPriorityTarget(thisEntity)
			if target and not target:IsNull() then
				if thisEntity.thread then
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
				end
				if thisEntity.exorcise then
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
				end
				if thisEntity.peel then
					if thisEntity.peel:IsFullyCastable() and thisEntity.peel:GetGhostCount() < 25 then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = thisEntity.peel:entindex()
						})
						return AI_THINK_RATE
					end
				end
			end
			return AICore:AttackHighestPriority( thisEntity )
		else return AI_THINK_RATE end
	end
end