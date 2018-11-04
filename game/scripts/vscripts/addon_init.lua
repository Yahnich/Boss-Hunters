HP_PER_STR = 18
MR_PER_STR = 0.4
HP_REGEN_PER_STR = 0.025
MANA_PER_INT = 10
MANA_REGEN_PER_INT = 0.035
ARMOR_PER_AGI = 0.07
ATKSPD_PER_AGI = 0.08
DMG_PER_AGI = 0.5
CDR_PER_INT = 0.385
SPELL_AMP_PER_INT = 0.0075

if IsClient() then -- Load clientside utility lib
	print("client-side has been initialized")
	require("libraries/client_util")
	
	
	if GameRules == nil then
		GameRules = class({})
	end
	GameRules.IsDaytime = function()
		local timeofday = CustomNetTables:GetTableValue( "game_info", "timeofday")
		return tonumber(timeofday["timeofday"]) == 1
	end
	
	GameRules.IsTemporaryNight = function()
		local timeofday = CustomNetTables:GetTableValue( "game_info", "timeofday")
		return tonumber(timeofday["timeofday"]) == 2
	end
	
	GameRules.IsNightstalkerNight = function()
		local timeofday = CustomNetTables:GetTableValue( "game_info", "timeofday")
		return tonumber(timeofday["timeofday"]) == 3
	end
	print( "initialized gamerules", GameRules, GameRules.IsDaytime )
	Convars:RegisterCommand( "cl_deepdebugging", function()
													if not GameRules.DebugCalls then
														print("Starting DebugCalls")
														GameRules.DebugCalls = true

														debug.sethook(function(...)
															local info = debug.getinfo(2)
															local src = tostring(info.short_src)
															local name = tostring(info.name)
															if name ~= "__index" then
																print("Call: ".. src .. " -- " .. name)
															end
														end, "c")
													else
														print("Stopped DebugCalls")
														GameRules.DebugCalls = false
														debug.sethook(nil, "c")
													end
												end, "fixing bug",0)
end

require("templates/relic_base_class")
require("templates/item_base_class")