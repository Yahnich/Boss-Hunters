--[[
Broodking AI
]]

if IsServer() then
	require( "ai/ai_core" )
	function Spawn( entityKeyValues )
		thisEntity:SetContextThink( "AIThinker", AIThink, 0.25 )
		thisEntity.burrow = thisEntity:FindAbilityByName("boss19_burrow")
		thisEntity.ground = thisEntity:FindAbilityByName("boss19_cracked_ground")
		thisEntity.swarm = thisEntity:FindAbilityByName("boss19_the_swarm")
		thisEntity.chasm = thisEntity:FindAbilityByName("boss19_chasm")
		Timers:CreateTimer(0.1, function()
			if  math.floor(GameRules.gameDifficulty + 0.5) <= 2 then
				thisEntity.burrow:SetLevel(1)
				thisEntity.ground:SetLevel(1)
				thisEntity.swarm:SetLevel(1)
				thisEntity.chasm:SetLevel(1)
			else
				thisEntity.burrow:SetLevel(2)
				thisEntity.ground:SetLevel(2)
				thisEntity.swarm:SetLevel(2)
				thisEntity.chasm:SetLevel(2)
			end
		end)
		thisEntity.ground.uses = 4
		thisEntity.ground.useTable = {}
		if  math.floor(GameRules.gameDifficulty + 0.5) > 2 then
			thisEntity:SetBaseMaxHealth(thisEntity:GetMaxHealth()*1.5)
			thisEntity:SetMaxHealth(thisEntity:GetMaxHealth()*1.5)
			thisEntity:SetHealth(thisEntity:GetMaxHealth())
		end
	end
	function AIThink()
		local target = AICore:GetHighestPriorityTarget(thisEntity)
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
			if target then
				if thisEntity.ground:IsFullyCastable() and thisEntity.ground.uses > #thisEntity.ground.useTable and thisEntity:GetHealthPercent() < 100/thisEntity.ground.uses * (thisEntity.ground.uses - #thisEntity.ground.useTable) and AICore:TotalEnemyHeroesInRange( thisEntity, thisEntity.ground:GetTrueCastRange() ) > 0 then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.ground:entindex()
					})
					return thisEntity.ground:GetChannelTime() + 0.1
				end
				if thisEntity.chasm:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = target:GetAbsOrigin(),
						AbilityIndex = thisEntity.chasm:entindex()
					})
					return thisEntity.chasm:GetCastPoint() + 0.1
				end
				if thisEntity.swarm:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = target:GetAbsOrigin(),
						AbilityIndex = thisEntity.swarm:entindex()
					})
					return thisEntity.swarm:GetCastPoint() + 0.1
				end
				if thisEntity:GetHealthPercent() < 75 then
					if thisEntity.burrow:IsFullyCastable() then
						local randomPos = target:GetAbsOrigin() + ActualRandomVector(1000, 400)
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
							Position = randomPos,
							AbilityIndex = thisEntity.burrow:entindex()
						})
						return thisEntity.burrow:GetCastPoint() + 0.1
					end
				elseif thisEntity:GetHealthPercent() < 40 then
					if thisEntity.burrow:IsFullyCastable() then
						local randomPos = caster:GetAbsOrigin() + ActualRandomVector(1000, 400)
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
							Position = randomPos,
							AbilityIndex = thisEntity.burrow:entindex()
						})
						return thisEntity.burrow:GetCastPoint() + 0.1
					end
				else
					if thisEntity.burrow:IsFullyCastable() and AICore:TotalEnemyHeroesInRange( thisEntity, 800 ) == 0 then
						local randomPos = target:GetAbsOrigin() + ActualRandomVector(1000, 400)
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
							Position = randomPos,
							AbilityIndex = thisEntity.burrow:entindex()
						})
						return thisEntity.burrow:GetCastPoint() + 0.1
					end
				end
				
				AICore:AttackHighestPriority( thisEntity )
				return 0.25
			else
				AICore:AttackHighestPriority( thisEntity )
				return 0.25
			end
		end
		return 0.25
	end
end