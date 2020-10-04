if IsClient() then return end

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.acceleration = thisEntity:FindAbilityByName("boss_aeon_time_acceleration")
	thisEntity.distortion = thisEntity:FindAbilityByName("boss_aeon_distortion_field")
	thisEntity.flashback = thisEntity:FindAbilityByName("boss_aeon_flashback")
	
	thisEntity.sphere = thisEntity:FindAbilityByName("boss_aeon_chronal_sphere")
	thisEntity.past = thisEntity:FindAbilityByName("boss_aeon_sins_of_the_past")
	thisEntity.rewind = thisEntity:FindAbilityByName("boss_aeon_rewind")
	thisEntity.fetal = thisEntity:FindAbilityByName("boss_aeon_fetal_syndrome")
	thisEntity.deteriorate = thisEntity:FindAbilityByName("boss_aeon_deteriorate")
	
	AITimers:CreateTimer(0.1, function()
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
			thisEntity.acceleration:SetLevel(1)
			thisEntity.distortion:SetLevel(1)
			thisEntity.flashback:SetLevel(1)
			
			thisEntity.sphere:SetLevel(1)
			thisEntity.past:SetLevel(1)
			thisEntity.rewind:SetLevel(1)
			thisEntity.fetal:SetLevel(1)
			thisEntity.deteriorate:SetLevel(1)
		elseif  math.floor(GameRules.gameDifficulty + 0.5) > 2 and  math.floor(GameRules.gameDifficulty + 0.5) <= 4 then 
			thisEntity.acceleration:SetLevel(2)
			thisEntity.distortion:SetLevel(2)
			thisEntity.flashback:SetLevel(2)
			
			thisEntity.sphere:SetLevel(2)
			thisEntity.past:SetLevel(2)
			thisEntity.rewind:SetLevel(2)
			thisEntity.fetal:SetLevel(2)
			thisEntity.deteriorate:SetLevel(2)
		end
		thisEntity.rewind:StartCooldown(10)
	end)
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() or not thisEntity:IsAlive() then
		local target = AICore:GetHighestPriorityTarget(thisEntity)
		if thisEntity.sphere:IsCooldownReady() and AICore:TotalEnemyHeroesInRange( thisEntity, thisEntity.sphere:GetTrueCastRange() + thisEntity.sphere:GetSpecialValueFor("max_radius")) > 0 and RollPercentage(50) then
			local position = AICore:OptimalHitPosition(thisEntity, thisEntity.sphere:GetTrueCastRange(), thisEntity.sphere:GetSpecialValueFor("max_radius"), false)
			return CastSphere(position)
		end
		if thisEntity.past:IsCooldownReady() and AICore:TotalEnemyHeroesInRange( thisEntity, -1 ) > 0 and RollPercentage(20) then
			local randomTarget = AICore:RandomEnemyHeroInRange( thisEntity, thisEntity.past:GetTrueCastRange() , true)
			if randomTarget then
				return CastSins( randomTarget )
			end
		end
		if thisEntity.rewind:IsCooldownReady() and RollPercentage(10) then
			return CastRewind()
		end
		if thisEntity.fetal:IsCooldownReady() and AICore:TotalEnemyHeroesInRange( thisEntity, thisEntity.fetal:GetTrueCastRange() ) > 0 and RollPercentage(75) then
			local highestDamage = AICore:MostDamageEnemyHeroInRange( thisEntity, thisEntity.fetal:GetTrueCastRange(), false)
			if highestDamage then
				return CastFetalSyndrome(highestDamage)
			end
		end
		if thisEntity.deteriorate:IsCooldownReady() and AICore:TotalEnemyHeroesInRange( thisEntity, thisEntity.deteriorate:GetTrueCastRange() + thisEntity.deteriorate:GetSpecialValueFor("radius" ) ) > 0 and RollPercentage(90) then
			local position = AICore:OptimalHitPosition(thisEntity, thisEntity.deteriorate:GetTrueCastRange(), thisEntity.deteriorate:GetSpecialValueFor("radius"), false)
			return CastDeteriorate(position)
		end
		return AICore:AttackHighestPriority( thisEntity )
	else
		return AI_THINK_RATE
	end
end

function CastSphere(position)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.sphere:entindex()
	})
	return thisEntity.sphere:GetCastPoint() + 0.1
end

function CastSins(target)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = thisEntity.past:entindex()
	})
	return thisEntity.past:GetCastPoint() + 0.1
end

function CastRewind()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.rewind:entindex()
	})
	return thisEntity.rewind:GetCastPoint() + 0.1
end

function CastFetalSyndrome(target)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = thisEntity.fetal:entindex()
	})
	return thisEntity.fetal:GetCastPoint() + 0.1
end

function CastDeteriorate(position)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.deteriorate:entindex()
	})
	return thisEntity.deteriorate:GetCastPoint() + 0.1
end