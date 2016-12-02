--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 1 )
	thisEntity.well = thisEntity:FindAbilityByName("boss_gravity_well")
	thisEntity.slam = thisEntity:FindAbilityByName("boss_graviton_slam")
	thisEntity.sweep = thisEntity:FindAbilityByName("boss_attractive_sweep")
	thisEntity.rift = thisEntity:FindAbilityByName("boss_spatial_rift")
	if not thisEntity:HasModifier("modifier_boss_damagedecrease") then
		thisEntity:AddNewModifier(spawnedUnit, nil, "modifier_boss_damagedecrease", {})
	end
	if GetMapName() == "epic_boss_fight_impossible" or GetMapName() == "epic_boss_fight_challenger" then 
		thisEntity.well:SetLevel(3)
		thisEntity.slam:SetLevel(3)
		thisEntity.sweep:SetLevel(3)
		thisEntity.rift:SetLevel(3)
		thisEntity:SetMaxHealth(thisEntity:GetMaxHealth()*2)
		thisEntity:SetBaseDamageMin(thisEntity:GetBaseDamageMin()*2)
		thisEntity:SetBaseDamageMax(thisEntity:GetBaseDamageMax()*2)
		thisEntity:SetPhysicalArmorBaseValue(thisEntity:GetPhysicalArmorBaseValue()*1.5)
		thisEntity:SetHealth(thisEntity:GetMaxHealth())
	elseif GetMapName() == "epic_boss_fight_hard" or GetMapName() == "epic_boss_fight_boss_master"  then
		thisEntity.well:SetLevel(2)
		thisEntity.slam:SetLevel(2)
		thisEntity.sweep:SetLevel(2)
		thisEntity.rift:SetLevel(2)
		thisEntity:SetMaxHealth(thisEntity:GetMaxHealth()*1.5)
		thisEntity:SetPhysicalArmorBaseValue(thisEntity:GetPhysicalArmorBaseValue()*1.25)
		thisEntity:SetBaseDamageMin(thisEntity:GetBaseDamageMin()*1.50)
		thisEntity:SetBaseDamageMax(thisEntity:GetBaseDamageMax()*1.50)
		thisEntity:SetHealth(thisEntity:GetMaxHealth())
	else
		thisEntity.well:SetLevel(1)
		thisEntity.slam:SetLevel(1)
		thisEntity.sweep:SetLevel(1)
		thisEntity.rift:SetLevel(1)
	end
end


function AIThink()
	if not thisEntity:IsDominated() then
		if thisEntity:IsChanneling() then
			return 0.25
		else
			if thisEntity.rift:IsFullyCastable() then
				if thisEntity.previoustarget then
					local distance = (thisEntity.previoustarget:GetAbsOrigin() - thisEntity:GetAbsOrigin()):Length2D()
					local direction = (thisEntity.previoustarget:GetAbsOrigin() - thisEntity:GetAbsOrigin()):Normalized()
					if distance > thisEntity.rift:GetCastRange() then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
							AbilityIndex = thisEntity.rift:entindex(),
							Position = thisEntity:GetAbsOrigin() + direction*thisEntity.rift:GetCastRange()
						})
						return 0.25
					elseif AICore:TotalEnemyHeroesInRange( thisEntity, thisEntity.rift:GetSpecialValueFor("radius") ) >= 3 then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
							AbilityIndex = thisEntity.rift:entindex(),
							Position = thisEntity.previoustarget:GetAbsOrigin()
						})
						return 0.25
					end
				else
					local target = AICore:HighestThreatHeroInRange(thisEntity, 2000, 10, true)
					if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity, 2000, true) end
					if not target then target = AICore:NearestEnemyHeroInRange( thisEntity, 9999, true) end
					if target then 
						local distance = (target:GetAbsOrigin() - thisEntity:GetAbsOrigin()):Length2D()
						local direction = (target:GetAbsOrigin() - thisEntity:GetAbsOrigin()):Normalized()
						if distance > thisEntity.rift:GetCastRange() then
							ExecuteOrderFromTable({
								UnitIndex = thisEntity:entindex(),
								OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
								AbilityIndex = thisEntity.rift:entindex(),
								Position = thisEntity:GetAbsOrigin() + direction*thisEntity.rift:GetCastRange()
							})
							return 0.25
						elseif AICore:TotalEnemyHeroesInRange( thisEntity, thisEntity.rift:GetSpecialValueFor("radius") ) >= 3  or AICore:TotalEnemyHeroesInRange( thisEntity, thisEntity.rift:GetSpecialValueFor("radius") ) >= PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) then
							ExecuteOrderFromTable({
								UnitIndex = thisEntity:entindex(),
								OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
								AbilityIndex = thisEntity.rift:entindex(),
								Position = target:GetAbsOrigin()
							})
							return 0.25
						end
					end
				end
			end
			if thisEntity.sweep:IsFullyCastable() then
				local target = AICore:NearestEnemyHeroInRange( thisEntity, thisEntity.sweep:GetCastRange(), false)
				local target2 = AICore:FarthestEnemyHeroInRange( thisEntity, thisEntity.sweep:GetCastRange(), false)
				if target and target2 then
					local distance1 = (target:GetAbsOrigin() - thisEntity:GetAbsOrigin()):Length2D()
					local distance2 = (target2:GetAbsOrigin() - thisEntity:GetAbsOrigin()):Length2D()
					local direction = (target2:GetAbsOrigin() - thisEntity:GetAbsOrigin()):Normalized()
					if distance2 < thisEntity.sweep:GetCastRange() and distance1 > 150 then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
							AbilityIndex = thisEntity.sweep:entindex(),
							Position = thisEntity:GetAbsOrigin() + direction*thisEntity.sweep:GetCastRange()
						})
						return 0.25
					end
				end
			end
			if thisEntity.slam:IsFullyCastable() then
				if AICore:TotalEnemyHeroesInRange( thisEntity, thisEntity.slam:GetCastRange() ) >= 2 or AICore:TotalEnemyHeroesInRange( thisEntity, thisEntity.slam:GetCastRange() ) >= PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)then
					local interval = (thisEntity.slam:GetChannelTime()+0.25)
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.slam:entindex()
					})
					return interval
				elseif thisEntity:GetHealth() < thisEntity:GetMaxHealth()*0.35 then
					local interval = (thisEntity.slam:GetChannelTime()+0.25)
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.slam:entindex()
					})
					return interval
				end
			end
			if thisEntity.well:IsFullyCastable() then
				local maxdistance = thisEntity.well:GetCastRange() + thisEntity.well:GetSpecialValueFor("radius_growth_speed")*thisEntity.well:GetChannelTime()
				local target2 = AICore:FarthestEnemyHeroInRange( thisEntity, maxdistance, false)
				if target2 then
					local distance2 = (target2:GetAbsOrigin() - thisEntity:GetAbsOrigin()):Length2D()
					if distance2 > thisEntity.well:GetCastRange() then
						local interval = (thisEntity.well:GetChannelTime()+0.25)
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = thisEntity.well:entindex()
						})
						return interval
					elseif math.ceil(thisEntity:GetMaxHealth() % thisEntity:GetHealth()) == 25 and thisEntity:GetMaxHealth() ~= thisEntity:GetHealth() then
					local interval = (thisEntity.slam:GetChannelTime()+0.25)
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.slam:entindex()
					})
					return interval
					end
				end
			end
			AICore:AttackHighestPriority( thisEntity )
			return 0.25
		end
	else return 0.25 end
end