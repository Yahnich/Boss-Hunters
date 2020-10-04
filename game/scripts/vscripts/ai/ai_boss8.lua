if IsClient() then return end

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.hook = thisEntity:FindAbilityByName("boss_clockwerk_meteor_hook")
	thisEntity.mark = thisEntity:FindAbilityByName("boss_clockwerk_mark_for_destruction")
	local level = math.floor(GameRules:GetGameDifficulty()/2)
	
	AITimers:CreateTimer(0.1, function() 
		thisEntity.hook:SetLevel( level )
		thisEntity.mark:SetLevel( level )
	end)
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		local radius = thisEntity.hook:GetTrueCastRange()
		local target = AICore:HighestThreatHeroInRange(thisEntity, radius, 0, false)
		if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity, radius, false) end
		if not target then target = AICore:NearestEnemyHeroInRange( thisEntity, radius, false) end
		if target and thisEntity.mark:IsFullyCastable() then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				Position = target:GetOrigin(),
				AbilityIndex = thisEntity.mark:entindex()
			})
			return AI_THINK_RATE
		end
		if thisEntity.hook:IsFullyCastable() then
			for _, unit in ipairs( thisEntity:FindEnemyUnitsInRadius( thisEntity:GetAbsOrigin(), radius, {flag = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS} ) ) do
				if unit:HasModifier("modifier_boss_clockwerk_mark_for_destruction_blind") then
					target = unit
					break
				end
			end
			if target then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = target:GetOrigin(),
					AbilityIndex = thisEntity.hook:entindex()
				})
				return AI_THINK_RATE
			end
		end
		return AICore:AttackHighestPriority( thisEntity )
	else return AI_THINK_RATE end
end