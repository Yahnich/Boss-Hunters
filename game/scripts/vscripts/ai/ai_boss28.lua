if IsServer() then
	require( "ai/ai_core" )
	function Spawn( entityKeyValues )
		Timers:CreateTimer(function()
			if thisEntity and not thisEntity:IsNull() then
				return AIThink(thisEntity)
			end
		end)
		thisEntity.trample = thisEntity:FindAbilityByName("boss18b_trample")
		thisEntity.swipe = thisEntity:FindAbilityByName("boss18b_swipe")
		thisEntity.frenzy = thisEntity:FindAbilityByName("boss18b_frenzy")
		thisEntity.huntress = thisEntity:FindAbilityByName("boss18b_elusive_huntress")
		Timers:CreateTimer(0.1, function()
			if  math.floor(GameRules.gameDifficulty + 0.5) <= 2 then
				thisEntity.trample:SetLevel(1)
				thisEntity.swipe:SetLevel(1)
				thisEntity.frenzy:SetLevel(1)
				thisEntity.huntress:SetLevel(1)
			else
				thisEntity.trample:SetLevel(2)
				thisEntity.swipe:SetLevel(2)
				thisEntity.frenzy:SetLevel(2)
				thisEntity.huntress:SetLevel(2)
			end
		end)
	end
	function AIThink()
		local target = AICore:GetHighestPriorityTarget(thisEntity)
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
			if thisEntity.frenzy:IsFullyCastable() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.frenzy:entindex()
				})
				return thisEntity.frenzy:GetCastPoint() + 0.1
			end
			if target then
				if thisEntity.trample:IsFullyCastable() then	
					local jumps = thisEntity.trample:GetSpecialValueFor("jumps")
					if thisEntity:GetHealthPercent() < 66 then jumps = jumps + 1 end
					if thisEntity:GetHealthPercent() < 33 then jumps = jumps + 1 end
					local jumpDistance = thisEntity.trample:GetSpecialValueFor("jump_distance") * jumps
					if CalculateDistance( thisEntity, target ) < jumpDistance then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
							Position = target:GetAbsOrigin(),
							AbilityIndex = thisEntity.trample:entindex()
						})
						return (thisEntity.trample:GetCastPoint() * jumps) + 1
					elseif AICore:NumEnemiesInLine(thisEntity, jumpDistance, thisEntity.trample:GetSpecialValueFor("starting_radius"), false) > 2 then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
							Position = caster:GetAbsOrigin() + caster:GetForwardVector() * 200,
							AbilityIndex = thisEntity.trample:entindex()
						})
						return (thisEntity.trample:GetCastPoint() * jumps) + 1
					end
				end
				if thisEntity.swipe:IsFullyCastable() and CalculateDistance(thisEntity, target) <= thisEntity:GetAttackRange() + thisEntity:GetIdealSpeed() then
					ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
							Position = target:GetAbsOrigin(),
							AbilityIndex = thisEntity.swipe:entindex()
						})
					return thisEntity.swipe:GetCastPoint() + 0.1
				end
			end
			AICore:AttackHighestPriority( thisEntity )
			return AI_THINK_RATE
		end
		return AI_THINK_RATE
	end
end