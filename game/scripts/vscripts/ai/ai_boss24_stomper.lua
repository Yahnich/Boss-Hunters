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
	thisEntity.smash = thisEntity:FindAbilityByName("creature_melee_smash2")
	if not thisEntity.smash then thisEntity.smash = thisEntity:FindAbilityByName("creature_melee_smash2_h") end
	if not thisEntity.smash then thisEntity.smash = thisEntity:FindAbilityByName("creature_melee_smash2_vh") end
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		local radius = thisEntity.smash:GetCastRange()
		if AICore:TotalNotDisabledEnemyHeroesInRange( thisEntity, radius, false) <= AICore:TotalEnemyHeroesInRange( thisEntity, radius ) 
		and AICore:TotalEnemyHeroesInRange( thisEntity, radius ) ~= 0 
		and thisEntity.smash:IsFullyCastable() then
			local smashRadius = thisEntity.smash:GetSpecialValueFor("impact_radius")
			local position = AICore:OptimalHitPosition(thisEntity, radius, smashRadius)
			if position then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = position,
					AbilityIndex = thisEntity.smash:entindex()
				})
				return AI_THINK_RATE
			end
		end
		return AICore:AttackHighestPriority( thisEntity )
	else return AI_THINK_RATE end
end