if IsServer() then
	require( "ai/ai_core" )
	function Spawn( entityKeyValues )
		AITimers:CreateTimer(function()
			if thisEntity and not thisEntity:IsNull() then
				return AIThink(thisEntity)
			end
		end)
		thisEntity.raze1 = thisEntity:FindAbilityByName("boss33b_shadowrazeN")
		thisEntity.raze2 = thisEntity:FindAbilityByName("boss33b_shadowrazeM")
		thisEntity.raze3 = thisEntity:FindAbilityByName("boss33b_shadowrazeF")
		thisEntity.shield = thisEntity:FindAbilityByName("boss33b_protective_shield")
		
		AITimers:CreateTimer(function()
			if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
				thisEntity.raze1:SetLevel(1)
				thisEntity.raze1:SetLevel(1)
				thisEntity.raze1:SetLevel(1)
				thisEntity.raze1:SetLevel(1)
			else
				thisEntity.raze1:SetLevel(2)
				thisEntity.raze1:SetLevel(2)
				thisEntity.raze1:SetLevel(2)
				thisEntity.raze1:SetLevel(2)
			end
		end)
	end


	function AIThink(thisEntity)
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
			local target = AICore:GetHighestPriorityTarget(thisEntity)
			if thisEntity:GetHealthPercent() > 50 then
				local raze1Pos = GetGroundPosition(thisEntity:GetAbsOrigin() + thisEntity:GetForwardVector() * thisEntity.raze1:GetSpecialValueFor("distance"), thisEntity)
				local raze2Pos = GetGroundPosition(thisEntity:GetAbsOrigin() + thisEntity:GetForwardVector() * thisEntity.raze2:GetSpecialValueFor("distance"), thisEntity)
				local raze3Pos = GetGroundPosition(thisEntity:GetAbsOrigin() + thisEntity:GetForwardVector() * thisEntity.raze3:GetSpecialValueFor("distance"), thisEntity)
				local razeRadius = thisEntity.raze1:GetSpecialValueFor("radius") + 32
				
				local raze1Units = thisEntity:FindEnemyUnitsInRadius(raze1Pos, razeRadius)
				local raze2Units = thisEntity:FindEnemyUnitsInRadius(raze2Pos, razeRadius)
				local raze3Units = thisEntity:FindEnemyUnitsInRadius(raze3Pos, razeRadius)
				
				local razesActive = 0
				if thisEntity.raze1:IsFullyCastable() then razesActive = razesActive + 1 end
				if thisEntity.raze2:IsFullyCastable() then razesActive = razesActive + 1 end
				if thisEntity.raze3:IsFullyCastable() then razesActive = razesActive + 1 end

				if thisEntity.raze1:IsFullyCastable() and ( #raze1Units > 2 or HasValInTable(raze1Units, target) ) or (#raze1Units > 1 and razesActive < 1) or RollPercentage(15) then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.raze1:entindex()
					})
					return thisEntity.raze1:GetCastPoint() + 0.1
				end
				if thisEntity.raze2:IsFullyCastable() and ( #raze2Units > 2 or HasValInTable(raze2Units, target) ) or (#raze2Units > 1 and razesActive < 1) or RollPercentage(15) then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.raze2:entindex()
					})
					return thisEntity.raze2:GetCastPoint() + 0.1
				end
				if thisEntity.raze3:IsFullyCastable() and ( #raze3Units > 2 or HasValInTable(raze3Units, target) ) or (#raze3Units > 1 and razesActive < 1) or RollPercentage(15) then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.raze3:entindex()
					})
					return thisEntity.raze3:GetCastPoint() + 0.1
				end
			else
				local raze1Pos = GetGroundPosition(thisEntity:GetAbsOrigin() + thisEntity:GetForwardVector() * thisEntity.raze1:GetSpecialValueFor("distance"), thisEntity)
				local raze2Pos = GetGroundPosition(thisEntity:GetAbsOrigin() + thisEntity:GetForwardVector() * thisEntity.raze2:GetSpecialValueFor("distance"), thisEntity)
				local raze3Pos = GetGroundPosition(thisEntity:GetAbsOrigin() + thisEntity:GetForwardVector() * thisEntity.raze3:GetSpecialValueFor("distance"), thisEntity)
				local razeRadius = thisEntity.raze1:GetSpecialValueFor("radius")
				
				local raze1Units = thisEntity:FindEnemyUnitsInRadius(raze1Pos, razeRadius)
				local raze2Units = thisEntity:FindEnemyUnitsInRing(thisEntity:GetAbsOrigin(), thisEntity.raze2:GetSpecialValueFor("distance") + razeRadius,  thisEntity.raze2:GetSpecialValueFor("distance") - razeRadius)
				local raze3Units = thisEntity:FindEnemyUnitsInLine(thisEntity:GetAbsOrigin(), thisEntity:GetAbsOrigin() + thisEntity:GetForwardVector() * (thisEntity.raze3:GetSpecialValueFor("distance")/3) * thisEntity.raze3:GetSpecialValueFor("phase2_raze_count"), razeRadius)
				
				local razesActive = 0
				if thisEntity.raze1:IsFullyCastable() then razesActive = razesActive + 1 end
				if thisEntity.raze2:IsFullyCastable() then razesActive = razesActive + 1 end
				if thisEntity.raze3:IsFullyCastable() then razesActive = razesActive + 1 end
				
				if thisEntity.raze1:IsFullyCastable() and ( #raze1Units > 2 or HasValInTable(raze2Units, target) )  or (#raze1Units > 1 and razesActive > 1) then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.raze1:entindex()
					})
					return thisEntity.raze1:GetCastPoint() + 0.1
				end
				if thisEntity.raze2:IsFullyCastable() and ( #raze2Units > 2 or HasValInTable(raze2Units, target) )  or (#raze2Units > 1 and razesActive > 1) then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.raze2:entindex()
					})
					return thisEntity.raze2:GetCastPoint() + 0.1
				end
				if thisEntity.raze3:IsFullyCastable() and ( #raze3Units > 2 or HasValInTable(raze2Units, target) )  or (#raze3Units > 1 and razesActive > 1)then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.raze3:entindex()
					})
					return thisEntity.raze3:GetCastPoint() + 0.1
				end
			end
			return AICore:AttackHighestPriority( thisEntity )
		else return AI_THINK_RATE end
	end
end