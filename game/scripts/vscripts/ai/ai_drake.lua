--[[
Broodking AI
]]

if IsServer() then
	require( "ai/ai_core" )
	function Spawn( entityKeyValues )
		thisEntity:SetContextThink( "AIThinker", AIThink, 0.25 )
		thisEntity.heal = thisEntity:FindAbilityByName("boss16m_heal_aura")
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
			thisEntity.heal:SetLevel(1)
		else
			thisEntity.heal:SetLevel(2)
		end
	end


	function AIThink()
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
			local target = AICore:GetHighestPriorityTarget(thisEntity)
			if target then
				if thisEntity.conflag and thisEntity.conflag:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = target:GetAbsOrigin(),
						AbilityIndex = thisEntity.conflag:entindex()
					})
					return thisEntity.conflag:GetCastPoint() + 0.1
				end
				if thisEntity.dragonfire and thisEntity.dragonfire:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = target:GetAbsOrigin(),
						AbilityIndex = thisEntity.dragonfire:entindex()
					})
					return thisEntity.dragonfire:GetCastPoint() + 0.1
				end
			end
			AICore:AttackHighestPriority( thisEntity )
			return 0.25
		else return 0.25 end
	end
end