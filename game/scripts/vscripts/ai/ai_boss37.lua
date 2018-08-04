--[[
Broodking AI
]]

require( "ai/ai_core" )

AI_STATE_COWARD = 1
AI_STATE_AGGRESSIVE = 2
AI_STATE_EGGS = 3

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.fate = thisEntity:FindAbilityByName("boss_broodmother_clipped_fate")
	thisEntity.injection = thisEntity:FindAbilityByName("boss_broodmother_parasitic_injection")
	thisEntity.brood = thisEntity:FindAbilityByName("boss_broodmother_strength_of_the_brood")
	
	thisEntity.egg = thisEntity:FindAbilityByName("boss_broodmother_egg_sack")
	thisEntity.infest = thisEntity:FindAbilityByName("boss_broodmother_infest")
	thisEntity.hunger = thisEntity:FindAbilityByName("boss_broodmother_arachnids_hunger")
	thisEntity.web = thisEntity:FindAbilityByName("boss_broodmother_fates_web")
	thisEntity.shot = thisEntity:FindAbilityByName("boss_broodmother_web_shot")

	AITimers:CreateTimer(0.1, function()
			if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
				thisEntity.fate:SetLevel(1)
				thisEntity.injection:SetLevel(1)
				thisEntity.brood:SetLevel(1)
				thisEntity.hunger:SetLevel(1)
				thisEntity.shot:SetLevel(1)
			else
				thisEntity.fate:SetLevel(2)
				thisEntity.injection:SetLevel(2)
				thisEntity.brood:SetLevel(2)
				thisEntity.hunger:SetLevel(2)
				thisEntity.shot:SetLevel(2)
			end
		end)
	thisEntity.getAIState = AI_STATE_AGGRESSIVE
end

