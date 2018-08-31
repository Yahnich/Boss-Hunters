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
	thisEntity.leap = thisEntity:FindAbilityByName("boss_wolves_leap")
	thisEntity.cripple = thisEntity:FindAbilityByName("boss_wolves_critical")
	thisEntity.howl = thisEntity:FindAbilityByName("boss_alpha_wolf_howl")
	thisEntity.aura = thisEntity:FindAbilityByName("boss_alpha_wolf_aura")
	
	AITimers:CreateTimer(0.1, 	function()
		thisEntity.leap:SetLevel(1)
		thisEntity.cripple:SetLevel(1)
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
			thisEntity.aura:SetLevel(1)
			thisEntity.howl:SetLevel(1)
		elseif  math.floor(GameRules.gameDifficulty + 0.5) > 2 then
			thisEntity.aura:SetLevel(2)
			thisEntity.howl:SetLevel(2)
		end
	end)
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local target = AICore:GetHighestPriorityTarget(thisEntity)
		if thisEntity.leap:IsFullyCastable() and target and CalculateDistance( target, thisEntity ) > thisEntity:GetAttackRange() then
			return CastLeap( target:GetAbsOrigin() )
		end
		if thisEntity.howl:IsFullyCastable() and ( thisEntity:IsAttacking() or AICore:BeingAttacked( thisEntity ) > 0 ) then
			return CastHowl()
		end
		return AICore:AttackHighestPriority( thisEntity )
	else return AI_THINK_RATE end
end

function CastLeap(position)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.leap:entindex()
	})
	return thisEntity.leap:GetCastPoint() + 0.1
end

function CastHowl()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.howl:entindex()
	})
	return thisEntity.howl:GetCastPoint() + 0.1
end