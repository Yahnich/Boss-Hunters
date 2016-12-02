--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 1 )
	thisEntity.smash = thisEntity:FindAbilityByName("creature_melee_smash")
	if not thisEntity.smash then thisEntity.smash = thisEntity:FindAbilityByName("creature_melee_smash_h") end
end


function AIThink()
	if not thisEntity:IsDominated() then
		local radius = thisEntity.smash:GetCastRange()
		if AICore:TotalNotDisabledEnemyHeroesInRange( thisEntity, radius, false ) <= AICore:TotalEnemyHeroesInRange( thisEntity, radius ) 
		and AICore:TotalEnemyHeroesInRange( thisEntity, radius ) ~= 0 
		and thisEntity.smash:IsFullyCastable() then
			local smashRadius = thisEntity.smash:GetSpecialValueFor("impact_radius")
			local position = AICore:OptimalHitPosition(thisEntity, radius, smashRadius)
			local target = AICore:NearestEnemyHeroInRange( thisEntity, 99999 , true)
			if position then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = position,
					AbilityIndex = thisEntity.smash:entindex()
				})
				return 0.25
			end
		end
		AICore:AttackHighestPriority( thisEntity )
		return 0.25
	else return 0.25 end
end