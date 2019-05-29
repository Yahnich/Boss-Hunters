--[[
Broodking AI
]]

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
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
			thisEntity.aura:SetLevel(1)
			thisEntity.death:SetLevel(1)
			thisEntity.take:SetLevel(1)
			
			thisEntity.wave:SetLevel(1)
			thisEntity.reaper:SetLevel(1)
			thisEntity.song:SetLevel(1)
			thisEntity.guillotine:SetLevel(1)
			thisEntity.weaken:SetLevel(1)
		else
			thisEntity.aura:SetLevel(2)
			thisEntity.death:SetLevel(2)
			thisEntity.take:SetLevel(2)
			
			thisEntity.wave:SetLevel(2)
			thisEntity.reaper:SetLevel(2)
			thisEntity.song:SetLevel(2)
			thisEntity.guillotine:SetLevel(2)
			thisEntity.weaken:SetLevel(2)
		end
	end)
	
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		local target = AICore:GetHighestPriorityTarget( thisEntity )
		if thisEntity.wave:IsFullyCastable() and RollPercentage(50) then
			return CastWave( thisEntity )
		end
		if thisEntity.weaken:IsFullyCastable() and HeroList:GetActiveHeroCount() > 1 and RollPercentage(20) then
			local weakenTarget = AICore:MostDamageEnemyHeroInRange( thisEntity, thisEntity.weaken:GetTrueCastRange() + thisEntity:GetIdealSpeed() , true ) or target
			if weakenTarget then
				return CastWeaken( weakenTarget, thisEntity )
			end
		end
		if thisEntity.song:IsFullyCastable() and RollPercentage(20) then
			local songTarget = AICore:RandomEnemyHeroInRange( thisEntity, -1 , false) or target
			if songTarget then
				return CastSong( songTarget, thisEntity )
			end
		end
		if thisEntity.guillotine:IsFullyCastable() and RollPercentage(20) then
			local songTarget = AICore:WeakestEnemyHeroInRange( thisEntity, -1 , false) or target
			if songTarget then
				return CastGuillotine( songTarget, thisEntity )
			end
		end
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