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
	thisEntity.ankle = thisEntity:FindAbilityByName("boss26b_ankle_biter")
	thisEntity.wound = thisEntity:FindAbilityByName("boss26b_wound")
	
	AITimers:CreateTimer(0.1, function()
		if  math.floor(GameRules.gameDifficulty + 0.5) <= 2 then
			thisEntity.ankle:SetLevel(1)
			thisEntity.wound:SetLevel(1)
		else
			thisEntity.ankle:SetLevel(2)
			thisEntity.wound:SetLevel(2)
		end
	end)
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local target = thisEntity:GetTauntTarget() or FindMarkedTarget(thisEntity) or AttackingMaster(thisEntity) or AICore:GetHighestPriorityTarget(thisEntity)
		if target then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = target:entindex(),
				AbilityIndex = thisEntity.ankle:entindex()
			})
			return thisEntity.ankle:GetCastPoint() + 0.1
		end
		
		if target then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = target:entindex(),
			})
			return thisEntity:GetSecondsPerAttack()
		end
		return AICore:AttackHighestPriority( thisEntity )
	else return 0.25 end
end


function FindMarkedTarget(entity)
	local flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
	if magic_immune then
		flags = flags + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	local targets = FindUnitsInRadius( entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flags, 0, false )
	for _, target in ipairs(targets) do
		if target:HasModifier("modifier_boss27_kill_them_debuff") then return target end
	end
	return nil
end

function AttackingMaster(entity)
	if entity.bearMaster then
		local attackers = AICore:BeingAttackedBy( entity.bearMaster )
		for _, attacker in ipairs(attackers) do
			return attacker
		end
	end
end