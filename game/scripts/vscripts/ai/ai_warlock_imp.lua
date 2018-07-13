--[[
Warlock Imp
]]

if IsServer() then
	require( "ai/ai_core" )
	function Spawn( entityKeyValues )
		AITimers:CreateTimer(function()
			if thisEntity and not thisEntity:IsNull() then
				return AIThink(thisEntity)
			end
		end)
		thisEntity:SetContextThink( "AIThinker", AIThink, 0.25 )

		thisEntity.bolt = thisEntity:FindAbilityByName("warlock_imp_bolt")
		thisEntity.bolt:SetLevel(1)
	end

	function AIThink(thisEntity)
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
			local target
			if thisEntity:GetOwnerEntity() and thisEntity:GetOwnerEntity():GetAttackTarget() then
				target = thisEntity:GetOwnerEntity():GetAttackTarget()
			else
				target = AICore:GetHighestPriorityTarget(thisEntity)
			end
			if target then
				if thisEntity.bolt:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_TARGET ,
						TargetIndex  = target:entindex(),
						AbilityIndex = thisEntity.bolt:entindex()
					})
					return thisEntity.bolt:GetCastPoint() + 0.1
				end
			else
				thisEntity:MoveToNPC(thisEntity:GetOwner())
			end
			AICore:AttackHighestPriority( thisEntity )
			return 0.25
		else return 0.25 end
	end
end