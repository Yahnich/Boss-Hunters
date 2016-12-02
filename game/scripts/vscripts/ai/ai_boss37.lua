--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 1 )
	if thisEntity:GetUnitName() == "npc_dota_boss37_h" then 
		thisEntity.suffix = "_h"
	elseif thisEntity:GetUnitName() == "npc_dota_boss37_vh" then
		thisEntity.suffix = "_vh"
	else
		thisEntity.suffix = ""
	end
	thisEntity.web = thisEntity:FindAbilityByName("creature_spin_web"..thisEntity.suffix)
	thisEntity.eggs = thisEntity:FindAbilityByName("creature_spawn_broodmother_eggs")
	thisEntity.haste = thisEntity:FindAbilityByName("creature_self_haste")
	thisEntity.cowardtime = 0
end


function AIThink()
	if not thisEntity:IsDominated() then
		local radius = thisEntity.web:GetSpecialValueFor("radius")
		if thisEntity:GetHealth() > thisEntity:GetMaxHealth()*0.5 then
			if AICore:BeingAttacked(thisEntity) > 2 or (AICore:TotalAlliedUnitsInRange( thisEntity, radius ) > 4 and thisEntity:IsAttacking() ) and thisEntity.web:IsFullyCastable() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.web:entindex()
				})
				thisEntity.webPos = thisEntity:GetOrigin()
				return 0.25
			end
			if thisEntity.eggs:IsFullyCastable() and AICore:SpecificAlliedUnitsAlive( thisEntity, "npc_dota_creature_broodmother" ) < 5 then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.eggs:entindex()
				})
				return 0.25
			end
		elseif thisEntity:GetHealth() > thisEntity:GetMaxHealth()*0.25 and thisEntity:GetHealth() < thisEntity:GetMaxHealth()*0.5 then
			local enemy = AICore:NearestEnemyHeroInRange( thisEntity, 600 )
			if AICore:BeingAttacked(thisEntity) > 2 or AICore:TotalAlliedUnitsInRange( thisEntity, radius ) > 4 and thisEntity.web:IsFullyCastable() and not thisEntity:HasModifier("modifier_rune_haste") and not enemy then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.web:entindex()
				})
				thisEntity.webPos = thisEntity:GetOrigin()
				return 0.25
			elseif thisEntity.eggs:IsFullyCastable() and AICore:SpecificAlliedUnitsAlive( thisEntity, "npc_dota_creature_broodmother" ) < 5 then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.eggs:entindex()
				})
				return 0.25
			elseif thisEntity.haste:IsFullyCastable() and not thisEntity:HasModifier("web_aura") then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.haste:entindex()
				})	
				AICore:BeAHugeCoward( thisEntity, 2000 )
				return 5
			else
				AICore:BeAHugeCoward( thisEntity, 800 )
				return 1
			end
		elseif thisEntity:GetHealth() < thisEntity:GetMaxHealth()*0.25 then
			if thisEntity.web:IsFullyCastable() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.web:entindex()
				})
				thisEntity.webPos = thisEntity:GetOrigin()
				thisEntity.cowardtime = GameRules:GetGameTime()
				return 0.25
			end
			local cowardDist = (thisEntity.webPos - thisEntity:GetOrigin())
			print(cowardDist:Length2D() > radius)
			if cowardDist:Length2D() < radius and thisEntity:HasModifier("web_aura") then
				AICore:AttackHighestPriority( thisEntity )
				return 0.25
			elseif cowardDist:Length2D() > radius and GameRules:GetGameTime() - thisEntity.cowardtime < 8 then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
					Position = thisEntity.webPos
				})
				return 3
			end
		end
		AICore:AttackHighestPriority( thisEntity )
		return 0.25
	else
		return 0.25
	end
end