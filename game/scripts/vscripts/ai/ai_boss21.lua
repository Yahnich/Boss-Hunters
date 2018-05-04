--[[
Broodking AI
]]

if IsServer() then
	require( "ai/ai_core" )
	function Spawn( entityKeyValues )
		Timers:CreateTimer(function()
			if thisEntity and not thisEntity:IsNull() then
				return AIThink(thisEntity)
			end
		end)
		thisEntity.bloodlust = thisEntity:FindAbilityByName("boss14_bloodlust")
		thisEntity.execute = thisEntity:FindAbilityByName("boss14_execute")
		thisEntity.quake = thisEntity:FindAbilityByName("boss14_quake")
		thisEntity.whirlwind = thisEntity:FindAbilityByName("boss14_whirlwind")
		Timers:CreateTimer(0.1, function()
			if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
				thisEntity.bloodlust:SetLevel(1)
				thisEntity.execute:SetLevel(1)
				thisEntity.quake:SetLevel(1)
				thisEntity.whirlwind:SetLevel(1)
			else
				thisEntity.bloodlust:SetLevel(2)
				thisEntity.execute:SetLevel(2)
				thisEntity.quake:SetLevel(2)
				thisEntity.whirlwind:SetLevel(2)
			end
		end)
	end


	function AIThink(thisEntity)
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
			local target = AICore:GetHighestPriorityTarget(thisEntity)
			if target and not target:IsNull() then
				if thisEntity:GetHealthPercent() > 50 then
					if thisEntity.quake and thisEntity.quake:IsFullyCastable() then
						local radius = thisEntity.quake:GetSpecialValueFor("radius")
						if AICore:TotalNotDisabledEnemyHeroesInRange( thisEntity, radius, false ) >= AICore:TotalEnemyHeroesInRange( thisEntity, radius ) and not AICore:TotalNotDisabledEnemyHeroesInRange( thisEntity, radius, false ) == 0 then
							ExecuteOrderFromTable({
								UnitIndex = thisEntity:entindex(),
								OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
								Position = thisEntity:GetAbsOrigin(),
								AbilityIndex = thisEntity.quake:entindex()
							})
							return thisEntity.quake:GetCastPoint() + 0.1
						end
					end
					if thisEntity.execute and thisEntity.execute:IsFullyCastable() then
						local executeTarget = thisEntity.execute:NearestExecuteableTarget( thisEntity.execute:GetTrueCastRange() + thisEntity:GetIdealSpeed() ) or target
						if executeTarget and not executeTarget:IsNull() then
							ExecuteOrderFromTable({
								UnitIndex = thisEntity:entindex(),
								OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
								TargetIndex = executeTarget:entindex(),
								AbilityIndex = thisEntity.execute:entindex()
							})
							return thisEntity.execute:GetCastPoint() + 1.2
						end
					end
					if thisEntity.whirlwind and thisEntity.whirlwind:IsFullyCastable() and AICore:TotalEnemyHeroesInRange( thisEntity,  thisEntity.whirlwind:GetSpecialValueFor("radius") ) > 0 then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = thisEntity.whirlwind:entindex()
						})
						return thisEntity.whirlwind:GetCastPoint() + 0.1
					end
				else
					if thisEntity.quake and thisEntity.quake:IsFullyCastable() then
						local radius = thisEntity.quake:GetSpecialValueFor("radius")
						if AICore:TotalNotDisabledEnemyHeroesInRange( thisEntity, radius, false ) >= AICore:TotalEnemyHeroesInRange( thisEntity, radius ) then
							ExecuteOrderFromTable({
								UnitIndex = thisEntity:entindex(),
								OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
								Position = target:GetAbsOrigin(),
								AbilityIndex = thisEntity.quake:entindex()
							})
							return thisEntity.quake:GetCastPoint() + 0.1
						end
					end
					if thisEntity.whirlwind and thisEntity.whirlwind:IsFullyCastable() then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = thisEntity.whirlwind:entindex()
						})
						return thisEntity.whirlwind:GetCastPoint() + 0.1
					end
					if thisEntity.execute and thisEntity.execute:IsFullyCastable() then
						local executeTarget = thisEntity.execute:NearestExecuteableTarget( thisEntity.execute:GetTrueCastRange() + thisEntity:GetIdealSpeed() ) or target
						if executeTarget then
							ExecuteOrderFromTable({
								UnitIndex = thisEntity:entindex(),
								OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
								TargetIndex = executeTarget:entindex(),
								AbilityIndex = thisEntity.execute:entindex()
							})
							return thisEntity.execute:GetCastPoint() + 3
						end
					end
				end
			end
			AICore:AttackHighestPriority( thisEntity )
			return AI_THINK_RATE
		else return AI_THINK_RATE end
	end
end