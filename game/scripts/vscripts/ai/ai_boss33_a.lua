if IsServer() then
	require( "ai/ai_core" )
	function Spawn( entityKeyValues )
		AITimers:CreateTimer(function()
			if thisEntity and not thisEntity:IsNull() then
				return AIThink(thisEntity)
			end
		end)
		thisEntity.poison = thisEntity:FindAbilityByName("boss33a_devitalize")
		thisEntity.orb = thisEntity:FindAbilityByName("boss33a_dark_orb")
		thisEntity.ward = thisEntity:FindAbilityByName("boss33a_protective_ward")
		
		thisEntity.IsTwinAlive = function(thisEntity)
			local sdCheck = thisEntity:FindFriendlyUnitsInRadius(thisEntity:GetAbsOrigin(),-1)
			for _, isSD in ipairs(sdCheck) do
				if isSD:GetUnitName() == "npc_dota_boss33_b" then 
					return true
				end
			end
			return false
		end
		
		AITimers:CreateTimer(0.1, function()
			if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
				thisEntity.poison:SetLevel(1)
				thisEntity.orb:SetLevel(1)
				thisEntity.ward:SetLevel(1)
			else
				thisEntity.poison:SetLevel(2)
				thisEntity.orb:SetLevel(2)
				thisEntity.ward:SetLevel(2)
			end
		end)
	end


	function AIThink(thisEntity)
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
			local target = AICore:GetHighestPriorityTarget(thisEntity)
			if target and CalculateDistance(target, thisEntity) > thisEntity.poison:GetTrueCastRange() then target = AICore:RandomEnemyHeroInRange( thisEntity, thisEntity.poison:GetTrueCastRange() , false) end
			if target then
				if thisEntity.poison:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = target:GetAbsOrigin(),
						AbilityIndex = thisEntity.poison:entindex()
					})
					return thisEntity.poison:GetCastPoint() + 0.1
				end
				if thisEntity.orb:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = target:GetAbsOrigin(),
						AbilityIndex = thisEntity.orb:entindex()
					})
					return thisEntity.orb:GetCastPoint() + 0.1
				end
			end
			return AICore:AttackHighestPriority( thisEntity )
		else return AI_THINK_RATE end
	end
end