if IsClient() then -- Load clientside utility lib
	require("libraries/client_util")

	if ClientGameMode == nil then
		ClientGameMode = class({})
		print("T R I G G E R E D")
	end

	--[[
		Here is where we run the code that occurs when the game starts
		This is run once the engine has launched
		Some useful things to do here:
		Set the hero selection time. Make this 0.0 if you have you rown hero selection system (like wc3 taverns)
			GameRules:SetHeroSelectionTime( [time] )
	]]--
	function ClientGameMode:InitGameMode()
		GameRules.UnitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")
	
		--Load unit KVs into main kv
		MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_heroes_custom.txt"))
		MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_heroes.txt"))
		MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_units.txt"))
		
		GameRules.AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
		MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/npc_abilities.txt"))
		MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/npc_items_custom.txt"))
		MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/items.txt"))
	end
end