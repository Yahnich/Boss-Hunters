--[[
Broodking AI
]]

require( "ai/ai_core" )
function Spawn( entityKeyValues )
	Timers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.rupture = thisEntity:FindAbilityByName("creature_rupture")
	thisEntity.pounce = thisEntity:FindAbilityByName("lesser_nightcrawler_pounce")
	local target = AICore:WeakestEnemyHeroInRange( thisEntity, 9000, true )
	if target then
		ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = target:entindex()
			})
	else
		AICore:AttackHighestPriority( thisEntity )
	end
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		local target = AICore:WeakestEnemyHeroInRange( thisEntity, thisEntity.rupture:GetCastRange(), true )
		if target and thisEntity.rupture:IsFullyCastable() and not target:HasModifier("modifier_bloodseeker_rupture") then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = target:entindex(),
				AbilityIndex = thisEntity.rupture:entindex()
			})
			return 1
		end
		local radius = thisEntity.pounce:GetSpecialValueFor("pounce_radius")
		local range = thisEntity.pounce:GetSpecialValueFor("pounce_distance")
		if AICore:EnemiesInLine(thisEntity, range, radius, true) and thisEntity.pounce:IsFullyCastable() then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.pounce:entindex()
			})
			return AI_THINK_RATE
		end
		local target = AICore:WeakestEnemyHeroInRange( thisEntity, 99999, true )
		if target then
			local distance = (thisEntity:GetOrigin() - target:GetOrigin()):Length2D()
			local direction = (thisEntity:GetOrigin() - target:GetOrigin()):Normalized()
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = target:entindex()
				})
			if distance > 1000 and thisEntity.pounce:IsFullyCastable() then 
				thisEntity:SetForwardVector(direction)
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.pounce:entindex()
				})
				return AI_THINK_RATE
			end
		else
			AICore:AttackHighestPriority( thisEntity )
		end
		return AI_THINK_RATE
	else return AI_THINK_RATE end
end