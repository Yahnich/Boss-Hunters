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
	thisEntity.equal = thisEntity:FindAbilityByName("boss_leshrac_great_equalizer")
	thisEntity.inevitable = thisEntity:FindAbilityByName("boss_leshrac_inevitable_end")
	thisEntity.punish = thisEntity:FindAbilityByName("boss_leshrac_punishment")
	
	thisEntity.spike = thisEntity:FindAbilityByName("boss_leshrac_earthshatter")
	thisEntity.lightning = thisEntity:FindAbilityByName("boss_leshrac_lightning_storm")
	thisEntity.pulse = thisEntity:FindAbilityByName("boss_leshrac_cataclysm")
	local level = math.floor( GameRules:GetGameDifficulty() / 2 )
	AITimers:CreateTimer(0.1, function()
		thisEntity.equal:SetLevel(level)
		thisEntity.inevitable:SetLevel(level)
		thisEntity.punish:SetLevel(level)
		thisEntity.spike:SetLevel(level)
		thisEntity.spike:SetLevel(level)
		thisEntity.pulse:SetLevel(level)
	end)
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		if thisEntity.spike:IsFullyCastable() and thisEntity.lightning:IsFullyCastable() then
			local range = thisEntity.spike:GetTrueCastRange(  )
			if thisEntity.spike:GetTrueCastRange() < thisEntity.lightning:GetTrueCastRange() then range = thisEntity.lightning:GetTrueCastRange() end
			local target = AICore:HighestThreatHeroInRange( thisEntity, range, 15, false )
			if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity, range, false ) end
			if target then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = target:GetOrigin(),
					AbilityIndex = thisEntity.lightning:entindex()
				})
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					AbilityIndex = thisEntity.spike:entindex(),
					Position = target:GetOrigin(),
					Queue = true
				})
				return thisEntity.spike:GetCastPoint() + thisEntity.lightning:GetCastPoint() + 0.1
			end
		end
		if thisEntity.spike:IsFullyCastable() and RollPercentage(35) then
			local target = AICore:HighestThreatHeroInRange( thisEntity, thisEntity.spike:GetTrueCastRange(), 15, false )
			if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity, thisEntity.spike:GetTrueCastRange(), false ) end
			if target then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					AbilityIndex = thisEntity.spike:entindex(),
					Position = target:GetOrigin()
				})
				return thisEntity.spike:GetCastPoint() + 0.1
			end
		end
		if thisEntity.lightning:IsFullyCastable() and RollPercentage(35) then
			local target = AICore:HighestThreatHeroInRange( thisEntity, thisEntity.lightning:GetTrueCastRange(), 0, false )
			if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity, thisEntity.lightning:GetTrueCastRange(), false ) end
			if target then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = target:GetOrigin(),
					AbilityIndex = thisEntity.lightning:entindex()
				})
			end
			return thisEntity.lightning:GetCastPoint() + 0.1
		end
		if thisEntity.pulse:IsFullyCastable() and RollPercentage(35) then
			if target then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_NO_TARGET,
					AbilityIndex = thisEntity.pulse:entindex()
				})
			end
			return thisEntity.pulse:GetCastPoint() + 0.1
		end
		return AICore:AttackHighestPriority( thisEntity )
	else return AI_THINK_RATE end
end