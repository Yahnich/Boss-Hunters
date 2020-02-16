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
	thisEntity.rage = thisEntity:FindAbilityByName("boss_lifestealer_bloodfrenzy")
	thisEntity.wounds = thisEntity:FindAbilityByName("boss_lifestealer_open_wounds")
	thisEntity.feast = thisEntity:FindAbilityByName("boss_lifestealer_feast")
	thisEntity.consume = thisEntity:FindAbilityByName("boss_lifestealer_consume")
	local level = math.floor(GameRules:GetGameDifficulty()/2)
	AITimers:CreateTimer(0.1, function() 
		thisEntity.rage:SetLevel( level )
		thisEntity.wounds:SetLevel( level )
		thisEntity.feast:SetLevel( level )
		thisEntity.consume:SetLevel( level )
	end)
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		local target = AICore:HighestThreatHeroInRange(thisEntity, thisEntity.wounds:GetTrueCastRange(), 15, false)
		if not target then target = AICore:NearestEnemyHeroInRange( thisEntity, thisEntity.wounds:GetTrueCastRange(), false) end
		if thisEntity.wounds:IsFullyCastable() and target and thisEntity:GetHealth() < thisEntity:GetMaxHealth()*0.8 then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = target:entindex(),
				AbilityIndex = thisEntity.wounds:entindex()
			})
			return thisEntity.wounds:GetCastPoint()
		end
		if not target then
			target = AICore:GetHighestPriorityTarget( thisEntity )
		end
		if thisEntity:IsDisabled() 
		or ( target and ( ( CalculateDistance( target, thisEntity ) > thisEntity:GetAttackRange() and target:GetIdealSpeed() > thisEntity:GetIdealSpeed() ) 
		or CalculateDistance( target, thisEntity ) > thisEntity:GetAttackRange() * 1.5 ) )
		and thisEntity.rage:IsFullyCastable() then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.rage:entindex()
			})
			return 0.1
		end
		if thisEntity.consume:IsFullyCastable() then
			local heroes = {}
			local consumeTarget
			for _, unit in ipairs( thisEntity:FindAllUnitsInRadius( thisEntity:GetAbsOrigin(), thisEntity.consume:GetTrueCastRange() ) ) do
				if unit ~= thisEntity then
					if unit:IsRealHero() then
						table.insert( heroes, unit )
					elseif unit:GetHealth() <= thisEntity:GetHealthDeficit() * 1.5 or 
					( consumeTarget and unit:GetHealth() > consumeTarget:GetHealth() 
					and unit:GetHealth() < consumeTarget:GetHealthDeficit() ) then
						consumeTarget = unit
					end
				end
			end
			if consumeTarget then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
					TargetIndex = consumeTarget:entindex(),
					AbilityIndex = thisEntity.consume:entindex()
				})
				return thisEntity.consume:GetCastPoint()
			elseif #heroes > 0 and RollPercentage( 35 ) then
				consumeTarget = heroes[RandomInt(1, #heroes)]
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
					TargetIndex = consumeTarget:entindex(),
					AbilityIndex = thisEntity.consume:entindex()
				})
				return thisEntity.consume:GetCastPoint()
			end
		end
		return AICore:AttackHighestPriority( thisEntity )
	else return AI_THINK_RATE end
end