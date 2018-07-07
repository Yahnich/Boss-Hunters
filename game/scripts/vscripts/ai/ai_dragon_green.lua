--[[
Green Dragon
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
		thisEntity.toxic_pool = thisEntity:FindAbilityByName("green_dragon_toxic_pool")
		thisEntity.toxic_pool:SetLevel(1)

		thisEntity.rot = thisEntity:FindAbilityByName("green_dragon_rot")
		thisEntity.rot:SetLevel(1)

		thisEntity.armor = thisEntity:FindAbilityByName("green_dragon_etheral_armor")
		thisEntity.armor:SetLevel(1)

		thisEntity.volatile_rot = thisEntity:FindAbilityByName("green_dragon_volatile_rot")
		thisEntity.volatile_rot:SetLevel(1)
	end


	function AIThink(thisEntity)
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
			local target = AICore:GetHighestPriorityTarget(thisEntity)
			if target then
				if thisEntity.toxic_pool:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = target:GetAbsOrigin(),
						AbilityIndex = thisEntity.toxic_pool:entindex()
					})
					return thisEntity.toxic_pool:GetCastPoint() + 0.1
				end
			end
			AICore:AttackHighestPriority( thisEntity )
			return 0.25
		else return 0.25 end
	end
end