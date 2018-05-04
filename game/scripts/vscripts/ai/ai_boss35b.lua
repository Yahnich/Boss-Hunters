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
	
end

function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		if not thisEntity:HasModifier("modifier_boss_doom_demonic_servants_checker") then
			if AICore:BeingAttacked( thisEntity ) > 0 or thisEntity.previousHealth > thisEntity:GetHealth() then
				AICore:BeAHugeCoward( thisEntity, 300 )
				goto done
			else
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
					Position = thisEntity:GetOwnerEntity():GetAbsOrigin() + CalculateDirection(thisEntity, thisEntity:GetOwnerEntity()) * 450
				})
				goto done
			end
		else
			AICore:RunToRandomPosition( thisEntity, 20 )
			goto done
		end
	end
	::done::
	thisEntity.previousHealth = thisEntity:GetHealth()
	return AI_THINK_RATE
end

