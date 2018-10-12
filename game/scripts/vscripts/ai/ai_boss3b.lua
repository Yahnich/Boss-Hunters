--[[
Broodking AI
]]

require( "ai/ai_core" )
if IsServer() then
	function Spawn( entityKeyValues )
		AITimers:CreateTimer(function()
			if thisEntity and not thisEntity:IsNull() then
				return AIThink(thisEntity)
			end
		end)
		thisEntity.spit = thisEntity:FindAbilityByName("boss3b_acid_spit")
		thisEntity.passive = thisEntity:FindAbilityByName("boss3b_acid_interior")
		AITimers:CreateTimer(function()
			if  math.floor(GameRules.gameDifficulty + 0.5) <= 2 then 
				thisEntity.spit:SetLevel(1)
				thisEntity.passive:SetLevel(1)
			else
				thisEntity.spit:SetLevel(2)
				thisEntity.passive:SetLevel(2)
			end
		end)
	end


	function AIThink(thisEntity)
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
			local target = AICore:GetHighestPriorityTarget(thisEntity)
			if target and thisEntity:GetHealthPercent() > 25 then 
				if thisEntity.spit:IsFullyCastable() then
					if not target:HasModifier("modifier_boss3b_acid_spit") then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
							Position = target:GetAbsOrigin(),
							AbilityIndex = thisEntity.spit:entindex()
						})
						return thisEntity.spit:GetCastPoint() + 0.1
					else
						local castRadius = thisEntity.spit:GetTrueCastRange() + thisEntity:GetIdealSpeed()
						local searchRadius = thisEntity.spit:GetSpecialValueFor("radius") + castRadius
						local potentialEnemies = thisEntity:FindEnemyUnitsInRadius(thisEntity:GetAbsOrigin(), searchRadius)
						local newTarget 
						for _, potTarget in ipairs(potentialEnemies) do
							if not potTarget:HasModifier("modifier_boss3b_acid_spit") then 
								newTarget = potTarget
								break
							end
						end
						if newTarget then
							ExecuteOrderFromTable({
								UnitIndex = thisEntity:entindex(),
								OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
								Position = newTarget:GetAbsOrigin(),
								AbilityIndex = thisEntity.spit:entindex()
							})
							return thisEntity.spit:GetCastPoint() + 0.1
						end
					end
				end
			else
				target = AICore:NearestEnemyHeroInRange( thisEntity, 15000 , true )
				AICore:RunToTarget( thisEntity, target )
				return AI_THINK_RATE
			end
			return AICore:AttackHighestPriority( thisEntity )
		else return AI_THINK_RATE end
	end
end