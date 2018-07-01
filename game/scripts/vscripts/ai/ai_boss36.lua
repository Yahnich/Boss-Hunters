require( "ai/ai_core" )
if IsServer() then
	function Spawn( entityKeyValues )
		AITimers:CreateTimer(0.06,function()
			local origin = Vector(969, 132)
			thisEntity:SetAbsOrigin( origin )
			FindClearSpaceForUnit(thisEntity, origin, true)
		end)
	end
end