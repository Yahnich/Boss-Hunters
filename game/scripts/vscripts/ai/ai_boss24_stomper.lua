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
	thisEntity.shatter = thisEntity:FindAbilityByName("boss_vanguard_shin_shatter")
	thisEntity.breaker = thisEntity:FindAbilityByName("boss_vanguard_back_breaker")
	thisEntity.wall = thisEntity:FindAbilityByName("boss_vanguard_bone_wall")
	
	AITimers:CreateTimer(function()
		if  math.floor(GameRules.gameDifficulty + 0.5) <= 2 then 
			thisEntity.shatter:SetLevel(1)
			thisEntity.breaker:SetLevel(1)
			thisEntity.wall:SetLevel(1)
		else
			thisEntity.shatter:SetLevel(2)
			thisEntity.breaker:SetLevel(2)
			thisEntity.wall:SetLevel(2)
		end
	end)
end

function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		if not thisEntity:IsChanneling() then
			if thisEntity.shatter:IsFullyCastable() and AICore:TotalEnemyHeroesInRange( thisEntity, thisEntity.shatter:GetSpecialValueFor("radius")) > 0 and RollPercentage(35) then
				return CastShinShatter()
			end
			if thisEntity.wall:IsFullyCastable() and AICore:BeingAttacked( thisEntity ) > 0 and RollPercentage(20) then
				return CastBoneWall()
			end
			return AICore:AttackHighestPriority( thisEntity )
		else return 0.5 end
	else return AI_THINK_RATE end
end

function CastShinShatter()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.shatter:entindex()
	})
	return thisEntity.shatter:GetCastPoint() + 0.1
end

function CastBoneWall()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.wall:entindex()
	})
	return thisEntity.wall:GetCastPoint() + 0.1
end