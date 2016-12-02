--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 1.5)
	thisEntity.smash = thisEntity:FindAbilityByName("creature_melee_smash3")
	thisEntity.smash2 = thisEntity:FindAbilityByName("creature_melee_smash3_h")
	if not thisEntity.smash and not thisEntity.smash2 then
		thisEntity.smash = thisEntity:FindAbilityByName("creature_melee_smash3_vh_a")
		thisEntity.smash2 = thisEntity:FindAbilityByName("creature_melee_smash3_vh_b")
	end
end


function AIThink()
	if not thisEntity:IsDominated() then
		local think = 0.25
		if thisEntity.smash then
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
					think = thisEntity.smash:GetSpecialValueFor("think_time") + thisEntity.smash:GetCastPoint() + 0.1
					return think
				end
			end
		end
		if thisEntity.smash2 then
			local radius = thisEntity.smash2:GetCastRange()
			if AICore:TotalNotDisabledEnemyHeroesInRange( thisEntity, radius, false ) <= AICore:TotalEnemyHeroesInRange( thisEntity, radius ) 
			and AICore:TotalEnemyHeroesInRange( thisEntity, radius ) ~= 0 
			and thisEntity.smash:IsFullyCastable() then
				local smashRadius = thisEntity.smash2:GetSpecialValueFor("impact_radius")
				local position = AICore:OptimalHitPosition(thisEntity, radius, smashRadius)
				if position then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = position,
						AbilityIndex = thisEntity.smash2:entindex()
					})
					think = thisEntity.smash2:GetSpecialValueFor("think_time") + thisEntity.smash2:GetCastPoint() + 0.1
					return think
				end
			end
		end
		AICore:AttackHighestPriority( thisEntity )
		return think
	else return 0.25 end
end