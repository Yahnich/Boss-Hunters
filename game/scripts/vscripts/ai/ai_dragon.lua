--[[
Broodking AI
]]

if IsServer() then
	function Spawn( entityKeyValues )
		AITimers:CreateTimer(function()
			if thisEntity and not thisEntity:IsNull() then
				return AIThink(thisEntity)
			end
		end)
		thisEntity.flock = thisEntity:FindAbilityByName("boss16_the_flock")
		thisEntity.conflag = thisEntity:FindAbilityByName("boss16_conflagration")
		thisEntity.dragonfire = thisEntity:FindAbilityByName("boss16_dragonfire")
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
			thisEntity.flock:SetLevel(1)
			thisEntity.conflag:SetLevel(3)
			thisEntity.dragonfire:SetLevel(3)
		else
			thisEntity.flock:SetLevel(2)
			thisEntity.conflag:SetLevel(4)
			thisEntity.dragonfire:SetLevel(4)
		end
	end


	function AIThink(thisEntity)
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
			local target = AICore:GetHighestPriorityTarget(thisEntity)
			if target then
				if thisEntity.flock:IsFullyCastable() then
					local noDrakes = (thisEntity.flock:GetDrakeCount() == 0)
					local reachedHPThreshold1 = (thisEntity:GetHealthPercent() < 66 and not thisEntity.reachedFirstThreshold)
					local reachedHPThreshold2 = (thisEntity:GetHealthPercent() < 33 and not thisEntity.reachedSecondThreshold)
					if reachedHPThreshold1 and not thisEntity.reachedFirstThreshold then thisEntity.reachedFirstThreshold = true end
					if reachedHPThreshold2 and not thisEntity.reachedSecondThreshold then thisEntity.reachedSecondThreshold = true end
					if noDrakes or reachedHPThreshold1 or reachedHPThreshold2 then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = thisEntity.flock:entindex()
						})
						return thisEntity.flock:GetCastPoint() + 0.1
					end
				end
				if thisEntity.conflag:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = target:GetAbsOrigin(),
						AbilityIndex = thisEntity.conflag:entindex()
					})
					return thisEntity.conflag:GetCastPoint() + 0.1
				end
				if thisEntity.dragonfire:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = target:GetAbsOrigin(),
						AbilityIndex = thisEntity.dragonfire:entindex()
					})
					return thisEntity.dragonfire:GetCastPoint() + 0.1
				end
			end
			AICore:AttackHighestPriority( thisEntity )
			return 0.25
		else return 0.25 end
	end
end