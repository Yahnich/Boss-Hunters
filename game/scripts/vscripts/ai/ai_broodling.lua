--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	
	thisEntity.spawn = thisEntity:FindAbilityByName("boss_broodling_spawn_spiderling")
	thisEntity.spawn:StartCooldown(10)

	AITimers:CreateTimer(0.1, function()
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
			thisEntity.spawn:SetLevel(1)
		else
			thisEntity.spawn:SetLevel(2)
		end
	end)
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		if thisEntity.spawn:IsFullyCastable() and AICore:SpecificAlliedUnitsAlive( thisEntity, "npc_dota_creature_spiderling", -1 ) < 15 then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.spawn:entindex()
			})
			return thisEntity.spawn:GetCastPoint() + 0.1
		end
		if AICore:TotalAlliedUnitsInRange( thisEntity, 1200 ) > math.ceil(4 * (thisEntity:GetHealthPercent()/100)) then
			AICore:AttackHighestPriority( thisEntity )
			return AI_THINK_RATE
		else
			AICore:BeAHugeCoward( thisEntity, 800 )
			return AI_THINK_RATE
		end
		return AI_THINK_RATE
	else
		return AI_THINK_RATE
	end
end