--[[
Broodking AI
]]

require( "ai/ai_core" )

ENTITY_THINK_STATE_PATROL = 1
ENTITY_THINK_STATE_ATTACK = 2
ENTITY_THINK_STATE_DEFENSIVE = 3

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 0.25 )
	thisEntity.gale = thisEntity:FindAbilityByName("venomancer_venomous_gale")
	thisEntity.viper = thisEntity:FindAbilityByName("viper_viper_strike")
	thisEntity.state = ENTITY_THINK_STATE_PATROL
end


function AIThink()
	if thisEntity.state == ENTITY_THINK_STATE_PATROL then
		local target = AICore:NearestEnemyHeroInRange( thisEntity, 1200, true)
		if not target then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET ,
				TargetIndex = thisEntity:GetOwner():entindex(),
			})
			return 0.25
		else
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET ,
				TargetIndex = target:entindex(),
			})
			thisEntity.state = ENTITY_THINK_STATE_ATTACK
			return 0.25
		end
	elseif thisEntity.state == ENTITY_THINK_STATE_ATTACK then
		local target = thisEntity:GetOwner():GetAttackTarget() or thisEntity:GetOwner():GetCursorCastTarget() or AICore:NearestEnemyHeroInRange( thisEntity, 1200, true)
		if not target then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET ,
				TargetIndex = thisEntity:GetOwner():entindex(),
			})
			thisEntity.state = ENTITY_THINK_STATE_PATROL
			return 0.25
		else
			if AICore:BeingAttacked(thisEntity) > 0 and thisEntity:GetHealth() < 0.4*thisEntity:GetMaxHealth() then
				thisEntity.state = ENTITY_THINK_STATE_DEFENSIVE
				return 0.25
			end
			if not thisEntity:IsAttackingEntity(target) then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = target:entindex(),
				})
				return thisEntity:GetSecondsPerAttack() + 0.05
			else
				if thisEntity.gale:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION ,
						Position = target:GetAbsOrigin(),
						AbilityIndex = thisEntity.gale:entindex(),
					})
					return thisEntity.gale:GetCastPoint() + 0.05
				end
				if thisEntity.viper:IsFullyCastable() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_TARGET ,
						TargetIndex = target:entindex(),
						AbilityIndex = thisEntity.viper:entindex(),
					})
					return thisEntity.viper:GetCastPoint() + 0.05
				end
			end
		end
	elseif thisEntity.state == ENTITY_THINK_STATE_DEFENSIVE then
		if AICore:BeingAttacked(thisEntity) == 0 then
			thisEntity.state = ENTITY_THINK_STATE_ATTACK
			return 0.25
		end
		AICore:BeAHugeCoward( thisEntity, 300 )
		return 0.25
	end
	return 0.25
end