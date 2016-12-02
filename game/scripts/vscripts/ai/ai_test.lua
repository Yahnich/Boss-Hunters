--[[
Broodking AI
]]

require( "ai/ai_core" )
function Spawn( entityKeyValues )
	POSITIONS_retreat = Entities:FindAllByName( "path_invader1_*" )
	for k,v in pairs(POSITIONS_retreat) do
		POSITIONS_retreat[k] = v:GetOrigin()
	end
	thisEntity:SetContextThink( "AIThinker", AIThink, 10 )
end


function AIThink()
	local picker = math.random(#POSITIONS_retreat)
	ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_HOLD_POSITION,
		})
	
	ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position = POSITIONS_retreat[picker]
		})
	print(POSITIONS_retreat[picker],picker)
	return 10
end