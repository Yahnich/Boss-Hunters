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
	thisEntity.fire = thisEntity:FindAbilityByName("boss_melee_fire_orb_vh")
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		local radius = thisEntity.fire:GetCastRange()/2
		if AICore:TotalEnemyHeroesInRange( thisEntity, radius ) >= 1 and thisEntity.fire:IsFullyCastable() then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				Position = thisEntity:GetOrigin(),
				AbilityIndex = thisEntity.fire:entindex()
			})
			return AI_THINK_RATE
		end
		return AICore:AttackHighestPriority( thisEntity )
	else
		return AI_THINK_RATE
	end
end