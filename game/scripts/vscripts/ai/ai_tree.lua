--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 1 )
	thisEntity.armor = thisEntity:FindAbilityByName("boss_living_armor")
	thisEntity.summon = thisEntity:FindAbilityByName("creature_summon_tree")
end


function AIThink()
	if not thisEntity:IsDominated() then
		if thisEntity.armor:IsFullyCastable() and not thisEntity:HasModifier("modifier_treant_living_armor") then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = thisEntity:entindex(),
				AbilityIndex = thisEntity.armor:entindex()
			})
			return 0.25
		end
		AICore:AttackHighestPriority( thisEntity )
		return 0.25
	else return 0.25 end
end