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
	thisEntity.dance = thisEntity:FindAbilityByName("nightcrawler_shadowdance")
	thisEntity.pounce = thisEntity:FindAbilityByName("lesser_nightcrawler_pounce")
	local target = AICore:HighestThreatHeroInRange( thisEntity, 9000 , 15, true)
	if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity, 9000, true ) end
	if target then
		ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = target:entindex()
			})
	else
		AICore:AttackHighestPriority( thisEntity )
	end
	thisEntity.prevHP = thisEntity:GetHealth()
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		local hp = thisEntity:GetHealth()
		if not thisEntity.prevHP then thisEntity.prevHP = hp end
		if (hp < thisEntity.prevHP*0.6 or hp < thisEntity:GetMaxHealth()*0.4) and thisEntity.dance:IsFullyCastable() then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.dance:entindex()
			})
			local reverseDir = thisEntity:GetForwardVector() * -1
			thisEntity:SetForwardVector(reverseDir)
			local duration = thisEntity.dance:GetSpecialValueFor("duration")
			local movespeed = thisEntity:GetIdealSpeed()
			ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION ,
					Position = thisEntity:GetForwardVector()*duration*movespeed
				})
			if thisEntity.pounce:IsFullyCastable() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.pounce:entindex()
				})
			end
			return duration
		end
			local radius = thisEntity.pounce:GetSpecialValueFor("pounce_radius")
			local range = thisEntity.pounce:GetSpecialValueFor("pounce_distance")
			if AICore:EnemiesInLine(thisEntity, range, radius, true) and thisEntity.pounce:IsFullyCastable() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.pounce:entindex()
				})
				return AI_THINK_RATE
			end
			local target = AICore:HighestThreatHeroInRange(thisEntity, 9000, 15, true)
			if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity, 9000, true) end
			if target then
				local distance = (thisEntity:GetOrigin() - target:GetOrigin()):Length2D()
				local direction = (thisEntity:GetOrigin() - target:GetOrigin()):Normalized()
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = target:entindex()
				})
				if distance > 1000 and thisEntity.pounce:IsFullyCastable() then 
					thisEntity:SetForwardVector(direction)
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.pounce:entindex()
					})
					return AI_THINK_RATE
				end
			else
				return AICore:AttackHighestPriority( thisEntity )
			end
		thisEntity.prevHP = thisEntity:GetHealth()
		return AI_THINK_RATE
	else return AI_THINK_RATE end
end