if IsServer() then
	require( "ai/ai_core" )
	function Spawn( entityKeyValues )
		thisEntity:SetContextThink( "AIThinker", AIThink, 0.25 )
		thisEntity.raze1 = thisEntity:FindAbilityByName("boss33b_shadowrazeN")
		thisEntity.raze2 = thisEntity:FindAbilityByName("boss33b_shadowrazeM")
		thisEntity.raze3 = thisEntity:FindAbilityByName("boss33b_shadowrazeF")
		thisEntity.shield = thisEntity:FindAbilityByName("boss33b_protective_shield")
		
		thisEntity.IsTwinAlive = function(self)
			local sdCheck = self:FindFriendlyUnitsInRadius(self:GetAbsOrigin(),-1)
			for _, isSD in ipairs(sdCheck) do
				if isSD:GetUnitName() == "npc_dota_boss33_a" then 
					return true
				end
			end
			return false
		end
		
		Timers:CreateTimer(function()
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
				
				thisEntity:SetBaseMaxHealth(thisEntity:GetBaseMaxHealth()*1.5)
				thisEntity:SetMaxHealth(thisEntity:GetMaxHealth()*1.5)
				thisEntity:SetHealth(thisEntity:GetMaxHealth())
			end
		end)
	end


	function AIThink()
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
			local target = AICore:GetHighestPriorityTarget(thisEntity)
			if thisEntity:GetHealthPercent() > 50 then
				local raze1Pos = GetGroundPosition(thisEntity:GetAbsOrigin() + thisEntity:GetForwardVector() * thisEntity.raze1:GetSpecialValueFor("distance"), thisEntity)
				local raze2Pos = GetGroundPosition(thisEntity:GetAbsOrigin() + thisEntity:GetForwardVector() * thisEntity.raze2:GetSpecialValueFor("distance"), thisEntity)
				local raze3Pos = GetGroundPosition(thisEntity:GetAbsOrigin() + thisEntity:GetForwardVector() * thisEntity.raze3:GetSpecialValueFor("distance"), thisEntity)
				local razeRadius = thisEntity.raze1:GetSpecialValueFor("radius")
				
				local raze1Units = thisEntity:FindEnemyUnitsInRadius(raze1Pos, razeRadius)
				local raze2Units = thisEntity:FindEnemyUnitsInRadius(raze2Pos, razeRadius)
				local raze3Units = thisEntity:FindEnemyUnitsInRadius(raze3Pos, razeRadius)

				if thisEntity.raze1:IsFullyCastable() and ( #raze1Units > 2 or HasValInTable(raze1Units, target) ) then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.raze1:entindex()
					})
					return thisEntity.raze1:GetCastPoint() + 0.1
				end
				if thisEntity.raze2:IsFullyCastable() and ( #raze2Units > 2 or HasValInTable(raze2Units, target) ) then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.raze2:entindex()
					})
					return thisEntity.raze2:GetCastPoint() + 0.1
				end
				if thisEntity.raze3:IsFullyCastable() and ( #raze3Units > 2 or HasValInTable(raze3Units, target) ) then
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
				local raze3Units = thisEntity:FindEnemyUnitsInLine(thisEntity:GetAbsOrigin(), thisEntity:GetAbsOrigin() + caster:GetForwardVector() * (thisEntity.raze3:GetSpecialValueFor("distance")/3) * self:GetSpecialValueFor("phase2_raze_count"), razeRadius)
				
				if thisEntity.raze1:IsFullyCastable() and ( #raze1Units > 2 or HasValInTable(raze2Units, target) ) then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.raze1:entindex()
					})
					return thisEntity.raze1:GetCastPoint() + 0.1
				end
				if thisEntity.raze2:IsFullyCastable() and ( #raze2Units > 2 or HasValInTable(raze2Units, target) ) then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.raze2:entindex()
					})
					return thisEntity.raze2:GetCastPoint() + 0.1
				end
				if thisEntity.raze3:IsFullyCastable() and ( #raze3Units > 2 or HasValInTable(raze2Units, target) ) then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.raze3:entindex()
					})
					return thisEntity.raze3:GetCastPoint() + 0.1
				end
			end
			AICore:AttackHighestPriority( thisEntity )
			return 0.25
		else return 0.25 end
	end
end