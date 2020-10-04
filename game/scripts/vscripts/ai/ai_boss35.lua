if IsClient() then return end

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.blood = thisEntity:FindAbilityByName("boss_doom_blood_is_power")
	thisEntity.sacrifice = thisEntity:FindAbilityByName("boss_doom_sacrificial_rite")
	thisEntity.unstoppable = thisEntity:FindAbilityByName("boss_doom_unstoppable")
	
	thisEntity.ill = thisEntity:FindAbilityByName("boss_doom_ill_fated")
	thisEntity.pillar = thisEntity:FindAbilityByName("boss_doom_pillar_of_hell")
	thisEntity.wave = thisEntity:FindAbilityByName("boss_doom_infernal_wave")
	thisEntity.tempest = thisEntity:FindAbilityByName("boss_doom_hell_tempest")
	thisEntity.servants = thisEntity:FindAbilityByName("boss_doom_demonic_servants")

	AITimers:CreateTimer(0.1, function()
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
			thisEntity.blood:SetLevel(1)
			thisEntity.sacrifice:SetLevel(1)
			thisEntity.unstoppable:SetLevel(1)
			
			thisEntity.ill:SetLevel(1)
			thisEntity.pillar:SetLevel(1)
			thisEntity.wave:SetLevel(1)
			thisEntity.tempest:SetLevel(1)
			thisEntity.servants:SetLevel(1)
		else
			thisEntity.blood:SetLevel(2)
			thisEntity.sacrifice:SetLevel(2)
			thisEntity.unstoppable:SetLevel(2)
			
			thisEntity.ill:SetLevel(2)
			thisEntity.pillar:SetLevel(2)
			thisEntity.wave:SetLevel(2)
			thisEntity.tempest:SetLevel(2)
			thisEntity.servants:SetLevel(2)
		end
	end)

end

function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local target = AICore:GetHighestPriorityTarget( thisEntity )
		if thisEntity.ill:IsFullyCastable() then
			local illTarget = AICore:MostDamageEnemyHeroInRange( thisEntity, thisEntity.ill:GetTrueCastRange() + thisEntity:GetIdealSpeed() , true ) or target
			if illTarget then
				return CastIllFated(illTarget, thisEntity)
			end
		end
		if thisEntity.servants:IsFullyCastable() and ( AICore:BeingAttacked( thisEntity ) > 0 or RollPercentage( 2 ) ) then
			return CastServants(thisEntity)
		end
		if thisEntity.tempest:IsFullyCastable() and ( AICore:TotalEnemyHeroesInRange( thisEntity, 1200) > 1 or ( AICore:TotalEnemyHeroesInRange( thisEntity, 1200) > 0 and RollPercentage(5) ) ) then
			return CastTempest(thisEntity)
		end
		if thisEntity.wave:IsFullyCastable() and ( AICore:NumEnemiesInLine(thisEntity, 2000, 1000, false) > 1 or ( AICore:NumEnemiesInLine(thisEntity, 2000, 1000, false) > 0 and RollPercentage(25) ) ) then
			return CastWave(thisEntity)
		end
		if thisEntity.pillar:IsFullyCastable() and ( AICore:NumEnemiesInLine(thisEntity, 1200, 250, false) > 1 or ( AICore:NumEnemiesInLine(thisEntity, 1200, 250, false) > 0 and RollPercentage(20) ) ) then
			return CastPillar(target:GetAbsOrigin(), thisEntity)
		end
		return AICore:AttackHighestPriority( thisEntity )
	else
		return AI_THINK_RATE
	end
end

function CastIllFated(target, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = thisEntity.ill:entindex()
	})
	return thisEntity.ill:GetCastPoint() + 0.1
end

function CastPillar(position, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.pillar:entindex()
	})
	return thisEntity.pillar:GetCastPoint() + 0.1
end

function CastWave(thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.wave:entindex()
	})
	return thisEntity.wave:GetCastPoint() + 0.1
end

function CastTempest(thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.tempest:entindex()
	})
	return thisEntity.tempest:GetCastPoint() + 0.1
end

function CastServants(thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.servants:entindex()
	})
	return thisEntity.servants:GetCastPoint() + 0.1
end