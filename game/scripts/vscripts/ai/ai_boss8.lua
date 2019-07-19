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
	thisEntity.spear = thisEntity:FindAbilityByName("boss_clockwerk_spear")
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		local radius = thisEntity.spear:GetTrueCastRange()
		local target = AICore:HighestThreatHeroInRange(thisEntity, radius, 0, false)
		if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity, radius, false) end
		if not target then target = AICore:NearestEnemyHeroInRange( thisEntity, radius, false) end
		if target and thisEntity.spear:IsFullyCastable() then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				Position = target:GetOrigin(),
				AbilityIndex = thisEntity.spear:entindex()
			})
			return AI_THINK_RATE
		end
		return AICore:AttackHighestPriority( thisEntity )
	else return AI_THINK_RATE end
end