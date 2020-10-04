if IsClient() then return end

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.smash = thisEntity:FindAbilityByName("boss_ogre_smash")
	if not thisEntity.smash then thisEntity.smash = thisEntity:FindAbilityByName("boss_ogre_smash") end
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		local target = AICore:NearestEnemyHeroInRange( thisEntity, 99999 , true)
		local radius = thisEntity.smash:GetCastRange(thisEntity:GetAbsOrigin(), target)
		if AICore:TotalNotDisabledEnemyHeroesInRange( thisEntity, radius, false ) <= AICore:TotalEnemyHeroesInRange( thisEntity, radius ) 
		and AICore:TotalEnemyHeroesInRange( thisEntity, radius ) ~= 0 
		and thisEntity.smash:IsFullyCastable() then
			local smashRadius = thisEntity.smash:GetSpecialValueFor("radius")
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