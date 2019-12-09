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
	thisEntity.slardarList = {}
	thisEntity.submerge = thisEntity:FindAbilityByName("boss_slardar_submerge")
	thisEntity.crush = thisEntity:FindAbilityByName("boss_slardar_splash_zone")
	thisEntity.bless = thisEntity:FindAbilityByName("boss_slardar_blessing_of_the_tides")
	thisEntity.getBehaviorState = BEHAVIOR_NORMAL
	
	local level = math.floor(GameRules.gameDifficulty/2 + 0.5)
	AITimers:CreateTimer(function()
		thisEntity.submerge:SetLevel( level )
		thisEntity.crush:SetLevel( level )
		thisEntity.bless:SetLevel( level )
	end)
end

BEHAVIOR_RETURNING = 1
BEHAVIOR_NORMAL = 0

function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local radius = thisEntity.crush:GetSpecialValueFor("radius")
		if thisEntity.crush:IsFullyCastable()
		and ( AICore:TotalNotDisabledEnemyHeroesInRange( thisEntity, radius * 1.25, false ) >= math.floor(AICore:TotalEnemyHeroesInRange( thisEntity, radius * 1.25 )/2) 
		and AICore:TotalEnemyHeroesInRange( thisEntity, radius ) ~= 0 )
		or ( #thisEntity.slardarList > 5
		and AICore:TotalEnemyHeroesInRange( thisEntity, thisEntity.crush:GetSpecialValueFor("pool_radius") ) > 0 and RollPercentage( 50 ) ) then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.crush:entindex()
			})
			return AI_THINK_RATE
		end
		local slardars = thisEntity.slardarList
		for i = #slardars, 1, -1 do
			if not slardars[i] or slardars[i]:IsNull() or not slardars[i]:IsAlive() then
				table.remove( slardars, i )
			end
		end
		if thisEntity.submerge:IsFullyCastable() and #slardars < thisEntity.submerge:GetSpecialValueFor("max_slithereen") and ( RollPercentage(25) or thisEntity:InWater() ) then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.submerge:entindex()
			})
			return AI_THINK_RATE
		end
		if thisEntity.submergeLoc then
			if CalculateDistance( thisEntity, thisEntity.submergeLoc ) > (thisEntity:GetIdealSpeed() * 0.5) + thisEntity.crush:GetSpecialValueFor("pool_radius") and thisEntity.getBehaviorState ~= BEHAVIOR_RETURNING then
				thisEntity.getBehaviorState = BEHAVIOR_RETURNING
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
					Position = thisEntity.submergeLoc,
				})
				return AI_THINK_RATE
			elseif CalculateDistance( thisEntity, thisEntity.submergeLoc ) < 100 and thisEntity.getBehaviorState == BEHAVIOR_RETURNING then
				thisEntity.getBehaviorState = BEHAVIOR_NORMAL
			end
			if thisEntity.getBehaviorState == BEHAVIOR_NORMAL then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
					Position = thisEntity.submergeLoc,
				})
				return AI_THINK_RATE
			end
			return AI_THINK_RATE
		else
			return AICore:AttackHighestPriority( thisEntity )
		end
	else return AI_THINK_RATE end
end