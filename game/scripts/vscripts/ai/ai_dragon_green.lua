--[[
Green Dragon
]]

if IsServer() then
	function Spawn( entityKeyValues )
		AITimers:CreateTimer(function()
			if thisEntity and not thisEntity:IsNull() then
				return AIThink(thisEntity)
			end
		end)
		thisEntity:SetContextThink( "AIThinker", AIThink, AI_THINK_RATE )
		thisEntity.toxic_pool = thisEntity:FindAbilityByName("green_dragon_toxic_pool")
		thisEntity.rot = thisEntity:FindAbilityByName("green_dragon_rot")
		thisEntity.armor = thisEntity:FindAbilityByName("green_dragon_etheral_armor")
		thisEntity.volatile_rot = thisEntity:FindAbilityByName("green_dragon_volatile_rot")
		
		
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then
			thisEntity.toxic_pool:SetLevel(1)
			thisEntity.armor:SetLevel(1)
			thisEntity.volatile_rot:SetLevel(1)
			thisEntity.rot:SetLevel(1)
		else
			thisEntity.toxic_pool:SetLevel(2)
			thisEntity.armor:SetLevel(2)
			thisEntity.volatile_rot:SetLevel(2)
			thisEntity.rot:SetLevel(2)
		end
	end


	function AIThink(thisEntity)
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() and not thisEntity:HasModifier("modifier_green_dragon_etheral_armor") then
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
				if thisEntity.volatile_rot:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = target:GetAbsOrigin(),
						AbilityIndex = thisEntity.volatile_rot:entindex()
					})
					return thisEntity.volatile_rot:GetCastPoint() + 0.1
				end
			end
			return AICore:AttackHighestPriority( thisEntity )
		else return AI_THINK_RATE end
	end
end