--[[
Broodking AI
]]
TECHIES_BEHAVIOR_SEEK_AND_DESTROY = 1
TECHIES_BEHAVIOR_ROAM_AND_MINE = 2
require( "ai/ai_core" )

function Spawn( entityKeyValues )
	Timers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.spawn = thisEntity:FindAbilityByName("boss_spawn_techies")
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		if thisEntity:IsChanneling() then return AI_THINK_RATE end
		if not thisEntity.spawn:IsCooldownReady() then return AI_THINK_RATE end
		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
			AbilityIndex = thisEntity.spawn:entindex()
		})
		return AI_THINK_RATE
	else return AI_THINK_RATE end
end