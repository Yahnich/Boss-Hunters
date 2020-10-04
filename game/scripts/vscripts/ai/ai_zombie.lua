if IsClient() then return end

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.berserk = thisEntity:FindAbilityByName("boss3a_berserk")
end


function AIThink(thisEntity)
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
		return AICore:AttackHighestPriority( thisEntity )
	else return 0.25 end
end