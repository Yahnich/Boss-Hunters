--[[
Broodking AI
]]

require( "ai/ai_core" )

-- GENERIC AI FOR SIMPLE CHASE ATTACKERS

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 0.25 )
end


function AIThink()
	if not thisEntity:IsDominated() then
		AICore:AttackHighestPriority( thisEntity )
		return 0.25
	else return 0.25 end
end