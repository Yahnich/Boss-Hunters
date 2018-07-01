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
	thisEntity.shield = thisEntity:FindAbilityByName("boss_evil_guardian_fire_shield")
	thisEntity.purge = thisEntity:FindAbilityByName("boss_evil_guardian_purge_their_sin")
	thisEntity.pool = thisEntity:FindAbilityByName("boss_evil_guardian_hell_on_earth")

	thisEntity.raze1 = thisEntity:FindAbilityByName("boss_evil_guardian_annihilation")
	thisEntity.raze2 = thisEntity:FindAbilityByName("boss_evil_guardian_destruction")
	thisEntity.raze3 = thisEntity:FindAbilityByName("boss_evil_guardian_apocalypse")
	thisEntity.fist = thisEntity:FindAbilityByName("boss_evil_guardian_rise_of_hell")
	thisEntity.stun = thisEntity:FindAbilityByName("boss_evil_guardian_end_of_days")
	thisEntity.getRazingFactor = 0
end

function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		local target = AICore:GetHighestPriorityTarget(thisEntity)
		if thisEntity.fist:IsFullyCastable() then
			if not target then
				target = AICore:NearestEnemyHeroInRange( thisEntity, -1, true)
			end
			if target then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = target:GetAbsOrigin(),
					AbilityIndex = thisEntity.fist:entindex()
				})
				return thisEntity.fist:GetCastPoint() + 0.1
			end
		end
		if target and not target:IsNull() then
			local cds = 0
			local raze1CD = thisEntity.raze1:IsCooldownReady()
			local raze2CD = thisEntity.raze2:IsCooldownReady()
			local raze3CD = thisEntity.raze3:IsCooldownReady()
			if raze1CD then
				cds = cds + 1
			end
			if raze2CD then
				cds = cds + 1
			end
			if raze3CD then
				cds = cds + 1
			end
			if thisEntity.getRazingFactor < 50 then
				if thisEntity.raze1:IsFullyCastable() and AICore:TotalEnemyHeroesInRange( thisEntity, 1200 ) > 0 and RollPercentage(33/cds) then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.raze1:entindex()
					})
					return thisEntity.raze1:GetCastPoint() + 0.1 + 2
				elseif thisEntity.raze2:IsFullyCastable() and AICore:TotalEnemyHeroesInRange( thisEntity, 1200 ) > 0 and RollPercentage(33/cds) then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.raze2:entindex()
					})
					return thisEntity.raze2:GetCastPoint() + 0.1 + 2
				elseif thisEntity.raze3:IsFullyCastable() and AICore:TotalEnemyHeroesInRange( thisEntity, 1200 ) > 0 and RollPercentage(33/cds) then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.raze3:entindex()
					})
					return thisEntity.raze3:GetCastPoint() + 0.1 + 2
				end
			end
			if thisEntity.stun:IsFullyCastable() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.stun:entindex()
				})
				return thisEntity.stun:GetCastPoint() + 0.1
			end
		end
		AICore:AttackHighestPriority( thisEntity )
		return 1
	else
		return 1
	end
end