--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 1 )
	thisEntity.raze1 = thisEntity:FindAbilityByName("boss_shadowraze1")
	thisEntity.raze2 = thisEntity:FindAbilityByName("boss_shadowraze2")
	thisEntity.raze3 = thisEntity:FindAbilityByName("boss_shadowraze3")
	thisEntity.summon = thisEntity:FindAbilityByName("boss_summon_eidolon")
end


function AIThink()
	if not thisEntity:IsDominated() then
		if thisEntity.raze1:IsFullyCastable() then
			local width = thisEntity.raze1:GetSpecialValueFor("shadowraze_radius")
			local range = thisEntity.raze1:GetSpecialValueFor("shadowraze_range")
			local target = AICore:FarthestEnemyHeroInRange( thisEntity, range, false )
			if target and AICore:EnemiesInLine(thisEntity, range, width, false) then
				local distance = (target:GetOrigin() - thisEntity:GetOrigin()):Length2D()
				if distance < range+width and distance > range-width then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.raze1:entindex()
					})
					return 0.25
				end
			end
		end
		if thisEntity.raze2:IsFullyCastable() then
			local width = thisEntity.raze2:GetSpecialValueFor("shadowraze_radius")
			local range = thisEntity.raze2:GetSpecialValueFor("shadowraze_range")
			local target = AICore:FarthestEnemyHeroInRange( thisEntity, range, false )
			if target and AICore:EnemiesInLine(thisEntity, range, width, false) then
				local distance = (target:GetOrigin() - thisEntity:GetOrigin()):Length2D()
				if distance < range+width and distance > range-width then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.raze2:entindex()
					})
					return 0.25
				end
			end
		end
		if thisEntity.raze3:IsFullyCastable() then
			local width = thisEntity.raze3:GetSpecialValueFor("shadowraze_radius")
			local range = thisEntity.raze3:GetSpecialValueFor("shadowraze_range")
			local target = AICore:FarthestEnemyHeroInRange( thisEntity, range, false )
			if target and AICore:EnemiesInLine(thisEntity, range, width, false)  then
				local distance = (target:GetOrigin() - thisEntity:GetOrigin()):Length2D()
				if distance < range+width and distance > range-width then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.raze3:entindex()
					})
					return 0.25
				end
			end
		end
		if thisEntity.summon:IsFullyCastable() and AICore:SpecificAlliedUnitsAlive( thisEntity, "npc_dota_boss33_eidolon") < 3 then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.summon:entindex()
			})
			return thisEntity.summon:GetChannelTime()+0.1
		end
		AICore:AttackHighestPriority( thisEntity )
		return 0.25
	else
		return 0.25
	end
end