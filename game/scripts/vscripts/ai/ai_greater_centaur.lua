if IsClient() then return end

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.stomp = thisEntity:FindAbilityByName("boss_centaur_stomp")
	thisEntity.charge = thisEntity:FindAbilityByName("boss_centaur_charge")
	thisEntity.bash = thisEntity:FindAbilityByName("boss_centaur_bash")
	
	local level = math.floor(GameRules.gameDifficulty / 2 + 0.5)
	AITimers:CreateTimer(0.1, function()
		thisEntity.stomp:SetLevel( level )
		thisEntity.charge:SetLevel( level )
		thisEntity.bash:SetLevel( level )
	end)

end

function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local target = AICore:GetHighestPriorityTarget( thisEntity )
		if thisEntity.stomp:IsFullyCastable() then
			local radius = thisEntity.stomp:GetSpecialValueFor("radius")
			if AICore:TotalEnemyHeroesInRange( thisEntity, radius ) > 1 or ( target and CalculateDistance( target, thisEntity) <= radius and not target:IsStunned() ) then
				return CastStomp(thisEntity)
			end
		end
		if thisEntity.charge:IsFullyCastable() then
			local range = thisEntity.charge:GetSpecialValueFor("speed")
			if target and CalculateDistance( target, thisEntity ) <= range then
				return CastCharge( target:GetAbsOrigin(), thisEntity )
			else
				local chargeAt = AICore:RandomEnemyHeroInRange( thisEntity, range + RandomInt( 0, 200 ) )
				if chargeAt then
					return CastCharge( chargeAt:GetAbsOrigin(), thisEntity )
				end
			end
		end
		return AICore:AttackHighestPriority( thisEntity )
	else
		return AI_THINK_RATE
	end
end

function CastStomp( thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.stomp:entindex()
	})
	return thisEntity.stomp:GetCastPoint() + 0.1
end

function CastCharge(position, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.charge:entindex()
	})
	return thisEntity.charge:GetCastPoint() + 0.1
end