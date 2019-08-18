--[[
Broodking AI
]]

require( "ai/ai_core" )

-- GENERIC AI FOR SIMPLE CHASE ATTACKERS

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
end


function AIThink(thisEntity)
	if thisEntity and not thisEntity:IsNull() then
		if not thisEntity:IsDominated() then
			if AICore:BeingAttacked( thisEntity ) >= RandomInt(1, 3) then
				AICore:BeAHugeCoward( thisEntity, 600 )
				return 600 / thisEntity:GetIdealSpeed()
			elseif RollPercentage(88) then
				return AICore:AttackHighestPriority( thisEntity )
			else
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
					Position = thisEntity:GetAbsOrigin() + thisEntity:GetForwardVector() * thisEntity:GetAttackRange() * 2 + RandomVector( thisEntity:GetIdealSpeed() / 2 )
				})
				return AI_THINK_RATE
			end
		else return 1 end
	end
end