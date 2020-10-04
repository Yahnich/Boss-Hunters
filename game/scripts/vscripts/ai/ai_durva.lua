if IsClient() then return end

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.core = thisEntity:FindAbilityByName("boss_durva_gorged_core")
	thisEntity.soul = thisEntity:FindAbilityByName("boss_durva_soul_barrier")
	thisEntity.link = thisEntity:FindAbilityByName("boss_durva_all_is_linked")
	
	thisEntity.consume = thisEntity:FindAbilityByName("boss_durva_consume_soul")
	thisEntity.feast = thisEntity:FindAbilityByName("boss_durva_feast_on_their_eyes")
	thisEntity.purgatory = thisEntity:FindAbilityByName("boss_durva_purgatory")
	thisEntity.burst = thisEntity:FindAbilityByName("boss_durva_filled_to_burst")

	AITimers:CreateTimer(0.1, function()
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
			thisEntity.core:SetLevel(1)
			thisEntity.soul:SetLevel(1)
			thisEntity.link:SetLevel(1)
			
			thisEntity.consume:SetLevel(1)
			thisEntity.feast:SetLevel(1)
			thisEntity.purgatory:SetLevel(1)
			thisEntity.burst:SetLevel(1)
		else
			thisEntity.core:SetLevel(2)
			thisEntity.soul:SetLevel(2)
			thisEntity.link:SetLevel(2)
			
			thisEntity.consume:SetLevel(2)
			thisEntity.feast:SetLevel(2)
			thisEntity.purgatory:SetLevel(2)
			thisEntity.burst:SetLevel(2)
		end
	end)
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local target = AICore:GetHighestPriorityTarget(thisEntity)
		if thisEntity.consume:IsFullyCastable() and target then
			return CastConsume( target:GetAbsOrigin() )
		end
		if thisEntity.feast:IsFullyCastable() and AICore:RandomEnemyHeroInRange( thisEntity, thisEntity.feast:GetTrueCastRange(), true ) then
			return CastFeast()
		end
		if thisEntity.purgatory:IsFullyCastable() and AICore:MostDamageEnemyHeroInRange( thisEntity, thisEntity.purgatory:GetTrueCastRange() ) then
			return CastPurgatory( AICore:MostDamageEnemyHeroInRange( thisEntity, thisEntity.purgatory:GetTrueCastRange() ) )
		end
		if thisEntity.burst:IsFullyCastable() and AICore:RandomEnemyHeroInRange( thisEntity, 800, true ) then
			return CastBurst()
		end
		return AICore:AttackHighestPriority( thisEntity )
	else 
		return AI_THINK_RATE 
	end
end

function CastConsume(position)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.consume:entindex()
	})
	return thisEntity.consume:GetCastPoint() + 0.1
end

function CastFeast()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.feast:entindex()
	})
	return thisEntity.feast:GetCastPoint() + 0.1
end

function CastPurgatory(target)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = thisEntity.purgatory:entindex()
	})
	return thisEntity.purgatory:GetCastPoint() + 0.1
end

function CastBurst()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.burst:entindex()
	})
	return thisEntity.burst:GetCastPoint() + 0.1
end