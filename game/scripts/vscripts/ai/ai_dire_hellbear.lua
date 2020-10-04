if IsClient() then return end

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.wallop = thisEntity:FindAbilityByName("boss_hellbear_wallop")
	thisEntity.clap = thisEntity:FindAbilityByName("boss_hellbear_clap")
	
	local level = math.floor(GameRules.gameDifficulty / 2 + 0.5)
	AITimers:CreateTimer(0.1, function()
		thisEntity.wallop:SetLevel( level )
		thisEntity.clap:SetLevel( level )
	end)

end

function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local target = AICore:GetHighestPriorityTarget( thisEntity )
		if thisEntity.clap:IsFullyCastable() then
			local radius = thisEntity.clap:GetSpecialValueFor("radius")
			if AICore:TotalEnemyHeroesInRange( thisEntity, radius ) > 1 or ( target and CalculateDistance( target, thisEntity) <= radius ) then
				return CastClap(thisEntity)
			end
		end
		if thisEntity.wallop:IsFullyCastable() then
			if target and CalculateDistance( target, thisEntity ) <= thisEntity.wallop:GetTrueCastRange() + thisEntity:GetIdealSpeed() / 2 then
				return CastWallop( target, thisEntity )
			else
				local chargeAt = AICore:RandomEnemyHeroInRange( thisEntity, thisEntity.wallop:GetTrueCastRange() + RandomInt( 0, 200 ) )
				if chargeAt then
					return CastWallop( chargeAt, thisEntity )
				end
			end
		end
		return AICore:AttackHighestPriority( thisEntity )
	else
		return AI_THINK_RATE
	end
end

function CastClap( thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.clap:entindex()
	})
	return thisEntity.clap:GetCastPoint() + 0.1
end

function CastWallop(target, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = thisEntity.wallop:entindex()
	})
	return thisEntity.wallop:GetCastPoint() + 0.1
end