--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 0.25 )
	thisEntity.ensnare = thisEntity:FindAbilityByName("dark_troll_warlord_ensnare")
	thisEntity.vanish = thisEntity:FindAbilityByName("boss_vanish")
	if GetMapName() == "epic_boss_fight_impossible" or GetMapName() == "epic_boss_fight_challenger" then
		thisEntity.vanish:SetLevel(2)
	else
		thisEntity.vanish:SetLevel(1)
	end
end


function AIThink()
	if not thisEntity:IsDominated() then
		local target = AICore:HighestThreatHeroInRange(thisEntity, thisEntity.ensnare:GetCastRange(), 15, true)
		if not target then target = AICore:NearestEnemyHeroInRange( thisEntity, thisEntity.ensnare:GetCastRange(), true) end
		if thisEntity.ensnare:IsFullyCastable() and target and not thisEntity:IsInvisible() then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = target:entindex(),
				AbilityIndex = thisEntity.ensnare:entindex()
			})
			return 0.25
		end
		if not target then target = AICore:NearestEnemyHeroInRange( thisEntity, 9999, true) end
		if thisEntity.vanish:IsFullyCastable() and target and not thisEntity:IsInvisible() then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.vanish:entindex()
			})
		end
		AICore:AttackHighestPriority( thisEntity )
		return 0.25
	else return 0.25 end
end