--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 0.25 )
	thisEntity.throw = thisEntity:FindAbilityByName("boss_hard_throw")
	thisEntity.toxic = thisEntity:FindAbilityByName("boss_toxic_weaponry")
	if GetMapName() == "epic_boss_fight_challenger" then
		thisEntity.throw:SetLevel(4)
		thisEntity.toxic:SetLevel(4)
	elseif GetMapName() == "epic_boss_fight_impossible" then
		thisEntity.throw:SetLevel(3)
		thisEntity.toxic:SetLevel(3)
	elseif GetMapName() == "epic_boss_fight_hard" or GetMapName() == "epic_boss_fight_boss_master" then
		thisEntity.throw:SetLevel(2)
		thisEntity.toxic:SetLevel(2)
	else
		thisEntity.throw:SetLevel(1)
		thisEntity.toxic:SetLevel(1)
	end
end


function AIThink()
	if not thisEntity:IsDominated() then
		local range = thisEntity:GetAttackRange() + thisEntity.throw:GetSpecialValueFor("bonus_range")
		local target = AICore:HighestThreatHeroInRange(thisEntity, range, 15, true)
		if not target then target = AICore:NearestEnemyHeroInRange( thisEntity, range, true) end
		if thisEntity.throw:IsFullyCastable() and target then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.throw:entindex()
			})
			return 0.1
		end
		AICore:AttackHighestPriority( thisEntity )
		return 0.25
	else return 0.25 end
end