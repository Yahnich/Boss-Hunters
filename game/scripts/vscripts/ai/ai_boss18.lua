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
	thisEntity.armor = thisEntity:FindAbilityByName("boss_living_armor")
	thisEntity.summon = thisEntity:FindAbilityByName("creature_summon_tree")
	
	AITimers:CreateTimer(0.1, function() spawn.armor:SetLevel( math.max(spawn.armor:GetMaxLevel(), math.floor(GameRules:GetGameDifficulty()/2) + RoundManager:GetRaidsFinished() ) ) end)
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		if not thisEntity:IsChanneling() then
			if thisEntity.armor:IsFullyCastable() and not thisEntity:HasModifier("modifier_treant_living_armor") then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
					TargetIndex = thisEntity:entindex(),
					AbilityIndex = thisEntity.armor:entindex()
				})
				return AI_THINK_RATE
			end
			if thisEntity.summon:IsFullyCastable() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.summon:entindex()
				})
				return AI_THINK_RATE
			end
			AICore:AttackHighestPriority( thisEntity )
			return AI_THINK_RATE
		else return 0.5 end
	else return AI_THINK_RATE end
end