--[[
Broodking AI
]]

require( "ai/ai_core" )
function Spawn( entityKeyValues )
	Timers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.ball = thisEntity:FindAbilityByName("boss4_death_ball")
	thisEntity.summon = thisEntity:FindAbilityByName("boss4_summon_zombies")
	thisEntity.sacrifice = thisEntity:FindAbilityByName("boss4_sacrifice")
	thisEntity.tombstone = thisEntity:FindAbilityByName("boss4_tombstone")
	
	Timers:CreateTimer(function()
		if  math.floor(GameRules.gameDifficulty + 0.5) <= 2 then 
			thisEntity.ball:SetLevel(1)
			thisEntity.summon:SetLevel(1)
			thisEntity.sacrifice:SetLevel(1)
			thisEntity.tombstone:SetLevel(1)
		else
			thisEntity.ball:SetLevel(2)
			thisEntity.summon:SetLevel(2)
			thisEntity.sacrifice:SetLevel(2)
			thisEntity.tombstone:SetLevel(2)
			
			thisEntity:SetBaseMaxHealth(thisEntity:GetMaxHealth()*1.5)
			thisEntity:SetMaxHealth(thisEntity:GetMaxHealth()*1.5)
			thisEntity:SetHealth(thisEntity:GetMaxHealth())
		end
	end)
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local target = AICore:GetHighestPriorityTarget(thisEntity)
		if (AICore:BeingAttacked(thisEntity) > 1 or AICore:IsNearEnemyUnit(thisEntity, 600)) and thisEntity.tombstone:IsFullyCastable() and not thisEntity:HasModifier("modifier_boss4_tombstone_caster") then
			local position = thisEntity:GetAbsOrigin() - (thisEntity:GetForwardVector() * thisEntity.tombstone:GetCastRange(thisEntity:GetAbsOrigin(), thisEntity))
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				Position = position,
				AbilityIndex = thisEntity.tombstone:entindex()
			})
			return thisEntity.tombstone:GetCastPoint() + 0.1
		end
		if thisEntity.summon:IsFullyCastable() and AICore:IsNearEnemyUnit(thisEntity, 800) then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.summon:entindex()
			})
			return thisEntity.summon:GetCastPoint() + 0.1
		end
		local range = thisEntity.ball:GetSpecialValueFor("distance")
		local radius = thisEntity.ball:GetSpecialValueFor("radius")
		if thisEntity.ball:IsFullyCastable() and AICore:EnemiesInLine(thisEntity, range, radius) then
			local targetPos = AICore:FindNearestEnemyInLine(thisEntity, range, radius)
			if CalculateDistance(thisEntity, target) < range then targetPos = target end
			if targetPos then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = targetPos:GetAbsOrigin(), 
					AbilityIndex = thisEntity.ball:entindex()
				})
			end
			return thisEntity.ball:GetCastPoint() + 0.1
		end
		if thisEntity.sacrifice:IsFullyCastable() and thisEntity:GetHealthPercent() < 75 and thisEntity.summon:GetZombieCount() > 4 then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.sacrifice:entindex()
			})
			return thisEntity.sacrifice:GetCastPoint() + 0.1
		end
		AICore:AttackHighestPriority( thisEntity )
		return 0.25
	else return 0.25 end
end