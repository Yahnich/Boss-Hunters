--[[
Broodking AI
]]

require( "ai/ai_core" )
function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
	thisEntity.blink = thisEntity:FindAbilityByName("boss_blink")
	thisEntity.strike = thisEntity:FindAbilityByName("boss_shadow_strike")
	thisEntity.scream = thisEntity:FindAbilityByName("boss_scream_of_pain")
	if math.floor(GameRules.gameDifficulty + 0.5) > 3 then
		thisEntity.blink:SetLevel(4)
		thisEntity.strike:SetLevel(4)
		thisEntity.scream:SetLevel(4)
	elseif math.floor(GameRules.gameDifficulty + 0.5) == 3 then
		thisEntity.blink:SetLevel(3)
		thisEntity.strike:SetLevel(3)
		thisEntity.scream:SetLevel(3)
	elseif math.floor(GameRules.gameDifficulty + 0.5) == 2 then
		thisEntity.blink:SetLevel(2)
		thisEntity.strike:SetLevel(2)
		thisEntity.scream:SetLevel(2)
	else
		thisEntity.blink:SetLevel(1)
		thisEntity.strike:SetLevel(1)
		thisEntity.scream:SetLevel(1)
	end
	thisEntity:SetHealth(thisEntity:GetMaxHealth())
end


function AIThink()
	if not thisEntity:IsDominated() then
		if thisEntity.blink:IsFullyCastable() then
			local range = thisEntity.blink:GetSpecialValueFor("blink_range")
			local target = AICore:HighestThreatHeroInRange( thisEntity, 9999, 15, false )
			if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity, 9999, false ) end
			if target and not thisEntity:IsAttackingEntity(target) and RollPercentage(25) then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					AbilityIndex = thisEntity.blink:entindex(),
					Position = target:GetOrigin() - (target:GetOrigin() + thisEntity:GetOrigin()):Normalized()*thisEntity:GetAttackRange()*math.random()
				})
				return thisEntity.blink:GetCastPoint() + 0.25
			end
		end
		if thisEntity.strike:IsFullyCastable() and RollPercentage(25) then
			local range = thisEntity.strike:GetCastRange()
			local target = AICore:HighestThreatHeroInRange( thisEntity, range, 15, false )
			if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity, range, false ) end
			if target then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
					TargetIndex = target:entindex(),
					AbilityIndex = thisEntity.strike:entindex()
				})
				return thisEntity.strike:GetCastPoint() + 0.25
			end
		end
		if thisEntity.scream:IsFullyCastable() and RollPercentage(25) then
			local range = thisEntity.blink:GetSpecialValueFor("area_of_effect")
			local target = AICore:HighestThreatHeroInRange( thisEntity, range, 15, false )
			if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity,range, false ) end
			if target then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.scream:entindex()
				})
				return thisEntity.scream:GetCastPoint() + 0.25
			end
		end
		AICore:AttackHighestPriority( thisEntity )
		return 0.25
	else return 0.25 end
end