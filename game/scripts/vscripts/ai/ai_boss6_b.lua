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
	thisEntity.curse = thisEntity:FindAbilityByName("boss_slark_blood_curse")
	thisEntity.gift = thisEntity:FindAbilityByName("boss_slark_gift_of_the_flayed")
	-- local target = AICore:WeakestEnemyHeroInRange( thisEntity, 9000, true )
	-- if target then
		-- ExecuteOrderFromTable({
				-- UnitIndex = thisEntity:entindex(),
				-- OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				-- TargetIndex = target:entindex()
			-- })
	-- else
		-- AICore:AttackHighestPriority( thisEntity )
	-- end
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		return AICore:AttackHighestPriority( thisEntity )
	else return AI_THINK_RATE end
end