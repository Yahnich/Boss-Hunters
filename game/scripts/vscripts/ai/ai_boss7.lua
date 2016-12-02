--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 0.25 )
	thisEntity.rage = thisEntity:FindAbilityByName("boss_ragebuff")
	thisEntity.wounds = thisEntity:FindAbilityByName("boss_wounds")
end


function AIThink()
	if not thisEntity:IsDominated() then
		local target = AICore:HighestThreatHeroInRange(thisEntity, thisEntity.wounds:GetCastRange(), 15, false)
		if not target then target = AICore:NearestEnemyHeroInRange( thisEntity, thisEntity.wounds:GetCastRange(), false) end
		if thisEntity.wounds:IsFullyCastable() and target and thisEntity:GetHealth() < thisEntity:GetMaxHealth()*0.6 then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = target:entindex(),
				AbilityIndex = thisEntity.wounds:entindex()
			})
			return 0.25
		end
		if ((thisEntity:IsAttackingEntity(target) and thisEntity:IsAttacking()) or thisEntity:IsDisabled()) and thisEntity.rage:IsFullyCastable()  then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.rage:entindex()
			})
		end
		AICore:AttackHighestPriority( thisEntity )
		return 0.25
	else return 0.25 end
end