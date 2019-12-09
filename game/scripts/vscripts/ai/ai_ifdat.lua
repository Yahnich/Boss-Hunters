function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.touch = thisEntity:FindAbilityByName("boss_ifdat_touch_of_fire")
	thisEntity.flash = thisEntity:FindAbilityByName("boss_ifdat_flashfire")
	thisEntity.trail = thisEntity:FindAbilityByName("boss_ifdat_trailblazer")
	
	thisEntity.magma = thisEntity:FindAbilityByName("boss_ifdat_magma_pool")
	thisEntity.flame = thisEntity:FindAbilityByName("boss_ifdat_flamethrower")
	thisEntity.cinder = thisEntity:FindAbilityByName("boss_ifdat_cinderheart")
	thisEntity.meteor = thisEntity:FindAbilityByName("boss_ifdat_meteor_storm")
	thisEntity.incinerate = thisEntity:FindAbilityByName("boss_ifdat_incinerate")
	
	level = math.floor(GameRules:GetGameDifficulty() / 2 + 0.5)
	
	thisEntity.touch:SetLevel( level )
	thisEntity.flash:SetLevel( level )
	thisEntity.trail:SetLevel( level )
	
	thisEntity.magma:SetLevel( level )
	thisEntity.flame:SetLevel( level )
	thisEntity.cinder:SetLevel( level )
	thisEntity.meteor:SetLevel( level )
	thisEntity.incinerate:SetLevel( level )
	thisEntity.touchOfFireTable = thisEntity.touchOfFireTable or {}
	thisEntity:SetHealth(thisEntity:GetMaxHealth())
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local target = AICore:GetHighestPriorityTarget(thisEntity)
		if thisEntity:GetHealthPercent() > 35 then
			return AggressiveBehavior(target)
		else
			if AICore:IsNearEnemyUnit( thisEntity, thisEntity:GetAttackRange() * 0.75 ) and not RollPercentage( 30 ) then
				local position = AICore:BeAHugeCoward( thisEntity, thisEntity:GetAttackRange() )
				return CalculateDistance( thisEntity:GetAbsOrigin(), position ) / thisEntity:GetIdealSpeed()
			else
				return AggressiveBehavior(target)
			end
			return AI_THINK_RATE
		end
	else 
		return AI_THINK_RATE 
	end
end

function AggressiveBehavior(target)
	if thisEntity.magma:IsFullyCastable() then
		local magmaTarget = AICore:RandomEnemyHeroInRange( thisEntity, thisEntity.magma:GetTrueCastRange() ) or target
		if magmaTarget then
			return CastMagmaPool( magmaTarget:GetAbsOrigin() )
		end
	end
	if thisEntity.flame:IsFullyCastable() then
		local flameTarget = AICore:RandomEnemyHeroInRange( thisEntity, thisEntity.flame:GetTrueCastRange() ) or target
		if flameTarget then
			return CastFlamethrower( flameTarget:GetAbsOrigin() )
		end
	end
	if thisEntity.incinerate:IsFullyCastable() then
		local incinerateTarget = target or AICore:RandomEnemyHeroInRange( thisEntity, thisEntity.magma:GetTrueCastRange(), false, true )
		if incinerateTarget then
			return CastIncinerate( incinerateTarget )
		end
	end
	if thisEntity.cinder:IsFullyCastable() and (thisEntity.cinder:GetCurrentPotentialHeal() <= thisEntity:GetHealthDeficit() or thisEntity:GetHealthPercent() <= 75) and RollPercentage( 100 - thisEntity:GetHealthPercent() ) then
		return CastCinderheart()
	end
	if thisEntity.meteor:IsFullyCastable() and target then
		return CastMeteorStorm( )
	end
	return AICore:AttackHighestPriority( thisEntity )
end

function CastMagmaPool(position)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.magma:entindex()
	})
	return thisEntity.magma:GetCastPoint() + 0.1
end

function CastFlamethrower(position)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.flame:entindex()
	})
	return thisEntity.flame:GetCastPoint() + 0.1
end

function CastCinderheart()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.cinder:entindex()
	})
	return thisEntity.cinder:GetCastPoint() + 0.1
end

function CastMeteorStorm()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.meteor:entindex()
	})
	return thisEntity.meteor:GetCastPoint() + 0.1
end


function CastIncinerate(target)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = thisEntity.incinerate:entindex()
	})
	return thisEntity.incinerate:GetCastPoint() + 0.1
end