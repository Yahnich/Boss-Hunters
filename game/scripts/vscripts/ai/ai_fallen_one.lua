if IsClient() then return end

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.aura = thisEntity:FindAbilityByName("fallen_one_aura_of_war")
	thisEntity.debilitate = thisEntity:FindAbilityByName("fallen_one_debilitate")
	thisEntity.fade = thisEntity:FindAbilityByName("fallen_one_fade_out")
	thisEntity.bolt = thisEntity:FindAbilityByName("fallen_one_sinister_bolt")

	AITimers:CreateTimer(0.1, function()
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
			thisEntity.aura:SetLevel(1)
			thisEntity.debilitate:SetLevel(1)
			thisEntity.fade:SetLevel(1)
			thisEntity.bolt:SetLevel(1)
		else
			thisEntity.aura:SetLevel(2)
			thisEntity.fade:SetLevel(2)
			thisEntity.bolt:SetLevel(2)
		end
	end)

end

function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local target = AICore:GetHighestPriorityTarget( thisEntity )
		if thisEntity.fade:IsFullyCastable() and ( AICore:BeingAttacked( thisEntity ) > 0 or RollPercentage( 25 ) ) then
			local illTarget = AICore:MostDamageEnemyHeroInRange( thisEntity, thisEntity.fade:GetTrueCastRange() + thisEntity:GetIdealSpeed() , true ) or target
			if illTarget then
				return CastFadeout(illTarget, thisEntity)
			end
		end
		if thisEntity.bolt:IsFullyCastable() and target and RollPercentage(50) then
			return CastSinisterBolt(target:GetAbsOrigin(), thisEntity)
		end
		if thisEntity.debilitate:IsFullyCastable() and target and RollPercentage(50) then
			return CastDebilitate(target:GetAbsOrigin(), thisEntity)
		end
		return AICore:AttackHighestPriority( thisEntity )
	else
		return AI_THINK_RATE
	end
end

function CastFadeout(target, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = thisEntity.fade:entindex()
	})
	return thisEntity.fade:GetCastPoint() + 0.1
end

function CastSinisterBolt(position, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.bolt:entindex()
	})
	return thisEntity.bolt:GetCastPoint() + 0.1
end

function CastDebilitate(position, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.debilitate:entindex()
	})
	return thisEntity.debilitate:GetCastPoint() + 0.1
end