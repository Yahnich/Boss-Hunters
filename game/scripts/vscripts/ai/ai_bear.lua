--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 1 )
	thisEntity.smash = thisEntity:FindAbilityByName("creature_earthshock")
end


function AIThink()
	if not thisEntity:IsDominated() then
		if thisEntity.smash then
			local radius = thisEntity.smash:GetCastRange()
			local target
			if AICore:TotalNotDisabledEnemyHeroesInRange( thisEntity, radius, false) <= AICore:TotalEnemyHeroesInRange( thisEntity, radius ) and AICore:TotalEnemyHeroesInRange( thisEntity, radius ) ~= 0 and thisEntity.smash:IsFullyCastable() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.smash:entindex()
				})
				return 0.25

			end
		end
		AICore:AttackHighestPriority( thisEntity )
		return 0.25
	else return 0.25 end
end