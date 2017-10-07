--[[
Broodking AI
]]

require( "ai/ai_core" )
if IsServer() then
	function Spawn( entityKeyValues )
		thisEntity:SetContextThink( "AIThinker", AIThink, 1 )
		thisEntity.spit = thisEntity:FindAbilityByName("boss3b_acid_spit")
		thisEntity.passive = thisEntity:FindAbilityByName("boss3b_acid_interior")
		Timers:CreateTimer(function()
			if  math.floor(GameRules.gameDifficulty + 0.5) <= 2 then 
				thisEntity.spit:SetLevel(1)
				thisEntity.passive:SetLevel(1)
			else
				thisEntity.spit:SetLevel(2)
				thisEntity.passive:SetLevel(2)
				
				thisEntity:SetBaseMaxHealth(thisEntity:GetMaxHealth()*1.5)
				thisEntity:SetMaxHealth(thisEntity:GetMaxHealth()*1.5)
				thisEntity:SetHealth(thisEntity:GetMaxHealth())
			end
		end)
	end


	function AIThink()
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
			local target = AICore:GetHighestPriorityTarget(thisEntity)
			if target and thisEntity.spit:IsFullyCastable() then
				if not target:HasModifier("modifier_boss3b_acid_spit") then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = target:GetAbsOrigin(),
						AbilityIndex = thisEntity.spit:entindex()
					})
					return thisEntity.spit:GetCastPoint() + 0.1
				else
					local castRadius = thisEntity.spit:GetTrueCastRange() + self:GetIdealSpeed()
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
			else
				target = AICore:NearestEnemyHeroInRange( thisEntity, 15000 , true )
				AICore:RunToTarget( thisEntity, target )
			end
			AICore:AttackHighestPriority( thisEntity )
			return 0.25
		else return 0.25 end
	end
end