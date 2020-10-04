if IsClient() then return end

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.vici = thisEntity:FindAbilityByName("archangel_imperium_vici")
	thisEntity.frat = thisEntity:FindAbilityByName("archangel_fraternitas")
	
	thisEntity.smite = thisEntity:FindAbilityByName("archangel_smite_the_earth")
	thisEntity.bolt = thisEntity:FindAbilityByName("archangel_holy_bolt")
	thisEntity.judge = thisEntity:FindAbilityByName("archangel_divine_judgement")

	AITimers:CreateTimer(0.1, function()
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
			thisEntity.vici:SetLevel(1)
			thisEntity.frat:SetLevel(1)
			
			thisEntity.smite:SetLevel(1)
			thisEntity.bolt:SetLevel(1)
			thisEntity.judge:SetLevel(1)
		else
			thisEntity.vici:SetLevel(2)
			thisEntity.frat:SetLevel(2)
			
			thisEntity.smite:SetLevel(2)
			thisEntity.bolt:SetLevel(2)
			thisEntity.judge:SetLevel(2)
		end
	end)

end

function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local target = AICore:GetHighestPriorityTarget( thisEntity )
		if thisEntity.judge:IsFullyCastable() then
			local illTarget = AICore:MostDamageEnemyHeroInRange( thisEntity, thisEntity.judge:GetTrueCastRange() + thisEntity:GetIdealSpeed() , true ) or target
			if illTarget then
				return CastDivineJudgement(illTarget, thisEntity)
			end
		end
		if thisEntity.bolt:IsFullyCastable() then
			return CastHolyBolt(thisEntity)
		end
		if thisEntity.smite:IsFullyCastable()  then
			local position = AICore:OptimalHitPosition( thisEntity, thisEntity.smite:GetTrueCastRange(), thisEntity.smite:GetSpecialValueFor("radius") )
			if position then
				return CastSmite(position, thisEntity)
			end
		end
		return AICore:AttackHighestPriority( thisEntity )
	else
		return AI_THINK_RATE
	end
end

function CastDivineJudgement(target, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = thisEntity.judge:entindex()
	})
	return thisEntity.judge:GetCastPoint() + 0.1
end

function CastHolyBolt(thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		Position = position,
		AbilityIndex = thisEntity.bolt:entindex()
	})
	return thisEntity.bolt:GetCastPoint() + 0.1
end

function CastSmite(position, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.smite:entindex()
	})
	return thisEntity.smite:GetCastPoint() + 0.1
end