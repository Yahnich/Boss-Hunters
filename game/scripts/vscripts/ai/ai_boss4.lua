--[[
Broodking AI
]]

require( "ai/ai_core" )
function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
	thisEntity.rip = thisEntity:FindAbilityByName("undying_soul_rip")
	thisEntity.summon = thisEntity:FindAbilityByName("creature_summon_undead")
end


function AIThink()
	if not thisEntity:IsDominated() then
		local interval = 0.25
		if thisEntity.summon:IsFullyCastable() and AICore:SpecificAlliedUnitsAlive( thisEntity, "npc_dota_mini_boss1") < 7 then
			ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.summon:entindex()
				})
			interval = 2
			return interval
		end
		if thisEntity:GetHealth() > (thisEntity:GetMaxHealth() / 2) then
			local target = AICore:WeakestEnemyHeroInRange( thisEntity, thisEntity.rip:GetCastRange(), false)
			local count = AICore:TotalUnitsInRange( thisEntity, thisEntity.rip:GetCastRange() )
			if target and thisEntity.rip:IsFullyCastable() and count > 3 then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
					TargetIndex = target:entindex(),
					AbilityIndex = thisEntity.rip:entindex()
				})
				return interval
			end
		else
			local count = AICore:TotalUnitsInRange( thisEntity, thisEntity.rip:GetCastRange() )
			if thisEntity.rip:IsFullyCastable() and count > 3 then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
					TargetIndex = thisEntity:entindex(),
					AbilityIndex = thisEntity.rip:entindex()
				})
				return interval
			end
		end
		AICore:AttackHighestPriority( thisEntity )
		return interval
	else return 0.25 end
end