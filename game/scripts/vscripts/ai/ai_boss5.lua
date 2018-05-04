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
	thisEntity.moment = thisEntity:FindAbilityByName("boss_moment_of_courage")
	thisEntity.odds = thisEntity:FindAbilityByName("boss_overwhelming_odds")
	thisEntity.press = thisEntity:FindAbilityByName("boss_press_the_attack")
	thisEntity.call = thisEntity:FindAbilityByName("boss_call_reinforcements")
	if  math.floor(GameRules.gameDifficulty + 0.5) > 3 then
		thisEntity.moment:SetLevel(4)
		thisEntity.press:SetLevel(4)
		thisEntity.odds:SetLevel(4)
	elseif  math.floor(GameRules.gameDifficulty + 0.5) == 3 then
		thisEntity.moment:SetLevel(3)
		thisEntity.press:SetLevel(3)
		thisEntity.odds:SetLevel(3)
	elseif  math.floor(GameRules.gameDifficulty + 0.5) == 2 then
		thisEntity.moment:SetLevel(2)
		thisEntity.press:SetLevel(2)
		thisEntity.odds:SetLevel(2)
	else
		thisEntity.moment:SetLevel(1)
		thisEntity.press:SetLevel(1)
		thisEntity.odds:SetLevel(1)
	end
	thisEntity:SetHealth(thisEntity:GetMaxHealth())
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		if thisEntity.odds:IsFullyCastable() then
			local radius = thisEntity.odds:GetSpecialValueFor("radius")
			local range = thisEntity.odds:GetCastRange() + radius
			if AICore:TotalEnemyHeroesInRange( thisEntity, radius ) ~= 0 then
				local position = AICore:OptimalHitPosition(thisEntity, range, radius)
				if position and RollPercentage(25) then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = position,
						AbilityIndex = thisEntity.odds:entindex()
					})
					return AI_THINK_RATE
				end
			end
		end
		if thisEntity.press:IsFullyCastable() then
			local hpregen = thisEntity.press:GetSpecialValueFor("hp_regen") *  thisEntity.press:GetSpecialValueFor("duration")
			if (thisEntity:IsAttacking() or thisEntity:GetHealthDeficit() > hpregen) and RollPercentage(8) then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
					TargetIndex = thisEntity:entindex(),
					AbilityIndex = thisEntity.press:entindex()
				})
				return AI_THINK_RATE
			elseif AICore:TotalAlliedUnitsInRange( thisEntity, thisEntity.press:GetCastRange() ) then
				local ally = AICore:WeakestAlliedUnitInRange( thisEntity, thisEntity.press:GetCastRange() , false)
				if ally and ally:GetHealthDeficit() > hpregen and RollPercentage(8) then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
						TargetIndex = ally:entindex(),
						AbilityIndex = thisEntity.press:entindex()
					})
					return AI_THINK_RATE
				end
			end
		end
		if thisEntity.call:IsFullyCastable() and AICore:SpecificAlliedUnitsAlive( thisEntity, "npc_dota_boss5b" ) < 6 then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.call:entindex()
			})
			return thisEntity.call:GetChannelTime()
		end
		AICore:AttackHighestPriority( thisEntity )
		return AI_THINK_RATE
	else return AI_THINK_RATE end
end