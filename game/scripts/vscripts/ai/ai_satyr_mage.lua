if IsClient() then return end

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.lightning = thisEntity:FindAbilityByName("satyr_mage_lightning")
	thisEntity.revitalize = thisEntity:FindAbilityByName("satyr_mage_revitalize")

	AITimers:CreateTimer(0.1, function()
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
			thisEntity.lightning:SetLevel(1)
			thisEntity.revitalize:SetLevel(1)
		else
			thisEntity.lightning:SetLevel(2)
			thisEntity.revitalize:SetLevel(2)
		end
	end)

end

function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local target = AICore:GetHighestPriorityTarget( thisEntity )
		if thisEntity.lightning:IsFullyCastable() then
			local attackT = AICore:RandomEnemyHeroInRange( thisEntity, thisEntity.lightning:GetTrueCastRange() + thisEntity:GetIdealSpeed(), true ) or target
			if attackT then
				return CastLightning(attackT, thisEntity)
			end
		end
		if thisEntity.revitalize:IsFullyCastable() and thisEntity:GetHealthPercent() <= 100 - thisEntity.revitalize:GetSpecialValueFor("heal_pct") then
			return CastRevitalize(thisEntity)
		else
			for _, enemy in ipairs( thisEntity:FindFriendlyUnitsInRadius( thisEntity:GetAbsOrigin(), 2000 ) ) do
				if RollPercentage( math.max( 10 + (100 - enemy:GetHealthPercent() ) - thisEntity.revitalize:GetSpecialValueFor("heal_pct"), 0) ) then
					return CastRevitalize(thisEntity)
				end
			end
		end
		return AICore:AttackHighestPriority( thisEntity )
	else
		return AI_THINK_RATE
	end
end

function CastLightning(target, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = thisEntity.lightning:entindex()
	})
	return thisEntity.lightning:GetCastPoint() + 0.1
end

function CastRevitalize(thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.revitalize:entindex()
	})
	return thisEntity.revitalize:GetCastPoint() + 0.1
end