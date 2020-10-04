if IsClient() then return end

require( "ai/ai_core" )

-- GENERIC AI FOR SIMPLE CHASE ATTACKERS

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	
	thisEntity.meat = thisEntity:FindAbilityByName("boss_flesh_behemoth_meat_pile")
	thisEntity.decay = thisEntity:FindAbilityByName("boss_flesh_behemoth_decay")

	AITimers:CreateTimer(0.1, function()
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
			thisEntity.meat:SetLevel(1)
			thisEntity.decay:SetLevel(1)
		else
			thisEntity.meat:SetLevel(2)
			thisEntity.decay:SetLevel(2)
		end
	end)
end


function AIThink(thisEntity)
	if thisEntity and not thisEntity:IsNull() then
		if not thisEntity:IsDominated() then
			if thisEntity.decay:IsFullyCastable() and AICore:NearestEnemyHeroInRange( thisEntity, thisEntity.decay:GetTrueCastRange()) then
				local position = AICore:OptimalHitPosition( thisEntity, thisEntity.decay:GetTrueCastRange(), thisEntity.decay:GetSpecialValueFor("radius") * 1.25 )
				return CastDecay(thisEntity, position)
			end
			return AICore:AttackHighestPriority( thisEntity )
		else return 1 end
	end
end

function CastDecay(thisEntity, position)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.decay:entindex()
	})
	return thisEntity.decay:GetCastPoint() + 0.1
end