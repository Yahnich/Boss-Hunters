if IsClient() then return end

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	
	thisEntity.aura = thisEntity:FindAbilityByName("boss_necro_vile_aura")
	thisEntity.death = thisEntity:FindAbilityByName("boss_necro_deathbringer")
	thisEntity.take = thisEntity:FindAbilityByName("boss_necro_take_the_weak")
	
	thisEntity.wave = thisEntity:FindAbilityByName("boss_necro_plague_wave")
	thisEntity.reaper = thisEntity:FindAbilityByName("boss_necro_fear_the_reaper")
	thisEntity.song = thisEntity:FindAbilityByName("boss_necro_swans_song")
	thisEntity.guillotine = thisEntity:FindAbilityByName("boss_necro_guillotine")
	thisEntity.weaken = thisEntity:FindAbilityByName("boss_necro_weaken")

	AITimers:CreateTimer(0.1, function()
		for i = 0, thisEntity:GetAbilityCount() - 1 do
			local ability = thisEntity:GetAbilityByIndex( i )
			
			if ability then
				ability:SetLevel( math.floor( GameRules.gameDifficulty/2 + 0.5) )
			end
		end
	end)
	
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		local target = AICore:GetHighestPriorityTarget( thisEntity )
		if thisEntity.wave then
			if thisEntity.wave:IsFullyCastable() and RollPercentage(50) then
				return CastWave( thisEntity )
			end
		end
		if thisEntity.weaken then
			if thisEntity.weaken:IsFullyCastable() and HeroList:GetActiveHeroCount() > 1 and RollPercentage(20) then
				local weakenTarget = AICore:MostDamageEnemyHeroInRange( thisEntity, thisEntity.weaken:GetTrueCastRange() + thisEntity:GetIdealSpeed() , true ) or target
				if weakenTarget then
					return CastWeaken( weakenTarget, thisEntity )
				end
			end
		end
		if thisEntity.song then
			if thisEntity.song:IsFullyCastable() and RollPercentage(20) then
				local songTarget = AICore:RandomEnemyHeroInRange( thisEntity, -1 , false) or target
				if songTarget then
					return CastSong( songTarget, thisEntity )
				end
			end
		end
		if thisEntity.guillotine then
			if thisEntity.guillotine:IsFullyCastable() and RollPercentage(20) then
				local songTarget = AICore:WeakestEnemyHeroInRange( thisEntity, -1 , false) or target
				if songTarget then
					return CastGuillotine( songTarget, thisEntity )
				end
			end
		end
		if thisEntity.reaper then
			if thisEntity.reaper:IsFullyCastable() and RollPercentage(60) then
				if RollPercentage(25) then
					local reaperTarget = AICore:RandomEnemyHeroInRange( thisEntity, -1 , false) or target
					if reaperTarget then
						return CastReaper( reaperTarget:GetAbsOrigin(), thisEntity )
					end
				elseif RollPercentage(50) and target then
					return CastReaper( target:GetAbsOrigin(), thisEntity )
				else
					AICore:OptimalHitPosition(thisEntity, thisEntity.reaper:GetTrueCastRange(), thisEntity.reaper:GetSpecialValueFor("radius"), false)
					return thisEntity.reaper:GetCastPoint() + 0.1
				end
			end
		end
		return AI_THINK_RATE
	else
		return AI_THINK_RATE
	end
end


function CastWave(thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.wave:entindex()
	})
	return thisEntity.wave:GetCastPoint() + 0.1
end

function CastReaper(position, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.reaper:entindex()
	})
	return thisEntity.reaper:GetCastPoint() + 0.1
end

function CastGuillotine(target, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = thisEntity.guillotine:entindex()
	})
	return thisEntity.guillotine:GetCastPoint() + 0.1
end

function CastSong(target, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = thisEntity.song:entindex()
	})
	return thisEntity.song:GetCastPoint() + 0.1
end

function CastWeaken(target, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = thisEntity.weaken:entindex()
	})
	return thisEntity.weaken:GetCastPoint() + 0.1
end