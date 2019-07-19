function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.decay = thisEntity:FindAbilityByName("boss_arthromos_touch_of_decay")
	thisEntity.raise = thisEntity:FindAbilityByName("boss_arthromos_hellraiser")
	thisEntity.plague = thisEntity:FindAbilityByName("boss_arthromos_plague_aura")
	
	thisEntity.swarm = thisEntity:FindAbilityByName("boss_arthromos_virulent_swarm")
	thisEntity.pestilence = thisEntity:FindAbilityByName("boss_arthromos_pestilence")
	thisEntity.dessicate = thisEntity:FindAbilityByName("boss_arthromos_dessicate")

	AITimers:CreateTimer(0.1, function()
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
			thisEntity.decay:SetLevel(1)
			thisEntity.raise:SetLevel(1)
			thisEntity.plague:SetLevel(1)
			
			thisEntity.swarm:SetLevel(1)
			thisEntity.pestilence:SetLevel(1)
			thisEntity.dessicate:SetLevel(1)
		else
			thisEntity.decay:SetLevel(2)
			thisEntity.raise:SetLevel(2)
			thisEntity.plague:SetLevel(2)
			
			thisEntity.swarm:SetLevel(2)
			thisEntity.pestilence:SetLevel(2)
			thisEntity.dessicate:SetLevel(2)
		end
	end)
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local target = AICore:GetHighestPriorityTarget(thisEntity)
		if thisEntity.pestilence:IsFullyCastable() and AICore:RandomEnemyHeroInRange( thisEntity, thisEntity.pestilence:GetSpecialValueFor("radius") ) then
			return CastPestilence()
		end
		if thisEntity.dessicate:IsFullyCastable() then
			return CastDessicate()
		end
		if thisEntity.swarm:IsFullyCastable() and target then
			return CastSwarm( target:GetAbsOrigin() )
		end
		return AICore:AttackHighestPriority( thisEntity )
	else 
		return AI_THINK_RATE 
	end
end

function CastSwarm(position)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.swarm:entindex()
	})
	return thisEntity.swarm:GetCastPoint() + 0.1
end

function CastPestilence()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.pestilence:entindex()
	})
	return thisEntity.pestilence:GetCastPoint() + 0.1
end

function CastDessicate()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.dessicate:entindex()
	})
	return thisEntity.dessicate:GetCastPoint() + thisEntity.dessicate:GetChannelTime() + 0.1
end