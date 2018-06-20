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
	thisEntity.ravage = thisEntity:FindAbilityByName("boss26_ravage")
	thisEntity.smash = thisEntity:FindAbilityByName("boss26_smash")
	thisEntity.rend = thisEntity:FindAbilityByName("boss26_rend")
	
	Timers:CreateTimer(0.1, function()
		if  math.floor(GameRules.gameDifficulty + 0.5) <= 2 then
			thisEntity.ravage:SetLevel(1)
			thisEntity.smash:SetLevel(1)
			thisEntity.rend:SetLevel(1)
		else
			thisEntity.ravage:SetLevel(2)
			thisEntity.smash:SetLevel(2)
			thisEntity.rend:SetLevel(2)
		end
	end)
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local target = thisEntity:GetTauntTarget() or FindMarkedTarget(thisEntity) or AttackingMaster(thisEntity) or AICore:GetHighestPriorityTarget(thisEntity)
		if target then
			if thisEntity.ravage:IsFullyCastable() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = target:GetAbsOrigin(),
					AbilityIndex = thisEntity.ravage:entindex()
				})
				return thisEntity.ravage:GetCastPoint() + 0.1
			end
			if thisEntity.rend:IsFullyCastable() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = target:GetAbsOrigin(),
					AbilityIndex = thisEntity.rend:entindex()
				})
				return thisEntity.rend:GetCastPoint() + 0.1
				
			end
		end
		if thisEntity.smash:IsFullyCastable() and AICore:IsNearEnemyUnit(thisEntity, thisEntity.smash:GetSpecialValueFor("radius")) then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.smash:entindex()
			})
			return thisEntity.smash:GetCastPoint() + 0.1
		end
		if not target then
			AICore:AttackHighestPriority( thisEntity )
		else
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = target:entindex(),
				AbilityIndex = thisEntity.ankle:entindex()
			})
		end
		return AI_THINK_RATE
	else return AI_THINK_RATE end
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
end

function AttackingMaster(entity)
	if entity.bearMaster then
		local attackers = AICore:BeingAttackedBy( entity.bearMaster )
		for _, attacker in ipairs(attackers) do
			return attacker
		end
	end
end