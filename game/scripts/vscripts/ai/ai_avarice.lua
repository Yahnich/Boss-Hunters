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
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		local newPos = AICore:BeAHugeCoward( thisEntity, 600 )
		local timeTaken = CalculateDistance( newPos, thisEntity:GetAbsOrigin() ) / thisEntity:GetIdealSpeed()
		return math.max( timeTaken, 1 )
	else return 1 end
end