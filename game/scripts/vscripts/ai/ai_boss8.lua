--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 1 )
	thisEntity.spear = thisEntity:FindAbilityByName("boss_spear")
end


function AIThink()
	if not thisEntity:IsDominated() then
		local radius = thisEntity.spear:GetCastRange()
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
			return 0.25
		end
		AICore:AttackHighestPriority( thisEntity )
		return 0.25
	else return 0.25 end
end