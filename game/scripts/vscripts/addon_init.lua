if IsClient() then -- Load clientside utility lib
	require("libraries/client_util")
	AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
	print("triggered")
end