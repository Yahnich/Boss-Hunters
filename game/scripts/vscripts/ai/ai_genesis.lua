--[[
Broodking AI
]]

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.reconstruction = thisEntity:FindAbilityByName("boss_genesis_reconstruction")
	thisEntity.deconstruction = thisEntity:FindAbilityByName("boss_genesis_deconstruction")
	thisEntity.pacifism = thisEntity:FindAbilityByName("boss_genesis_pacifism")
	
	thisEntity.crumple = thisEntity:FindAbilityByName("boss_genesis_crumple")
	thisEntity.purify = thisEntity:FindAbilityByName("boss_genesis_purify")
	thisEntity.resolve = thisEntity:FindAbilityByName("boss_genesis_strengthen_resolve")
	thisEntity.tolife = thisEntity:FindAbilityByName("boss_genesis_return_to_life")
	thisEntity.sanctuary = thisEntity:FindAbilityByName("boss_genesis_sanctuary")
	thisEntity.dominion = thisEntity:FindAbilityByName("boss_genesis_dominion")

	AITimers:CreateTimer(0.1, function()
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
			thisEntity.reconstruction:SetLevel(1)
			thisEntity.deconstruction:SetLevel(1)
			thisEntity.pacifism:SetLevel(1)
			
			thisEntity.crumple:SetLevel(1)
			thisEntity.purify:SetLevel(1)
			thisEntity.resolve:SetLevel(1)
			thisEntity.sanctuary:SetLevel(1)
			thisEntity.dominion:SetLevel(1)
		else
			thisEntity.reconstruction:SetLevel(2)
			thisEntity.deconstruction:SetLevel(2)
			thisEntity.pacifism:SetLevel(2)
			
			thisEntity.crumple:SetLevel(2)
			thisEntity.purify:SetLevel(2)
			thisEntity.resolve:SetLevel(2)
			thisEntity.sanctuary:SetLevel(2)
			thisEntity.dominion:SetLevel(2)
		end
	end)

end

function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local target = AICore:GetHighestPriorityTarget( thisEntity )
		if thisEntity.crumple:IsFullyCastable() then
			if not target or thisEntity.crumple:GetTrueCastRange() < CalculateDistance( target, thisEntity ) then
				local nearest = AICore:NearestEnemyHeroInRange( thisEntity, thisEntity.crumple:GetTrueCastRange() + thisEntity:GetIdealSpeed(), false)
				if nearest then
					return CastCrumple(nearest:GetAbsOrigin(), thisEntity)
				end
			elseif target then
				return CastCrumple(target:GetAbsOrigin(), thisEntity)
			end
		end
		if thisEntity.purify:IsFullyCastable() and RollPercentage(50) then
			local randomTarget = AICore:RandomEnemyHeroInRange( thisEntity, thisEntity.purify:GetTrueCastRange() )
			if randomTarget then
				return CastPurify(randomTarget, thisEntity)
			elseif target then
				return CastPurify(target, thisEntity)
			end
		end
		if thisEntity.resolve:IsFullyCastable() and AICore:TotalEnemyHeroesInRange( thisEntity, thisEntity.deconstruction:GetSpecialValueFor("radius") ) > 0 then
			return CastResolve(thisEntity)
		end
		if thisEntity.tolife:IsFullyCastable() then
			return CastReturn(thisEntity)
		end
		if thisEntity.sanctuary:IsFullyCastable() 
		and ( AICore:TotalEnemyHeroesInRange( thisEntity, 1200 ) > 1 
		or ( AICore:TotalEnemyHeroesInRange( thisEntity, 1200 ) > 0 
		and RollPercentage(20) ) )
		and not thisEntity:HasModifier("modifier_boss_genesis_dominion") then
			return CastSanctuary(thisEntity)
		end
		if thisEntity.dominion:IsFullyCastable() 
		and ( AICore:BeingAttacked( thisEntity ) > 1 ) 
		and not thisEntity:HasModifier("modifier_boss_genesis_sanctuary") then
			return CastDominion(thisEntity)
		end
		return AICore:AttackHighestPriority( thisEntity )
	else
		return AI_THINK_RATE
	end
end

function CastPurify(target, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = thisEntity.purify:entindex()
	})
	return thisEntity.purify:GetCastPoint() + 0.1
end

function CastCrumple(position, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.crumple:entindex()
	})
	return thisEntity.crumple:GetCastPoint() + 0.1
end

function CastResolve(thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.resolve:entindex()
	})
	return thisEntity.resolve:GetCastPoint() + 0.1
end

function CastReturn(thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.tolife:entindex()
	})
	return thisEntity.tolife:GetCastPoint() + 0.1
end

function CastSanctuary(thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.sanctuary:entindex()
	})
	return thisEntity.sanctuary:GetCastPoint() + 0.1
end

function CastDominion(thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.dominion:entindex()
	})
	return thisEntity.dominion:GetCastPoint() + 0.1
end