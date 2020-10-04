if IsClient() then return end

require( "ai/ai_core" )

-- GENERIC AI FOR SIMPLE CHASE ATTACKERS

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
end


function AIThink(thisEntity)
	if thisEntity and not thisEntity:IsNull() and thisEntity:IsAlive() then
		if not thisEntity:IsDominated() then
			local skeletonBlastUnit
			local nearestUnit
			if thisEntity:GetOwner() and thisEntity:GetOwner():IsReincarnating() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
					Position = thisEntity:GetOwner():GetAbsOrigin() + RandomVector(150)
				})
				return CalculateDistance(thisEntity:GetOwner(), thisEntity) / (thisEntity:GetIdealSpeed() * 0.5)
			end
			for _, enemy in ipairs( thisEntity:FindEnemyUnitsInRadius( thisEntity:GetAbsOrigin(), -1, {order = FIND_CLOSEST, flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE}) ) do
				if enemy:HasModifier("modifier_wk_blast") then
					skeletonBlastUnit = enemy
					break
				elseif not nearestUnit then
					nearestUnit = enemy
				end
			end
			if skeletonBlastUnit then
				thisEntity:MoveToTargetToAttack( skeletonBlastUnit )
				return AI_THINK_RATE
			elseif nearestUnit then
				thisEntity:MoveToTargetToAttack( nearestUnit )
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = nearestUnit:entindex()
				})
				return AI_THINK_RATE
			else
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
					Position = thisEntity:GetAbsOrigin() + thisEntity:GetForwardVector() * thisEntity:GetAttackRange() * 2 + RandomVector( thisEntity:GetIdealSpeed() / 2 )
				})
				return AI_THINK_RATE
			end
			return AI_THINK_RATE
		else return 1 end
	end
end