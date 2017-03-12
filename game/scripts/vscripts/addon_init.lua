if IsClient() then -- Load clientside utility lib
	print("T R I G G E R E D")
	GameRules.UnitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")
	require("libraries/client_util")
	 --Load unit KVs into main kv
	MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_heroes_custom.txt"))
	MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_heroes.txt"))
	MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_units.txt"))
	
	GameRules.AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
	MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/npc_abilities.txt"))
	MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/npc_items_custom.txt"))
	MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/items.txt"))
end