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

LinkLuaModifier( "modifier_boss_ascension", "lua_abilities/heroes/modifiers/modifier_boss_ascension.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_illusion_tag", "libraries/modifiers/illusions/modifier_illusion_tag.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_illusion_bonuses", "libraries/modifiers/illusions/modifier_illusion_bonuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_blind_generic", "libraries/modifiers/modifier_blind_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_wearable", "libraries/modifiers/modifier_wearable.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_status_immunity", "libraries/modifiers/modifier_status_immunity.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_paralyze", "libraries/modifiers/modifier_paralyze.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_in_water", "libraries/modifiers/modifier_in_water.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_healing_disable", "libraries/modifiers/modifier_healing_disable.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_summon_handler", "libraries/modifiers/modifier_summon_handler.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_stunned_generic", "libraries/modifiers/modifier_stunned_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_silence_generic", "libraries/modifiers/modifier_silence_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_disarm_generic", "libraries/modifiers/modifier_disarm_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_break_generic", "libraries/modifiers/modifier_break_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_daze_generic", "libraries/modifiers/modifier_daze_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_generic_barrier", "libraries/modifiers/modifier_generic_barrier.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_taunt_generic", "libraries/modifiers/modifier_taunt_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_fear_generic", "libraries/modifiers/modifier_fear_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_chill_generic", "libraries/modifiers/modifier_chill_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_frozen_generic", "libraries/modifiers/modifier_frozen_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_hidden_generic", "libraries/modifiers/modifier_hidden_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_boss_attackspeed", "lua_abilities/heroes/modifiers/modifier_boss_attackspeed.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_boss_damagedecrease", "lua_abilities/heroes/modifiers/modifier_boss_damagedecrease.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_spawn_immunity", "libraries/modifiers/modifier_spawn_immunity.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_tombstone_respawn_immunity", "libraries/modifiers/modifier_tombstone_respawn_immunity.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_generic_attack_bonus", "libraries/modifiers/modifier_generic_attack_bonus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_generic_attack_bonus_pct", "libraries/modifiers/modifier_generic_attack_bonus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_power_scaling", "libraries/modifiers/modifier_power_scaling.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_boss_evasion", "libraries/modifiers/modifier_boss_evasion.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_boss_hard_enrage", "libraries/modifiers/modifier_boss_hard_enrage.lua", LUA_MODIFIER_MOTION_NONE)


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