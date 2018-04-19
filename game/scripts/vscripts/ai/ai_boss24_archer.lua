--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	Timers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.walk = thisEntity:FindAbilityByName("boss_wind_walk")
	thisEntity.focus = thisEntity:FindAbilityByName("boss_focusfire")
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		local range = thisEntity.focus:GetCastRange()
		local target = AICore:HighestThreatHeroInRange(thisEntity, range, 10, true)
		if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity, range, true ) end
		if thisEntity:GetHealth() < thisEntity:GetMaxHealth()*0.3 then
			if not thisEntity:HasModifier("modifier_clinkz_wind_walk") and thisEntity.walk:IsFullyCastable() and not thisEntity.override then
				print("check1")
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.walk:entindex()
				})
				AICore:BeAHugeCoward( thisEntity, 500)
			elseif thisEntity:HasModifier("modifier_clinkz_wind_walk") and thisEntity.walk:IsFullyCastable() and thisEntity.focus:IsFullyCastable() and thisEntity.currHP == nil then
				if target then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
						TargetIndex = target:entindex(),
						AbilityIndex = thisEntity.focus:entindex()
					})
					thisEntity.override = true
					thisEntity.currHP = thisEntity:GetHealth()
				end
			elseif thisEntity.currHP and thisEntity.currHP > thisEntity:GetHealth() and thisEntity.walk:IsFullyCastable() then
				thisEntity.currHP = nil
				override = false
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.walk:entindex()
				})
				AICore:BeAHugeCoward( thisEntity, 500)
			elseif (thisEntity.currHP and thisEntity.currHP <= thisEntity:GetHealth()) or not thisEntity.walk:IsFullyCastable() and not thisEntity:HasModifier("modifier_clinkz_wind_walk") then
				AICore:AttackHighestPriority( thisEntity )
			else 
				AICore:BeAHugeCoward( thisEntity, 300)
			end		
			return 1
		else
			if target and thisEntity.focus:IsFullyCastable() and not thisEntity:HasModifier("modifier_clinkz_wind_walk") then
				ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
						TargetIndex = target:entindex(),
						AbilityIndex = thisEntity.focus:entindex()
					})
				return 0.25
			end
			AICore:AttackHighestPriority( thisEntity )
		return 0.25
		end
	else return 0.25 end
end