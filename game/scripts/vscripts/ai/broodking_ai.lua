--[[
Broodking AI
]]

function Spawn( entityKeyValues )
	AICore:ManageThreat(thisEntity)
	thisEntity:SetContextThink( "BroodkingThink", BroodkingThink, 0.25 )
end


function BroodkingThink()
	AICore:ManageThreat(thisEntity)
end