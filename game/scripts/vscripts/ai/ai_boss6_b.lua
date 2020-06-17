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
	thisEntity.curse = thisEntity:FindAbilityByName("boss_slark_blood_curse")
	thisEntity.gift = thisEntity:FindAbilityByName("boss_slark_gift_of_the_flayed")
	-- local target = AICore:WeakestEnemyHeroInRange( thisEntity, 9000, true )
	-- if target then
		-- ExecuteOrderFromTable({
				-- UnitIndex = thisEntity:entindex(),
				-- OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				-- TargetIndex = target:entindex()
			-- })
	-- else
		-- AICore:AttackHighestPriority( thisEntity )
	-- end
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		local target = AICore:GetHighestPriorityTarget(thisEntity)
		local leashTarget
		for _, enemy in ipairs( thisEntity:FindEnemyUnitsInRadius( thisEntity:GetAbsOrigin(), thisEntity.curse:GetTrueCastRange() ) ) do
			if enemy:HasModifier("modifier_boss_slark_leap_tether") then
				leashTarget = enemy
				break
			end
		end
		if not leashTarget then
			leashTarget = RollPercentage(20) and target
		end
		if thisEntity.curse:IsFullyCastable() and leashTarget then
			return CastBloodCurse( leashTarget:GetAbsOrigin() + leashTarget:GetForwardVector() * math.min( leashTarget:GetIdealSpeed(), thisEntity.curse:GetSpecialValueFor("radius") - 25 ) )
		end
		if thisEntity.gift:IsFullyCastable() and AICore:NumEnemiesInLine(thisEntity, thisEntity.gift:GetSpecialValueFor("distance"), thisEntity.gift:GetSpecialValueFor("end_width")/2) > 0 then
			return CastGiftOfTheFlayed()
		end
		return AICore:AttackHighestPriority( thisEntity )
	else return AI_THINK_RATE end
end

function CastBloodCurse(position)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.curse:entindex()
	})
	return thisEntity.curse:GetCastPoint() + 0.1
end

function CastGiftOfTheFlayed()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.gift:entindex()
	})
	return thisEntity.gift:GetCastPoint() + 0.1
end