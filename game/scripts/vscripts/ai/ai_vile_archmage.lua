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
	thisEntity.archon = thisEntity:FindAbilityByName("vile_archmage_vile_archon")
	thisEntity.wand = thisEntity:FindAbilityByName("vile_archmage_unstable_wand")
	
	thisEntity.explosion = thisEntity:FindAbilityByName("vile_archmage_vile_explosion")
	thisEntity.blow = thisEntity:FindAbilityByName("vile_archmage_ethereal_blow")
	thisEntity.coil = thisEntity:FindAbilityByName("vile_archmage_runic_coil")

	AITimers:CreateTimer(0.1, function()
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
			thisEntity.archon:SetLevel(1)
			thisEntity.wand:SetLevel(1)
			
			thisEntity.explosion:SetLevel(1)
			thisEntity.blow:SetLevel(1)
			thisEntity.coil:SetLevel(1)
		else
			thisEntity.archon:SetLevel(2)
			thisEntity.wand:SetLevel(2)
			
			thisEntity.explosion:SetLevel(2)
			thisEntity.blow:SetLevel(2)
			thisEntity.coil:SetLevel(2)
		end
	end)

end

function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local target = AICore:GetHighestPriorityTarget( thisEntity )
		if thisEntity.blow:IsFullyCastable() then
			local illTarget = AICore:MostDamageEnemyHeroInRange( thisEntity, thisEntity.blow:GetTrueCastRange() + thisEntity:GetIdealSpeed() , true ) or target
			if illTarget then
				return CastEtherealBlow(illTarget, thisEntity)
			end
		end
		if thisEntity.coil:IsFullyCastable() and ( AICore:BeingAttacked( thisEntity ) > 0 or RollPercentage( 25 ) ) then
			local position = thisEntity:GetAbsOrigin() - thisEntity:GetForwardVector() * thisEntity.coil:GetTrueCastRange()
			return CastRunicCoil(position, thisEntity)
		end
		if thisEntity.explosion:IsFullyCastable()  then
			local position = AICore:OptimalHitPosition( thisEntity, thisEntity.explosion:GetTrueCastRange(), thisEntity.explosion:GetSpecialValueFor("radius") )
			if position then
				return CastVileExplosion(position, thisEntity)
			end
		end
		return AICore:AttackHighestPriority( thisEntity )
	else
		return AI_THINK_RATE
	end
end

function CastEtherealBlow(target, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = thisEntity.blow:entindex()
	})
	return thisEntity.blow:GetCastPoint() + 0.1
end

function CastRunicCoil(position, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.coil:entindex()
	})
	return thisEntity.coil:GetCastPoint() + 0.1
end

function CastVileExplosion(position, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.explosion:entindex()
	})
	return thisEntity.explosion:GetCastPoint() + 0.1
end