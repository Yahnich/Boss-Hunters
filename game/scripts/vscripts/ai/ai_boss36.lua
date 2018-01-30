require( "ai/ai_core" )
if IsServer() then
	function Spawn( entityKeyValues )
		Timers:CreateTimer(function()
			local origin = Vector(-545,-2367 )
			thisEntity:SetAbsOrigin( origin )
			FindClearSpaceForUnit(thisEntity, origin, true)
			
			if GameRules.gameDifficulty > 2 then 
				thisEntity:SetBaseMaxHealth(5000)
				thisEntity:SetMaxHealth(5000)
				thisEntity:SetHealth(5000)
			elseif GameRules.gameDifficulty <= 2 then 
				thisEntity:SetBaseMaxHealth(3500)
				thisEntity:SetMaxHealth(3500)
				thisEntity:SetHealth(3500)
			end
		end)
	end
end