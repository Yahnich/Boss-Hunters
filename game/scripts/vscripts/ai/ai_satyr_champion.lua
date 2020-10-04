if IsClient() then return end

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.shock = thisEntity:FindAbilityByName("satyr_champion_shockwave")
	thisEntity.combust = thisEntity:FindAbilityByName("satyr_champion_mana_combustion")
	thisEntity.occult = thisEntity:FindAbilityByName("satyr_champion_occult_aura")

	AITimers:CreateTimer(0.1, function()
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
			thisEntity.shock:SetLevel(1)
			thisEntity.combust:SetLevel(1)
			thisEntity.occult:SetLevel(1)
		else
			thisEntity.shock:SetLevel(2)
			thisEntity.combust:SetLevel(2)
			thisEntity.occult:SetLevel(2)
		end
	end)

end

function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local target = AICore:GetHighestPriorityTarget( thisEntity )
		if thisEntity.shock:IsFullyCastable() and ( AICore:NumEnemiesInLine(thisEntity, thisEntity.shock:GetSpecialValueFor("distance"), thisEntity.shock:GetSpecialValueFor("width")) >= 2 or (AICore:NumEnemiesInLine(thisEntity, thisEntity.shock:GetSpecialValueFor("distance"), thisEntity.shock:GetSpecialValueFor("width") ) >= 1 and RollPercentage( 25 ) ) ) then
			local sTarget = AICore:FindNearestEnemyInLine(thisEntity, thisEntity.shock:GetSpecialValueFor("distance"), thisEntity.shock:GetSpecialValueFor("width") )
			if sTarget then
				return CastShockwave(sTarget:GetAbsOrigin(), thisEntity)
			end
		end
		if thisEntity.combust:IsFullyCastable()  then
			local position = AICore:OptimalHitPosition( thisEntity, thisEntity.combust:GetTrueCastRange(), thisEntity.combust:GetSpecialValueFor("radius") )
			if position then
				return CastManaCombustion(position, thisEntity)
			elseif target then
				return CastManaCombustion(target:GetAbsOrigin(), thisEntity)
			end
		end
		return AICore:AttackHighestPriority( thisEntity )
	else
		return AI_THINK_RATE
	end
end

function CastShockwave(position, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.shock:entindex()
	})
	return thisEntity.shock:GetCastPoint() + 0.1
end

function CastManaCombustion(position, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.combust:entindex()
	})
	return thisEntity.combust:GetCastPoint() + 0.1
end