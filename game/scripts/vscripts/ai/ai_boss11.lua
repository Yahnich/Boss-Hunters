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
	thisEntity.spike = thisEntity:FindAbilityByName("creature_aoe_spikes")
	thisEntity.lightning = thisEntity:FindAbilityByName("creature_lightning_storm")
	AITimers:CreateTimer(0.1, function()
		if  math.floor(GameRules.gameDifficulty + 0.5) <= 2 then
			thisEntity.lightning:SetLevel(1)
			thisEntity.spike:SetLevel(1)
		else
			thisEntity.lightning:SetLevel(2)
			thisEntity.spike:SetLevel(2)
		end
	end)
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		if thisEntity.spike:IsFullyCastable() and thisEntity.lightning:IsFullyCastable() then
			local range = thisEntity.spike:GetCastRange()
			if thisEntity.spike:GetCastRange() < thisEntity.lightning:GetCastRange() then range = thisEntity.lightning:GetCastRange() end
			local target = AICore:HighestThreatHeroInRange( thisEntity, range, 15, false )
			if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity, range, false ) end
			if target then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					AbilityIndex = thisEntity.spike:entindex(),
					Position = target:GetOrigin()
				})
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
					TargetIndex = target:entindex(),
					AbilityIndex = thisEntity.lightning:entindex()
				})
				return AI_THINK_RATE
			end
		elseif thisEntity.spike:IsFullyCastable() then
			local target = AICore:HighestThreatHeroInRange( thisEntity, thisEntity.spike:GetCastRange(), 15, false )
			if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity, thisEntity.spike:GetCastRange(), false ) end
			if target then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					AbilityIndex = thisEntity.spike:entindex(),
					Position = target:GetOrigin()
				})
				return AI_THINK_RATE
			end
		elseif thisEntity.lightning:IsFullyCastable() then
			local target = AICore:HighestThreatHeroInRange( thisEntity, thisEntity.lightning:GetCastRange(), 0, false )
			if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity, thisEntity.lightning:GetCastRange(), false ) end
			if target then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
					TargetIndex = target:entindex(),
					AbilityIndex = thisEntity.lightning:entindex()
				})
			end
			return AI_THINK_RATE
		end
		return AICore:AttackHighestPriority( thisEntity )
	else return AI_THINK_RATE end
end