function AIThink(thisEntity)
	thisEntity.getLastCheckedHealth = thisEntity.getLastCheckedHealth or thisEntity:GetHealth()
	if not thisEntity:IsDominated() then
		local target = AICore:GetHighestPriorityTarget(thisEntity)
		if thisEntity.getLastCheckedHealth - thisEntity:GetHealth() < thisEntity:GetHealth() * 0.15 and thisEntity.getAIState ~= AI_STATE_COWARD then
			thisEntity.getAIState = AI_STATE_COWARD
			thisEntity.getLastCheckedHealth = thisEntity:GetHealth()
		elseif thisEntity.getLastCheckedHealth > thisEntity:GetHealth() + thisEntity:GetHealthRegen() and thisEntity.getAIState ~= AI_STATE_AGGRESSIVE then
			thisEntity.getAIState = AI_STATE_AGGRESSIVE
		end
		if target then
			local distance = CalculateDistance( thisEntity, target )
			if thisEntity.getAIState == AI_STATE_AGGRESSIVE then
				if thisEntity:GetHealthPercent() > 50 then
					if thisEntity.shot:IsFullyCastable() then
						if distance > thisEntity:GetAttackRange() + thisEntity:GetIdealSpeed() and distance < thisEntity.shot:GetTrueCastRange() then
							return CastShot( thisEntity, target:GetAbsOrigin() )
						elseif distance > thisEntity.shot:GetTrueCastRange() then
							target = AICore:NearestEnemyHeroInRange( thisEntity, thisEntity.shot:GetTrueCastRange(), false)
							if target then return CastShot(thisEntity, target:GetAbsOrigin() ) end
						end
					end
					if thisEntity.hunger:IsFullyCastable() then
						if thisEntity:IsAttacking() or thisEntity:IsDisarmed() then
							return CastHunger(thisEntity)
						end
					end
					if thisEntity.egg:IsFullyCastable() and AICore:SpecificAlliedUnitsAlive( thisEntity, "npc_dota_creature_broodmother", -1 ) < 4 then return CastEggSack(thisEntity, thisEntity:GetAbsOrigin() + RandomVector(thisEntity.egg:GetTrueCastRange()) ) end
					if thisEntity.infest:IsFullyCastable() then
						if distance < thisEntity.infest:GetTrueCastRange() then
							CastInfest( thisEntity, target:GetAbsOrigin() )
						else
							target = AICore:RandomEnemyHeroInRange( thisEntity, thisEntity.shot:GetTrueCastRange(), false)
							if target then return CastInfest(thisEntity, target:GetAbsOrigin() ) end
						end
					end
					if thisEntity.web:IsFullyCastable() then
						if target:IsAtAngleWithEntity(thisEntity, 105) then -- running away
							return CastWeb( thisEntity, thisEntity:GetAbsOrigin() + CalculateDirection(target, thisEntity) * thisEntity.web:GetTrueCastRange() )
						end
					end
				elseif thisEntity:GetHealthPercent() > 25 then
					if thisEntity.hunger:IsFullyCastable() then
						if thisEntity:IsAttacking() or thisEntity:IsDisarmed() then
							return CastHunger(thisEntity)
						end
					end
					if AICore:BeingAttacked( thisEntity ) > 2 then
						thisEntity.getAIState = AI_STATE_COWARD
						if thisEntity.web:IsFullyCastable() then
							return CastWeb( thisEntity, thisEntity:GetAbsOrigin() - thisEntity:GetForwardVector() * thisEntity.web:GetTrueCastRange() )
						end
						return AI_THINK_RATE
					end
					if thisEntity.infest:IsFullyCastable() then
						if distance < thisEntity.infest:GetTrueCastRange() then
							CastInfest( thisEntity, target:GetAbsOrigin() )
						else
							target = AICore:RandomEnemyHeroInRange( thisEntity, thisEntity.shot:GetTrueCastRange(), false)
							if target then return CastInfest(thisEntity, target:GetAbsOrigin() ) end
						end
					end
					if thisEntity.egg:IsFullyCastable() and AICore:SpecificAlliedUnitsAlive( thisEntity, "npc_dota_creature_broodmother", -1 ) < 4 then return CastEggSack(thisEntity, thisEntity:GetAbsOrigin() + RandomVector(thisEntity.egg:GetTrueCastRange()) ) end
					if thisEntity.shot:IsFullyCastable() and AICore:TotalEnemyHeroesInRange( thisEntity, thisEntity.shot:GetTrueCastRange()) < 3 then
						if distance > thisEntity:GetAttackRange() + thisEntity:GetIdealSpeed() and distance < thisEntity.shot:GetTrueCastRange() then
							return CastShot( thisEntity, target:GetAbsOrigin() )
						elseif distance > thisEntity.shot:GetTrueCastRange() then
							target = AICore:NearestEnemyHeroInRange( thisEntity, thisEntity.shot:GetTrueCastRange(), false)
							if target then return CastShot(thisEntity, target:GetAbsOrigin() ) end
						end
					end
					if thisEntity.web:IsFullyCastable() then
						if target:IsMoving() then -- running away
							return CastWeb( thisEntity, thisEntity:GetAbsOrigin() + CalculateDirection(target, thisEntity) * thisEntity.web:GetTrueCastRange() )
						end
					end
				else
					if AICore:BeingAttacked( thisEntity ) > 1 or (thisEntity:IsDisarmed() and not thisEntity.hunger:IsFullyCastable()) or thisEntity:IsSilenced() then
						thisEntity.getAIState = AI_STATE_COWARD
						return AI_THINK_RATE
					end
					if thisEntity.hunger:IsFullyCastable() then
						if thisEntity:IsAttacking() or (thisEntity:IsDisarmed() and distance < thisEntity:GetAttackRange()) then
							return CastHunger(thisEntity)
						end
					end
					if thisEntity.shot:IsFullyCastable() and AICore:TotalEnemyHeroesInRange( thisEntity, thisEntity.shot:GetTrueCastRange()) < 2 then
						if distance > thisEntity:GetAttackRange() + thisEntity:GetIdealSpeed() and distance < thisEntity.shot:GetTrueCastRange() then
							return CastShot( thisEntity, target:GetAbsOrigin() )
						elseif distance > thisEntity.shot:GetTrueCastRange() then
							target = AICore:NearestEnemyHeroInRange( thisEntity, thisEntity.shot:GetTrueCastRange(), false)
							if target then return CastShot(thisEntity, target:GetAbsOrigin() ) end
						end
					end
					if thisEntity.infest:IsFullyCastable() then
						if distance < thisEntity.infest:GetTrueCastRange() then
							CastInfest( thisEntity, target:GetAbsOrigin() )
						else
							target = AICore:RandomEnemyHeroInRange( thisEntity, thisEntity.shot:GetTrueCastRange(), false)
							if target then return CastInfest(thisEntity, target:GetAbsOrigin() ) end
						end
					end
					if thisEntity.web:IsFullyCastable() then
						if target:IsMoving() then -- running away
							return CastWeb( thisEntity, thisEntity:GetAbsOrigin() + CalculateDirection(target, thisEntity) * thisEntity.web:GetTrueCastRange() )
						end
					end
					if thisEntity.egg:IsFullyCastable() and AICore:SpecificAlliedUnitsAlive( thisEntity, "npc_dota_creature_broodmother", -1 ) < 4 then return CastEggSack(thisEntity, thisEntity:GetAbsOrigin() + RandomVector(thisEntity.egg:GetTrueCastRange()) ) end
				end
				return AICore:AttackHighestPriority( thisEntity )
			elseif thisEntity.getAIState == AI_STATE_COWARD then
				local runPosition = AICore:BeAHugeCoward( thisEntity, 800 )
				if not runPosition then thisEntity:GetAbsOrigin() end
				if thisEntity.web:IsFullyCastable() and GridNav:FindPathLength(thisEntity:GetAbsOrigin(), runPosition) > CalculateDistance( runPosition, thisEntity ) + 200 then
					return CastWeb(thisEntity, thisEntity:GetAbsOrigin() + CalculateDirection( runPosition, thisEntity ) * thisEntity.web:GetTrueCastRange())
				end
				if thisEntity.hunger:IsFullyCastable() and distance < thisEntity:GetAttackRange() then
					thisEntity.getAIState = AI_STATE_AGGRESSIVE
				end
				if AICore:BeingAttacked( thisEntity ) < 2 then 
					if thisEntity.egg:IsFullyCastable() and AICore:SpecificAlliedUnitsAlive( thisEntity, "npc_dota_creature_broodmother", -1 ) < 4 then 
						return CastEggSack(thisEntity, thisEntity:GetAbsOrigin() + RandomVector(thisEntity.egg:GetTrueCastRange()) ) 
					end
					if thisEntity.shot:IsFullyCastable() and AICore:TotalEnemyHeroesInRange( thisEntity, thisEntity.shot:GetTrueCastRange()) < 2 then
						if distance > thisEntity:GetAttackRange() + thisEntity:GetIdealSpeed() and distance < thisEntity.shot:GetTrueCastRange() then
							thisEntity.getAIState = AI_STATE_AGGRESSIVE
							thisEntity.getLastCheckedHealth = thisEntity:GetHealth()
							return CastShot( thisEntity, target:GetAbsOrigin() )
						elseif distance > thisEntity.shot:GetTrueCastRange() then
							target = AICore:NearestEnemyHeroInRange( thisEntity, thisEntity.shot:GetTrueCastRange(), false)
							if target then 
								thisEntity.getAIState = AI_STATE_AGGRESSIVE
								thisEntity.getLastCheckedHealth = thisEntity:GetHealth()
								return CastShot(thisEntity, target:GetAbsOrigin() )
							end
						end
					end
					if thisEntity.infest:IsFullyCastable() then
						if distance < thisEntity.infest:GetTrueCastRange() then
							CastInfest( thisEntity, target:GetAbsOrigin() )
						else
							target = AICore:RandomEnemyHeroInRange( thisEntity, thisEntity.shot:GetTrueCastRange(), false)
							if target then return CastInfest(thisEntity, target:GetAbsOrigin() ) end
						end
					end
				end
			end
		end
		return AI_THINK_RATE
	else
		return AI_THINK_RATE
	end
end


function CastWeb(thisEntity, position)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.web:entindex()
	})
	return thisEntity.web:GetCastPoint() + 0.1
end

function CastHunger(thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.hunger:entindex()
	})
	return thisEntity.hunger:GetCastPoint() + 0.1
end

function CastShot(thisEntity, position)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.shot:entindex()
	})
	return thisEntity.shot:GetCastPoint() + 0.1
end

function CastEggSack(thisEntity, position)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.egg:entindex()
	})
	return thisEntity.egg:GetCastPoint() + 0.1
end

function CastInfest(thisEntity, position)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.infest:entindex()
	})
	return thisEntity.infest:GetCastPoint() + 0.1
end