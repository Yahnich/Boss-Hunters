if IsClient() then return end

require( "ai/ai_core" )
function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.pounce = thisEntity:FindAbilityByName("boss_slark_leap")
	thisEntity.gift = thisEntity:FindAbilityByName("boss_slark_deep_ones_gift")
	thisEntity.shroud = thisEntity:FindAbilityByName("boss_slark_shroud_of_foam")
	local level = math.floor(GameRules.gameDifficulty / 2 + 0.5)
	AITimers:CreateTimer(0.1, function()
		thisEntity.pounce:SetLevel( level )
		thisEntity.gift:SetLevel( level )
		thisEntity.shroud:SetLevel( level )
	end)
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		local radius = thisEntity.pounce:GetSpecialValueFor("pounce_radius")
		local range = thisEntity.pounce:GetSpecialValueFor("pounce_distance")
		if AICore:EnemiesInLine(thisEntity, range, radius, true) and thisEntity.pounce:IsFullyCastable() then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				Position = thisEntity:GetAbsOrigin() + thisEntity:GetForwardVector() * 150,
				AbilityIndex = thisEntity.pounce:entindex()
			})
			return AI_THINK_RATE
		end
		local target = AICore:HighestThreatHeroInRange(thisEntity, 800, 15, true)
		if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity, 9000, true) end
		if target then
			local distance = (thisEntity:GetOrigin() - target:GetOrigin()):Length2D()
			local direction = CalculateDirection( target, thisEntity )
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = target:entindex()
			})
			if distance > 1000 and thisEntity.pounce:IsFullyCastable() then 
				thisEntity:SetForwardVector(direction)
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = target:GetAbsOrigin(),
					AbilityIndex = thisEntity.pounce:entindex()
				})
				return AI_THINK_RATE
			end
		else
			return AICore:AttackHighestPriority( thisEntity )
		end
		return AI_THINK_RATE
	else return AI_THINK_RATE end
end