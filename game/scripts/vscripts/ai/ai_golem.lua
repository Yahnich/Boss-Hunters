--[[
Broodking AI
]]
function Spawn( entityKeyValues )
	Timers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.split = thisEntity:FindAbilityByName("boss_golem_split")
	thisEntity.mass = thisEntity:FindAbilityByName("boss_golem_cracked_mass")

	thisEntity.toss = thisEntity:FindAbilityByName("boss_golem_golem_toss")
	thisEntity.leap = thisEntity:FindAbilityByName("boss_golem_golem_leap")
	thisEntity.smash = thisEntity:FindAbilityByName("boss_golem_golem_smash")
	
	Timers:CreateTimer(0.1, function()
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
			thisEntity.split:SetLevel(1)
			thisEntity.mass:SetLevel(1)
			
			thisEntity.toss:SetLevel(1)
			thisEntity.leap:SetLevel(1)
			thisEntity.smash:SetLevel(1)
		else
			thisEntity.split:SetLevel(2)
			thisEntity.mass:SetLevel(2)
			
			thisEntity.toss:SetLevel(2)
			thisEntity.leap:SetLevel(2)
			thisEntity.smash:SetLevel(2)
		end
	end)
end


function AIThink(thisEntity)
	if thisEntity and not thisEntity:IsNull() then
		if not thisEntity:IsDominated() then
			local target = AICore:GetHighestPriorityTarget( thisEntity )
			if thisEntity.smash:IsFullyCastable() and AICore:TotalEnemyHeroesInRange( thisEntity, thisEntity.smash:GetTrueCastRange()) >= 1 then
				return Smash()
			end
			if thisEntity.leap:IsFullyCastable() then
				if CalculateDistance(target, thisEntity) > thisEntity:GetAttackRange() then
					if CalculateDistance(target, thisEntity) > thisEntity.leap:GetTrueCastRange() then
						if RollPercentage(50) then
							return Leap( thisEntity:GetAbsOrigin() + CalculateDirection(target, thisEntity) * thisEntity.leap:GetTrueCastRange() )
						else
							local nearest = AICore:NearestEnemyHeroInRange( thisEntity, thisEntity.leap:GetTrueCastRange() , true )
							if nearest then
								return Leap( nearest:GetAbsOrigin() )
							end
						end
					end
				elseif RollPercentage(50) then
					local weakest = AICore:WeakestEnemyHeroInRange( thisEntity, thisEntity.leap:GetTrueCastRange() , true )
					if weakest then
						return Leap( weakest:GetAbsOrigin() )
					end
					local nearest = AICore:NearestEnemyHeroInRange( thisEntity, thisEntity.leap:GetTrueCastRange() , true )
					if nearest then
						return Leap( nearest:GetAbsOrigin() )
					end
				end
			end
			if thisEntity.toss:IsFullyCastable() then
				local tossTarget = target
				if RollPercentage(33) then
					local tossTarget = AICore:MostDamageEnemyHeroInRange( thisEntity, -1, true)
				elseif RollPercentage(33) then
					local tossTarget = AICore:WeakestEnemyHeroInRange( thisEntity, -1, true)
				elseif RollPercentage(33) then
					local tossTarget = AICore:NearestEnemyHeroInRange( thisEntity, -1, true)
				end
				if CalculateDistance( tossTarget, thisEntity ) > thisEntity.toss:GetTrueCastRange() then
					return TossGolem( thisEntity:GetAbsOrigin() + CalculateDirection(tossTarget, thisEntity) * thisEntity.toss:GetTrueCastRange())
				else
					return TossGolem( tossTarget:GetAbsOrigin() )
				end
			end
			AICore:AttackHighestPriority( thisEntity )
			return 0.25
		else return 0.25 end
	end
end

function TossGolem(position)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.toss:entindex()
	})
	return thisEntity.toss:GetCastPoint() + 0.1
end

function Leap(position)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.leap:entindex()
	})
	return thisEntity.leap:GetCastPoint() + 0.1
end

function Smash()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.smash:entindex()
	})
	return thisEntity.smash:GetCastPoint() + 0.1
end