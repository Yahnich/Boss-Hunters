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
		
		-- AICore:AttackHighestPriority( thisEntity )
		return AI_THINK_RATE
	else
		return AI_THINK_RATE
	end
end