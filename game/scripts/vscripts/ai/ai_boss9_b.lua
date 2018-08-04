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
	thisEntity.summon = thisEntity:FindAbilityByName("creature_summon_slither")
	thisEntity.crush = thisEntity:FindAbilityByName("creature_slithereen_crush")
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		local radius = thisEntity.crush:GetSpecialValueFor("crush_radius")
		if AICore:TotalNotDisabledEnemyHeroesInRange( thisEntity, radius ) > math.floor(AICore:TotalEnemyHeroesInRange( thisEntity, radius )/2) 
		and thisEntity.crush:IsFullyCastable()
		and AICore:TotalEnemyHeroesInRange( thisEntity, radius ) ~= 0  then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.crush:entindex()
			})
			return AI_THINK_RATE
		end
		return AICore:AttackHighestPriority( thisEntity )
	else return AI_THINK_RATE end
end