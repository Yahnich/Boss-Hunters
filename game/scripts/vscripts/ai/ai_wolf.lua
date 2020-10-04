if IsClient() then return end

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.leap = thisEntity:FindAbilityByName("boss_wolves_leap")
	thisEntity.cripple = thisEntity:FindAbilityByName("boss_wolves_critical")
	
	AITimers:CreateTimer(0.1, 	function()
									thisEntity.leap:SetLevel(1)
									thisEntity.cripple:SetLevel(1)
								end)
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local target = AICore:GetHighestPriorityTarget(thisEntity)
		if thisEntity.leap:IsFullyCastable() and target and CalculateDistance( target, thisEntity ) > thisEntity:GetAttackRange() then
			return CastLeap( target:GetAbsOrigin() )
		end
		return AICore:AttackHighestPriority( thisEntity )
	else 
		return AI_THINK_RATE 
	end
end

function CastLeap(position)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.leap:entindex()
	})
	return thisEntity.leap:GetCastPoint() + 0.1
end