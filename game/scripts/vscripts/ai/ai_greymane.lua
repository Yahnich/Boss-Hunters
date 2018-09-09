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
	thisEntity.call = thisEntity:FindAbilityByName("boss_greymane_call_of_the_alpha")
	thisEntity.leader = thisEntity:FindAbilityByName("boss_greymane_leaders_inspiration")
	
	thisEntity.swipe = thisEntity:FindAbilityByName("boss_greymane_furious_swipe")
	thisEntity.pounce = thisEntity:FindAbilityByName("boss_greymane_pounce")
	thisEntity.cry = thisEntity:FindAbilityByName("boss_greymane_battle_cry")
	thisEntity.blows = thisEntity:FindAbilityByName("boss_greymane_frenzied_blows")

	AITimers:CreateTimer(0.1, function()
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
			thisEntity.call:SetLevel(1)
			thisEntity.leader:SetLevel(1)
			
			thisEntity.swipe:SetLevel(1)
			thisEntity.pounce:SetLevel(1)
			thisEntity.cry:SetLevel(1)
			thisEntity.blows:SetLevel(1)
		else
			thisEntity.call:SetLevel(2)
			thisEntity.leader:SetLevel(2)
			
			thisEntity.swipe:SetLevel(2)
			thisEntity.pounce:SetLevel(2)
			thisEntity.cry:SetLevel(2)
			thisEntity.blows:SetLevel(2)
		end
	end)
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local target = AICore:GetHighestPriorityTarget(thisEntity)
		if thisEntity.cry:IsFullyCastable() then
			return CastCry( thisEntity )
		end
		if thisEntity.swipe:IsFullyCastable() then
			if target and CalculateDistance( target, thisEntity) <= thisEntity.swipe:GetTrueCastRange() * 1.5 then
				return CastSwipe( target:GetAbsOrigin(), thisEntity )
			else
				local randomTarget = AICore:RandomEnemyHeroInRange( thisEntity, thisEntity.swipe:GetTrueCastRange() * 1.5 )
				if randomTarget then
					return CastSwipe( randomTarget:GetAbsOrigin(), thisEntity )
				end
			end
		end
		if thisEntity.pounce:IsFullyCastable() and target then
			return CastPounce( target:GetAbsOrigin(), thisEntity )
		end
		if thisEntity.blows:IsFullyCastable() and target then
			return CastBlows( target:GetAbsOrigin(), thisEntity )
		end
		return AICore:AttackHighestPriority( thisEntity )
	else 
		return AI_THINK_RATE 
	end
end

function CastSwipe(position, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.swipe:entindex()
	})
	return thisEntity.swipe:GetCastPoint() + 0.1
end

function CastPounce(position, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.pounce:entindex()
	})
	return thisEntity.pounce:GetCastPoint() + 0.1
end

function CastCry(thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.cry:entindex()
	})
	return thisEntity.cry:GetCastPoint() + 0.1
end

function CastBlows(position, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.blows:entindex()
	})
	return thisEntity.blows:GetCastPoint() + 0.1
end