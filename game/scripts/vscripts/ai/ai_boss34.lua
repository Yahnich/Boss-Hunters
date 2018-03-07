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
	thisEntity.orb = thisEntity:FindAbilityByName("boss_death_orb")
	thisEntity.death = thisEntity:FindAbilityByName("boss_death_time")
	thisEntity.blink = thisEntity:FindAbilityByName("boss_blink_on_far")
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		local radius = 800
		if AICore:TotalEnemyHeroesInRange( thisEntity, radius ) >= 1 and thisEntity.orb:IsFullyCastable() then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.orb:entindex()
			})
			return 3
		elseif AICore:TotalEnemyHeroesInRange( thisEntity, radius ) >= 1 and thisEntity.death:IsFullyCastable() then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.death:entindex()
			})
			return 6
		elseif thisEntity.blink:IsFullyCastable() then
			local target = AICore:WeakestEnemyHeroInRange( thisEntity, thisEntity.blink:GetCastRange(), true)
			if target then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
					TargetIndex = target:entindex(),
					AbilityIndex = thisEntity.blink:entindex()
				})
				return 1
			end
		else
			AICore:AttackHighestPriority( thisEntity )
			return 0.25
		end
		return 0.25
	else
		return 0.25
	end
end