--[[
Broodking AI
]]

if IsServer() then
	require( "ai/ai_core" )
	function Spawn( entityKeyValues )
		thisEntity:SetContextThink( "AIThinker", AIThink, 0.25 )
		thisEntity.thread = thisEntity:FindAbilityByName("boss15_thread_of_life")
		thisEntity.peel = thisEntity:FindAbilityByName("boss15_peel_the_veil")
		thisEntity.exorcise = thisEntity:FindAbilityByName("boss15_exorcise")
		Timers:CreateTimer(0.1, function()
			if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
				thisEntity.thread:SetLevel(1)
				thisEntity.peel:SetLevel(1)
				thisEntity.exorcise:SetLevel(1)
			elseif  math.floor(GameRules.gameDifficulty + 0.5) == 2 then 
				thisEntity.thread:SetLevel(2)
				thisEntity.peel:SetLevel(2)
				thisEntity.exorcise:SetLevel(2)
				
				thisEntity:SetBaseMaxHealth(thisEntity:GetMaxHealth()*1.2)
				thisEntity:SetMaxHealth(thisEntity:GetMaxHealth()*1.2)
				thisEntity:SetHealth(thisEntity:GetMaxHealth())
			else
				thisEntity.thread:SetLevel(3)
				thisEntity.peel:SetLevel(3)
				thisEntity.exorcise:SetLevel(3)
				
				thisEntity:SetBaseMaxHealth(thisEntity:GetMaxHealth()*1.5)
				thisEntity:SetMaxHealth(thisEntity:GetMaxHealth()*1.5)
				thisEntity:SetHealth(thisEntity:GetMaxHealth())
			end
		end)
	end


	function AIThink()
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
						return 0.25
					end
				else
					if thisEntity.thread:IsFullyCastable() then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
							TargetIndex = target:entindex(),
							AbilityIndex = thisEntity.thread:entindex()
						})
						return 0.25
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
					return 0.25
				end
				if thisEntity.peel:IsFullyCastable() and thisEntity.peel:GetGhostCount() < 25 then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.peel:entindex()
					})
					return 0.25
				end
			end
			AICore:AttackHighestPriority( thisEntity )
			return 0.25
		else return 0.25 end
	end
end