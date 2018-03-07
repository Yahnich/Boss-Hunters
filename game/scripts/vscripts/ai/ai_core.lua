--[[
Tower Defense AI

These are the valid orders, in case you want to use them (easier here than to find them in the C code):

DOTA_UNIT_ORDER_NONE
DOTA_UNIT_ORDER_MOVE_TO_POSITION 
DOTA_UNIT_ORDER_MOVE_TO_TARGET 
DOTA_UNIT_ORDER_ATTACK_MOVE
DOTA_UNIT_ORDER_ATTACK_TARGET
DOTA_UNIT_ORDER_CAST_POSITION
DOTA_UNIT_ORDER_CAST_TARGET
DOTA_UNIT_ORDER_CAST_TARGET_TREE
DOTA_UNIT_ORDER_CAST_NO_TARGET
DOTA_UNIT_ORDER_CAST_TOGGLE
DOTA_UNIT_ORDER_HOLD_POSITION
DOTA_UNIT_ORDER_TRAIN_ABILITY
DOTA_UNIT_ORDER_DROP_ITEM
DOTA_UNIT_ORDER_GIVE_ITEM
DOTA_UNIT_ORDER_PICKUP_ITEM
DOTA_UNIT_ORDER_PICKUP_RUNE
DOTA_UNIT_ORDER_PURCHASE_ITEM
DOTA_UNIT_ORDER_SELL_ITEM
DOTA_UNIT_ORDER_DISASSEMBLE_ITEM
DOTA_UNIT_ORDER_MOVE_ITEM
DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO
DOTA_UNIT_ORDER_STOP
DOTA_UNIT_ORDER_TAUNT
DOTA_UNIT_ORDER_BUYBACK
DOTA_UNIT_ORDER_GLYPH
DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH
DOTA_UNIT_ORDER_CAST_RUNE
]]

AICore = {}


AI_BEHAVIOR_AGGRESSIVE = 1 -- Threat is weighted towards damage
AI_BEHAVIOR_CAUTIOUS = 2 -- Threat is weighted towards health
AI_BEHAVIOR_SAFE = 3 -- Threat is weighted towards heals and debuffs, requires bigger threat difference to switch aggro

