if IsClient() then return end

require( "ai/ai_core" )

-- GENERIC AI FOR SIMPLE CHASE ATTACKERS

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	
	thisEntity.cold = thisEntity:FindAbilityByName("boss_phantom_cold_touch")
	thisEntity.wail = thisEntity:FindAbilityByName("boss_phantom_banshee_wail")

	AITimers:CreateTimer(0.1, function()
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
			thisEntity.cold:SetLevel(1)
			thisEntity.wail:SetLevel(1)
		else
			thisEntity.cold:SetLevel(2)
			thisEntity.wail:SetLevel(2)
		end
	end)
end


function AIThink(thisEntity)
	if thisEntity and not thisEntity:IsNull() then
		if not thisEntity:IsDominated() then
			if thisEntity.wail:IsFullyCastable() and AICore:NearestEnemyHeroInRange( thisEntity, thisEntity.wail:GetSpecialValueFor("radius")) then
				return CastWail(thisEntity)
			end
			return AICore:AttackHighestPriority( thisEntity )
		else return 1 end
	end
end

function CastWail(thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.wail:entindex()
	})
	return thisEntity.wail:GetCastPoint() + 0.1
end