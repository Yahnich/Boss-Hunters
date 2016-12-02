--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 1 )
	thisEntity.berserk = thisEntity:FindAbilityByName("creature_zombie_berserk")
end


function AIThink()
	if not thisEntity:IsDominated() then
		local radius = thisEntity:GetAttackRange()+thisEntity:GetAttackRangeBuffer()
		local target = AICore:HighestThreatHeroInRange(thisEntity, radius, 0, true)
		if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity, radius, true) end
		if not target then target = AICore:NearestEnemyHeroInRange( thisEntity, 8000, true) end
		if target then
			if (target:GetOrigin() - thisEntity:GetOrigin()):Length2D() > 500 and thisEntity.berserk:IsFullyCastable() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.berserk:entindex()
				})
				return 0.25
			end
		end
		if thisEntity:IsAttacking() and thisEntity.berserk:IsFullyCastable() then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.berserk:entindex()
			})
			return 0.25
		end
		AICore:AttackHighestPriority( thisEntity )
		return 0.25
	else return 0.25 end
end