function AICore:RandomEnemyHeroInRange( entity, range , magic_immune)
	local flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
	if magic_immune then
		flags = flags + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	if entity:GetTauntTarget() then return entity:GetTauntTarget() end
	local enemies = FindUnitsInRadius( entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flags, 0, false )
	if #enemies > 0 then
		local index = RandomInt( 1, #enemies )
		return enemies[index]
	else
		return nil
	end
end

function AICore:NearestEnemyHeroInRange( entity, range , magic_immune)
	local flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
	if magic_immune then
		flags = flags + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	if entity:GetTauntTarget() then return entity:GetTauntTarget() end
	
	local enemies = FindUnitsInRadius( entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flags, 0, false )
	
	local minRange = range
	local target = nil
	
	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (entity:GetAbsOrigin() - enemy:GetAbsOrigin()):Length2D()
		if enemy:IsAlive() and distanceToEnemy < minRange then
			minRange = distanceToEnemy
			target = enemy
		end
	end
	if entity:GetTauntTarget() then 
		target = entity:GetTauntTarget()
	end
	return target
end

function AICore:BeingAttacked( entity )
	local enemies = FindUnitsInRadius( entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, 9999, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
	local count = 0
	
	for _,enemy in pairs(enemies) do
		if enemy:IsAlive() and enemy:IsAttackingEntity(entity) then
			count = (count or 0) + 1
		end
	end
	return count
end

function AICore:BeingAttackedBy( entity )
	local enemies = FindUnitsInRadius( entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, 9999, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
	local attackers = {}
	
	for _,enemy in pairs(enemies) do
		if enemy:IsAlive() and enemy:IsAttackingEntity(entity) then
			table.insert(attackers, enemy)
		end
	end
	return attackers
end

function AICore:GetHighestPriorityTarget(entity)
	local target
	if entity.AIprevioustarget and entity:CanEntityBeSeenByMyTeam(entity.AIprevioustarget) then
		target = entity.AIprevioustarget
	else
		target = AICore:NearestEnemyHeroInRange( entity, 15000 , true )
	end
	if entity:GetTauntTarget() then 
		target = entity:GetTauntTarget()
	end
	return target
end

function AICore:AttackHighestPriority( entity )
	if not entity and not entity:IsAlive() then return end
	local flag = DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE
	if not entity:IsDominated() then
		local target = entity:GetTauntTarget()
		local weakestInRange
		local closestUnit
		local minThreat = 0
		local minHP = 0
		if entity.AIprevioustarget and not entity.AIprevioustarget:IsNull() and entity.AIprevioustarget:IsAlive() and not entity.AIprevioustarget:IsInvisible() then 
			target = entity.AIprevioustarget
			target.threat = target.threat or 0
			minThreat = target.threat
		end
		if not entity:GetTauntTarget() then
			local range = entity:GetAttackRange() + entity:GetIdealSpeed() * 1.5
			local minRange = 99999
			local enemies = FindUnitsInRadius( entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, minRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flag, 0, false )
			for _,enemy in pairs(enemies) do
				local distanceToEnemy = (entity:GetAbsOrigin() - enemy:GetAbsOrigin()):Length2D()
				if not enemy.threat then enemy.threat = 0 end
				if not minThreat then minThreat = 0 end
				if GridNav:CanFindPath( entity:GetAbsOrigin(), enemy:GetAbsOrigin() ) and enemy:IsAlive() then
					if distanceToEnemy < range then
						if enemy.threat > minThreat and not entity.AIprevioustarget then
							minThreat = enemy.threat
							target = enemy
						elseif entity.AIprevioustarget and enemy.threat > minThreat + 5*(entity.AIbehavior or 1) then
							minThreat = enemy.threat
							target = enemy
						end
						if not target then
							local HP = enemy:GetHealth()
							if HP < minHP then
								minHP = HP
								weakestInRange = enemy
							end
						end
					end
					if not weakestInRange then
						if minRange > distanceToEnemy then
							minRange = distanceToEnemy
							closestUnit = enemy
						end
					end
				end
			end
		end
		target = target or weakestInRange or closestUnit
		entity.AIprevioustarget = target
		if target and not target:IsNull() then
			ExecuteOrderFromTable({
				UnitIndex = entity:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = target:entindex()
			})
			return 1
		else
			AICore:RunToRandomPosition( entity, 5 )
			return 1
		end
	end
end


function AICore:IsNearEnemyUnit(entity, radius)
	local iFlag = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	local units = FindUnitsInRadius(entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, iFlag, 0, false)
	return (#units > 0)
end

function AICore:BeAHugeCoward( entity, runbuffer )
	local nearest = AICore:NearestEnemyHeroInRange( entity, 99999, true )
	local position
	if nearest and not entity:GetTauntTarget() then
		local direction = (nearest:GetAbsOrigin()-entity:GetAbsOrigin()):Normalized()
		local distance = (nearest:GetAbsOrigin()-entity:GetAbsOrigin()):Length2D()
		position = entity:GetAbsOrigin() + (-direction)*RandomInt(100,300)
		if distance < runbuffer then
			ExecuteOrderFromTable({
				UnitIndex = entity:entindex(),
				OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
				Position = position
			})
		end
	elseif entity:GetTauntTarget() then
		position = entity:GetTauntTarget():GetAbsOrigin()
		ExecuteOrderFromTable({
			UnitIndex = entity:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = entity:GetTauntTarget():entindex()
		})
	end
	return position
end

function AICore:RunToRandomPosition( entity, spasticness )
	local position = entity:GetAbsOrigin() + Vector( RandomInt(-1000, 1000), RandomInt(-1000, 1000), 0)
	if RollPercentage(spasticness) and not entity:GetTauntTarget() then
		ExecuteOrderFromTable({
			UnitIndex = entity:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position = position
		})
	elseif entity:GetTauntTarget() then
		ExecuteOrderFromTable({
			UnitIndex = entity:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = entity:GetTauntTarget():entindex()
		})
	end
end

function AICore:RunToTarget( entity, target )
	if not entity or (not target and not entity:GetTauntTarget()) then 
		return 0.5 
	elseif entity:GetTauntTarget() then
		ExecuteOrderFromTable({
			UnitIndex = entity:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = entity:GetTauntTarget():entindex()
		})
		return 0.25
	end
	local position = target:GetAbsOrigin()
	ExecuteOrderFromTable({
		UnitIndex = entity:entindex(),
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		Position = position
	})
end

function AICore:FarthestEnemyHeroInRange( entity, range , magic_immune)
	local flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
	if magic_immune then
		flags = flags + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	if entity:GetTauntTarget() then return entity:GetTauntTarget() end
	local enemies = FindUnitsInRadius( entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flags, 0, false )
	
	local minRange = nil
	local target = nil
	
	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (entity:GetAbsOrigin() - enemy:GetAbsOrigin()):Length2D()
		if enemy:IsAlive() and (minRange == nil or distanceToEnemy > minRange) and distanceToEnemy < range then
			minRange = distanceToEnemy
			target = enemy
		end
	end
	if entity:GetTauntTarget() then 
		target = entity:GetTauntTarget()
	end
	return target
end

function AICore:NearestDisabledEnemyHeroInRange( entity, range , magic_immune)
	local flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
	if magic_immune then
		flags = flags + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	if entity:GetTauntTarget() then return entity:GetTauntTarget() end
	local enemies = FindUnitsInRadius( entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flags, 0, false )
	
	local minRange = range
	local target = nil
	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (entity:GetAbsOrigin() - enemy:GetAbsOrigin()):Length2D()
		if enemy:IsAlive() and distanceToEnemy < minRange and enemy:IsDisabled() then
			minRange = distanceToEnemy
			target = enemy
		end
	end
	if entity:GetTauntTarget() then 
		target = entity:GetTauntTarget()
	end
	return target
end

function AICore:TotalEnemyHeroesInRange( entity, range)
	local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
	local enemies = FindUnitsInRadius( entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flags, 0, false )
	
	local count = 0
	
	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (entity:GetAbsOrigin() - enemy:GetAbsOrigin()):Length2D()
		if enemy:IsAlive() and distanceToEnemy < range then
			count = count + 1
		end
	end
	return count
end

function AICore:OptimalHitPosition(entity, range, radius, magic_immune)
	local flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
	if magic_immune then
		flags = flags + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	local enemies = FindUnitsInRadius( entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, range + radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flags, 0, false )
	
	local initTarget = entity:GetTauntTarget() or AICore:HighestThreatHeroInRange(entity, range + radius, 0, (magic_immune or false) )
	
	
	local meanPos
	if initTarget then meanPos = initTarget:GetAbsOrigin() end
	for _,enemy in pairs(enemies) do
		local distanceToEnemy = CalculateDistance(enemy, entity)
		if not meanPos then withinRadius = 0
		else withinRadius = CalculateDistance(meanPos, enemy) end
		if enemy:IsAlive() and distanceToEnemy < range + radius and withinRadius < 2 * radius and not (enemy == initTarget) then
			if not meanPos then meanPos = enemy:GetAbsOrigin()
			elseif CalculateDistance(meanPos, entity) > range then meanPos = entity:GetAbsOrigin() + CalculateDirection(meanPos, entity) * range
			meanPos = (meanPos + enemy:GetAbsOrigin())/2 end
		end
	end
	if entity:GetTauntTarget() then meanPos = entity:GetTauntTarget():GetAbsOrigin() end
	return meanPos
end

function AICore:FindFarthestEnemyInLine(entity, range, width, magic_immune)
	local flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
	if magic_immune then
		flags = flags + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	local enemies = FindUnitsInLine(entity:GetTeamNumber(), entity:GetAbsOrigin(),  entity:GetAbsOrigin() + entity:GetForwardVector()*range, nil, width, DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flags)
	local distance = 0
	local target
	for _, enemy in ipairs(enemies) do
		if CalculateDistance(enemy, entity) > distance then
			distance = CalculateDistance(enemy, entity)
			target = enemy 
		end
	end
	if entity:GetTauntTarget() then 
		target = entity:GetTauntTarget()
	end
	return target
end

function AICore:FindNearestEnemyInLine(entity, range, width, magic_immune)
	local flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
	if magic_immune then
		flags = flags + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	local enemies = FindUnitsInLine(entity:GetTeamNumber(), entity:GetAbsOrigin(),  entity:GetAbsOrigin() + entity:GetForwardVector()*range, nil, width, DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flags)
	local distance = 0
	local target
	for _, enemy in ipairs(enemies) do
		if CalculateDistance(enemy, entity) < distance then
			distance = CalculateDistance(enemy, entity)
			target = enemy 
		end
	end
	if entity:GetTauntTarget() then 
		target = entity:GetTauntTarget()
	end
	return target
end

function AICore:TotalNotDisabledEnemyHeroesInRange( entity, range , magic_immune)
	local flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
	if magic_immune then
		flags = flags + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	
	local enemies = FindUnitsInRadius( entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flags, 0, false )
	
	local count = 0
	
	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (entity:GetAbsOrigin() - enemy:GetAbsOrigin()):Length2D()
		if enemy:IsAlive() and distanceToEnemy < range and not enemy:IsDisabled() then
			count = count + 1
		end
	end
	return count
end

function AICore:TotalUnitsInRange( entity, range )
	
	local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	local enemies = FindUnitsInRadius( entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flags, 0, false )
	
	local count = 0
	
	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (entity:GetAbsOrigin() - enemy:GetAbsOrigin()):Length2D()
		if enemy:IsAlive() and distanceToEnemy < range then
			count = count + 1
		end
	end
	return count
end

function AICore:TotalAlliedUnitsInRange( entity, range	)
	local enemies = FindUnitsInRadius( entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false )
	
	local count = 0
	
	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (entity:GetAbsOrigin() - enemy:GetAbsOrigin()):Length2D()
		if enemy:IsAlive() and distanceToEnemy < range then
			count = count + 1
		end
	end
	return count
end

function AICore:AlliedUnitsAlive( entity )
	local allies = FindUnitsInRadius( entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, 99999, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false )
	
	local count = 0
	
	for _,ally in pairs(allies) do
		if ally:IsAlive() and ally ~= entity then
			count = count + 1
		end
	end
	return count
end

function AICore:WeakestAlliedUnitInRange( entity, range , magic_immune)
	local flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
	if magic_immune then
		flags = flags + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	local allies = FindUnitsInRadius( entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, flags, 0, false )

	local minHP = nil
	local target = nil

	for _,ally in pairs(allies) do
		local distanceToEnemy = (entity:GetAbsOrigin() - ally:GetAbsOrigin()):Length2D()
		local HP = ally:GetHealth()
		if ally:IsAlive() and (minHP == nil or HP < minHP) and distanceToEnemy < range then
			minHP = HP
			target = ally
		end
	end
	if entity:GetTauntTarget() then 
		target = entity:GetTauntTarget()
	end
	return target
end

function AICore:SpecificAlliedUnitsInRange( entity, name, range )
	local enemies = FindUnitsInRadius( entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false )
	
	for _,enemy in pairs(enemies) do
		if enemy:IsAlive() and enemy ~= entity and (enemy:GetUnitName() == name or enemy:GetName() == name or enemy:GetUnitLabel() == name) then
			return true
		end
	end
	return false
end

function AICore:SpecificAlliedUnitsAlive( entity, name )
	local enemies = FindUnitsInRadius( entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, 99999, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false )
	
	local count = 0
	
	for _,enemy in pairs(enemies) do
		if enemy:IsAlive() and enemy ~= entity and (enemy:GetUnitName() == name or enemy:GetName() == name or enemy:GetUnitLabel() == name) then
			count = count + 1
		end
	end
	return count
end

function AICore:EnemiesInLine(entity, range, width, magic_immune)
	local flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
	if magic_immune then
		flags = flags + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	local enemies = FindUnitsInLine(entity:GetTeamNumber(), entity:GetAbsOrigin(),  entity:GetAbsOrigin() + entity:GetForwardVector()*range, nil, width, DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flags)
	if #enemies > 0 then
		if entity:GetTauntTarget() then
			return HasValInTable(enemies, entity:GetTauntTarget())
		end
		return true
	else
		return false
	end
end

function AICore:NumEnemiesInLine(entity, range, width, magic_immune)
	local flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
	if magic_immune then
		flags = flags + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	local enemies = FindUnitsInLine(entity:GetTeamNumber(), entity:GetAbsOrigin(),  entity:GetAbsOrigin() + entity:GetForwardVector()*range, nil, width, DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flags)
	return #enemies
end

function AICore:WeakestEnemyHeroInRange( entity, range , magic_immune)
	local flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
	if magic_immune then
		flags = flags + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	if entity:GetTauntTarget() then return entity:GetTauntTarget() end
	local enemies = FindUnitsInRadius( entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flags, 0, false )

	local minHP = nil
	local target = nil

	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (entity:GetAbsOrigin() - enemy:GetAbsOrigin()):Length2D()
		local HP = enemy:GetHealth()
		if enemy:IsAlive() and (minHP == nil or HP < minHP) and distanceToEnemy < range then
			minHP = HP
			target = enemy
		end
	end
	if entity:GetTauntTarget() then 
		target = entity:GetTauntTarget()
	end
	return target
end

function AICore:StrongestEnemyHeroInRange( entity, range , magic_immune)
	local flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
	if magic_immune then
		flags = flags + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	if entity:GetTauntTarget() then return entity:GetTauntTarget() end
	local enemies = FindUnitsInRadius( entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flags, 0, false )

	local minHP = nil
	local target = nil

	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (entity:GetAbsOrigin() - enemy:GetAbsOrigin()):Length2D()
		local HP = enemy:GetHealth()
		if enemy:IsAlive() and (minHP == nil or HP > minHP) and distanceToEnemy < range then
			minHP = HP
			target = enemy
		end
	end
	if entity:GetTauntTarget() then 
		target = entity:GetTauntTarget()
	end
	return target
end

function AICore:HighestThreatHeroInRange(entity, range, basethreat, magic_immune)
	local flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
	if magic_immune then
		flags = flags + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	if entity:GetTauntTarget() then return entity:GetTauntTarget() end
    local enemies = FindUnitsInRadius( entity:GetTeamNumber(), entity:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flags, 0, false )

	local target = nil
	local minThreat = basethreat
	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (entity:GetAbsOrigin() - enemy:GetAbsOrigin()):Length2D()
		if not enemy.threat then enemy.threat = 0 end
		local threat = enemy.threat
		if enemy:IsAlive() and (minThreat == nil or threat > minThreat) and distanceToEnemy < range then
			minThreat = threat
			target = enemy
		end
	end
	if entity:GetTauntTarget() then 
		target = entity:GetTauntTarget()
	end
	return target
end

function AICore:CreateBehaviorSystem( behaviors )
	local BehaviorSystem = {}

	BehaviorSystem.possibleBehaviors = behaviors
	BehaviorSystem.thinkDuration = 1.0
	BehaviorSystem.repeatedlyIssueOrders = true -- if you're paranoid about dropped orders, leave this true

	BehaviorSystem.currentBehavior =
	{
		endTime = 0,
		order = { OrderType = DOTA_UNIT_ORDER_NONE }
	}

	function BehaviorSystem:Think()
		if GameRules:GetGameTime() >= self.currentBehavior.endTime then
			local newBehavior = self:ChooseNextBehavior()
			if newBehavior == nil then 
				-- Do nothing here... this covers possible problems with ChooseNextBehavior
			elseif newBehavior == self.currentBehavior then
				self.currentBehavior:Continue()
			else
				if self.currentBehavior.End then self.currentBehavior:End() end
				self.currentBehavior = newBehavior
				self.currentBehavior:Begin()
			end
		end

		if self.currentBehavior.order and self.currentBehavior.order.OrderType ~= DOTA_UNIT_ORDER_NONE then
			if self.repeatedlyIssueOrders or
				self.previousOrderType ~= self.currentBehavior.order.OrderType or
				self.previousOrderTarget ~= self.currentBehavior.order.TargetIndex or
				self.previousOrderPosition ~= self.currentBehavior.order.Position then

				-- Keep sending the order repeatedly, in case we forgot >.<
				ExecuteOrderFromTable( self.currentBehavior.order )
				self.previousOrderType = self.currentBehavior.order.OrderType
				self.previousOrderTarget = self.currentBehavior.order.TargetIndex
				self.previousOrderPosition = self.currentBehavior.order.Position
			end
		end

		if self.currentBehavior.Think then self.currentBehavior:Think(self.thinkDuration) end

		return self.thinkDuration
	end

	function BehaviorSystem:ChooseNextBehavior()
		local result = nil
		local bestDesire = nil
		for _,behavior in pairs( self.possibleBehaviors ) do
			local thisDesire = behavior:Evaluate()
			if bestDesire == nil or thisDesire > bestDesire then
				result = behavior
				bestDesire = thisDesire
			end
		end

		return result
	end

	function BehaviorSystem:Deactivate()
		print("End")
		if self.currentBehavior.End then self.currentBehavior:End() end
	end

	return BehaviorSystem
end

---
---

function CDOTA_BaseNPC:GetAIBehavior()
	self.AIbehavior = self.AIbehavior or RandomInt(1,3)
	return self.AIbehavior
end