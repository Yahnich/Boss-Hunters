MAXIMUM_ATTACK_SPEED	= 700
MINIMUM_ATTACK_SPEED	= 20

ROUND_END_DELAY = 3

DOTA_LIFESTEAL_SOURCE_NONE = 0
DOTA_LIFESTEAL_SOURCE_ATTACK = 1
DOTA_LIFESTEAL_SOURCE_ABILITY = 2

MAP_CENTER = Vector(332, -1545)
GAME_MAX_LEVEL = 160

GLOBAL_STUN_LIST = {}

if CHoldoutGameMode == nil then
	CHoldoutGameMode = class({})
end


require("lua_map/map")
require("lua_boss/boss_32_meteor")
require( "epic_boss_fight_game_round" )
require( "epic_boss_fight_game_spawner" )

require( "libraries/Timers" )
require( "libraries/notifications" )
require( "statcollection/init" )
require("libraries/utility")
require("libraries/animations")
require("stats_screen")
require("relicmanager")
require( "ai/ai_core" )

LinkLuaModifier( "modifier_illusion_bonuses", "libraries/modifiers/illusions/modifier_illusion_bonuses.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_stats_system_handler", "libraries/modifiers/modifier_stats_system_handler.lua", LUA_MODIFIER_MOTION_NONE)
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
LinkLuaModifier( "modifier_chill_generic", "libraries/modifiers/modifier_chill_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_frozen_generic", "libraries/modifiers/modifier_frozen_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_hidden_generic", "libraries/modifiers/modifier_hidden_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_necrolyte_sadist_aura_reduction", "lua_abilities/heroes/modifiers/modifier_necrolyte_sadist_aura_reduction", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_skeleton_king_reincarnation_cooldown", "lua_abilities/heroes/modifiers/modifier_skeleton_king_reincarnation_cooldown.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_boss_attackspeed", "lua_abilities/heroes/modifiers/modifier_boss_attackspeed.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_boss_damagedecrease", "lua_abilities/heroes/modifiers/modifier_boss_damagedecrease.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_spawn_immunity", "libraries/modifiers/modifier_spawn_immunity.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_tombstone_respawn_immunity", "libraries/modifiers/modifier_tombstone_respawn_immunity.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_generic_attack_bonus", "libraries/modifiers/modifier_generic_attack_bonus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_generic_attack_bonus_pct", "libraries/modifiers/modifier_generic_attack_bonus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_cooldown_reduction_handler", "libraries/modifiers/modifier_cooldown_reduction_handler.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_base_attack_time_handler", "libraries/modifiers/modifier_base_attack_time_handler.lua", LUA_MODIFIER_MOTION_NONE)


-- Precache resources
function Precache( context )
	PrecacheResource( "particle", "particles/range_ability_line.vpcf", context )
	PrecacheResource( "particle", "particles/items3_fx/lotus_orb_shield.vpcf", context )
	PrecacheResource( "particle", "particles/generic_gameplay/generic_stunned.vpcf", context )
	PrecacheResource( "particle", "particles/generic_gameplay/generic_silence.vpcf", context )
	PrecacheResource( "particle", "particles/generic_gameplay/generic_disarm.vpcf", context )
	PrecacheResource( "particle", "particles/generic_gameplay/generic_break.vpcf", context )
	PrecacheResource( "particle", "particles/items_fx/glyph.vpcf", context )
	PrecacheResource( "particle", "particles/generic_dazed_side.vpcf", context )
	PrecacheResource( "particle", "particles/generic_gameplay/generic_slowed_cold.vpcf", context )
	PrecacheResource( "particle", "particles/brd_taunt/brd_taunt_mark_base.vpcf", context )
	PrecacheResource( "particle", "particles/status_fx/status_effect_beserkers_call.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_dire.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_debuff.vpcf", context )
	PrecacheResource( "particle", "particles/econ/events/nexon_hero_compendium_2014/blink_dagger_end_nexon_hero_cp_2014.vpcf", context)

	-- Hero Precaches
	PrecacheUnitByNameSync("npc_dota_warlock_moloch", context)
    PrecacheUnitByNameSync("npc_dota_warlock_naamah", context)
	PrecacheResource("particle", "particles/warlock_deepfire_ember.vpcf", context)
	
	-- UAM particles
	PrecacheResource("particle", "particles/desolator3_projectile.vpcf", context)
	PrecacheResource("particle", "particles/desolator4_projectile.vpcf", context)
	PrecacheResource("particle", "particles/desolator5_projectile.vpcf", context)
	PrecacheResource("particle", "particles/desolator6_projectile.vpcf", context)
	PrecacheResource("particle", "particles/skadi2_projectile.vpcf", context)
	
	-- Relic particles
	PrecacheResource("particle", "particles/relics/relic_cursed_demon_wings_trail.vpcf", context)
	PrecacheResource("particle", "particles/relics/molten_crystal/molten_crystal_fire.vpcf", context)
	
	-- Elite particles
	PrecacheResource("particle", "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", context)
	PrecacheResource("particle", "particles/econ/items/kunkka/kunkka_weapon_whaleblade/kunkka_spell_torrent_splash_whaleblade.vpcf", context)
	PrecacheResource("particle", "particles/econ/courier/courier_onibi/courier_onibi_yellow_ambient_smoke_lvl21.vpcf", context)			
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_enigma.vsndevts" , context)
	PrecacheResource("soundfile", "soundevents/game_sounds_ui.vsndevts" , context)
	PrecacheResource("soundfile", "soundevents/soundevents_dota_ui.vsndevts" , context)
	PrecacheResource("soundfile", "soundevents/game_sound.vsndevts" , context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_crystalmaiden.vsndevts" , context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_ancient_apparition.vsndevts"  , context)
	
	PrecacheResource("particle", "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", context)
	PrecacheResource("particle", "particles/items3_fx/octarine_core_lifesteal.vpcf", context)
	PrecacheResource("particle", "particles/elite_warning.vpcf", context)
	PrecacheResource("particle", "particles/elite_overhead.vpcf", context)
	PrecacheResource("particle", "particles/status_fx/status_effect_frost.vpcf", context)
	
	PrecacheResource("particle", "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf", context)
		
	-- Generic Boss Particles
	PrecacheResource("particle", "particles/nyx_assassin_impale.vpcf", context)
	PrecacheResource("particle", "particles/econ/generic/generic_aoe_shockwave_1/generic_aoe_shockwave_1.vpcf", context)
	PrecacheResource("particle", "particles/generic_aoe_persistent_circle_1/death_timer_glow_rev.vpcf", context)
	PrecacheResource("particle", "particles/econ/generic/generic_aoe_explosion_sphere_1/generic_aoe_explosion_sphere_1.vpcf", context)
	PrecacheResource("particle", "particles/econ/generic/generic_buff_1/generic_buff_1.vpcf", context)
	PrecacheResource("particle", "particles/generic_gameplay/generic_stunned.vpcf", context)
	PrecacheResource("particle", "particles/generic_gameplay/generic_sleep.vpcf", context)
	PrecacheResource("particle", "particles/generic_linear_indicator.vpcf", context)
	PrecacheResource("particle", "particles/generic/generic_marker.vpcf", context)
	
	-- Role Particles
	PrecacheResource("particle", "particles/roles/dev/com_particle.vpcf", context)
	PrecacheResource("particle", "particles/roles/dev/dev_particle.vpcf", context)
	PrecacheResource("particle", "particles/roles/dev/vip_particle.vpcf", context)
	
	-- fix these fucking particles
	PrecacheResource("particle", "particles/units/heroes/hero_tinker/tinker_rockets.vpcf", context)
	PrecacheResource("particle", "particles/econ/items/tinker/tinker_motm_rollermaw/tinker_rollermaw_spawn.vpcf", context)
	PrecacheResource("particle", "particles/econ/items/tinker/tinker_motm_rollermaw/tinker_rollermaw_motm.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_tinker/tinker_missile.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_tinker/tinker_missile_dud.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_tinker/tinker_machine.vpcf", context)
	
	PrecacheResource("particle", "particles/death_spear.vpcf", context)
	PrecacheResource("particle", "particles/boss/boss_shadows_orb.vpcf", context)
	PrecacheResource("particle", "particles/dark_orb.vpcf", context)
	
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_lone_druid.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_lone_druid/lone_druid_savage_roar.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_lone_druid/lone_druid_savage_roar_debuff.vpcf", context)
	PrecacheResource("particle", "particles/status_fx/status_effect_lone_druid_savage_roar.vpcf", context)
	
	PrecacheResource("particle_folder", "particles/econ/generic/generic_aoe_shockwave_1", context)
	
	local precacheList = LoadKeyValues('scripts/npc/activelist.txt')
	for hero, activated in pairs(precacheList) do
		if activated  == "1" then
			PrecacheUnitByNameSync(hero, context)
		end
	end
end

-- Actually make the game mode when we activate
function Activate()
	GameRules.holdOut = CHoldoutGameMode()
	GameRules.holdOut:InitGameMode()
	require("projectilemanager")
	-- require('statsmanager')
end

function CHoldoutGameMode:InitGameMode()
	print ("Epic Boss Fight Loaded")
	GameRules._finish = false
	GameRules.vote_Yes = 0
	GameRules.vote_No = 0
	GameRules.gameDifficulty = 1
	GameRules.voteRound_Yes = 0;
	GameRules.voteRound_No = 0;
	GameRules.voteTableDifficulty = {};
	GameRules.voteTableLives = {};
	
	GameRules._Elites = LoadKeyValues( "scripts/kv/elites.kv" )
	
	GameRules.UnitKV = LoadKeyValues("scripts/npc/npc_heroes.txt")
	MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_heroes_custom.txt"))
	MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_units.txt"))
	MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_units_custom.txt"))
	
	GameRules.AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
	MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/npc_abilities_override.txt"))
	MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/npc_items_custom.txt"))
	MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/items.txt"))
	
	GameRules.HeroList = LoadKeyValues("scripts/npc/activelist.txt")
	
	print(GetMapName())
	
	GameRules.playersDisconnected = 0
	self._nRoundNumber = 1
	GameRules._roundnumber = 1
	self._NewGamePlus = false
	self._message = false
	self.Last_Target_HB = nil
	self.Shield = false
	self.Last_HP_Display = -1
	self._currentRound = nil
	self._regenround25 = false
	self._regenround13 = false
	self._regenNG = false
	self._check_check_dead = false
	self._flLastThinkGameTime = nil
	self._check_dead = false
	self._timetocheck = 0
	self._freshstart = true
	self.boss_master_id = -1
	GameRules.boss_master_id = -1
	
	GameRules._maxLives = 10
	GameRules:SetHeroSelectionTime( 80.0 )
	GameRules:SetPreGameTime( 30.0 )
	GameRules:SetShowcaseTime( 0 )
	GameRules:SetStrategyTime( 0 )
	GameRules:SetCustomGameSetupAutoLaunchDelay( 0 ) -- fix valve bullshit
	
	local mapInfo = LoadKeyValues( "addoninfo.txt" )[GetMapName()]
	
	GameRules.BasePlayers = mapInfo.MaxPlayers
	GameRules._maxLives =  mapInfo.Lives
	GameRules.gameDifficulty =  mapInfo.Difficulty
	CustomNetTables:SetTableValue( "game_info", "difficulty", {difficulty = GameRules.gameDifficulty} )
	CustomNetTables:SetTableValue( "game_info", "timeofday", {timeofday = 0} )
	
	GameRules._used_life = 0
	GameRules._life = GameRules._maxLives
	
	CustomGameEventManager:Send_ServerToAllClients( "updateQuestLife", { lives = GameRules._life, maxLives = GameRules._maxLives } )
	
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, mapInfo.MaxPlayers)
	if GetMapName() == "epic_boss_fight_boss_master" then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 1 )
	else 
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )
	end
	GameRules._life = GameRules._maxLives
	
	self:_ReadGameConfiguration()
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetUseUniversalShopMode( true )

	GameRules:SetTreeRegrowTime( 30.0 )
	GameRules:SetCreepMinimapIconScale( 4 )
	GameRules:SetRuneMinimapIconScale( 1.5 )
	GameRules:SetGoldTickTime( 1 )
	GameRules:SetGoldPerTick( 1 )
	GameRules:GetGameModeEntity():SetRemoveIllusionsOnDeath( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	GameRules:GetGameModeEntity():SetCustomBuybackCooldownEnabled(true)
	GameRules:GetGameModeEntity():SetCustomBuybackCostEnabled(true)
	GameRules:GetGameModeEntity():SetCameraDistanceOverride(1400)
	-- GameRules:GetGameModeEntity():SetCustomGameForceHero("npc_dota_hero_wisp")
	GameRules.XP_PER_LEVEL = {100,
					200}
	for i = 3, GAME_MAX_LEVEL do
		GameRules.XP_PER_LEVEL[i] = GameRules.XP_PER_LEVEL[i-1] + i * 100
	end

	GameRules:GetGameModeEntity():SetUseCustomHeroLevels( true )
    GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel( GameRules.XP_PER_LEVEL )
	
	GameRules:GetGameModeEntity():SetMaximumAttackSpeed(MAXIMUM_ATTACK_SPEED)
	GameRules:GetGameModeEntity():SetMinimumAttackSpeed(MINIMUM_ATTACK_SPEED)
	
	-- Custom console commands
	Convars:RegisterCommand( "holdout_test_round", function(...) return self:_TestRoundConsoleCommand( ... ) end, "Test a round of holdout.", FCVAR_CHEAT )
	Convars:RegisterCommand( "game_tools_ask_nettable_info", function()
																local player = Convars:GetDOTACommandClient()
																Timers:CreateTimer(function()
																	if not player or player:IsNull() then return end
																	CustomGameEventManager:Send_ServerToPlayer( player, "game_tools_ask_nettable_info", {} )
																	return 1
																end)
															end, "test",0)
	Convars:RegisterCommand( "clear_relics", function()
											if Convars:GetDOTACommandClient() and IsInToolsMode() then
												local player = Convars:GetDOTACommandClient()
												RelicManager:ClearRelics(player:GetPlayerID(), true) 
											end
										end, "adding relics",0)
	Convars:RegisterCommand( "add_relic", function(command, relicName)
											if Convars:GetDOTACommandClient() and IsInToolsMode() then
												local player = Convars:GetDOTACommandClient()
												local hero = player:GetAssignedHero()
												print(relicName, "ok")
												hero:AddRelic(relicName)
											end
										end, "adding relics",0)
	Convars:RegisterCommand( "roll_relics", function(command, relicName)
											if Convars:GetDOTACommandClient() and IsInToolsMode() then
												local player = Convars:GetDOTACommandClient()
												local hero = player:GetAssignedHero()
												RelicManager:RollRelicsForPlayer( player:GetPlayerID() )
											end
										end, "adding relics",0)
	Convars:RegisterCommand( "getdunked", function()
											if Convars:GetDOTACommandClient() then
												local player = Convars:GetDOTACommandClient()
												local hero = player:GetAssignedHero() 
												hero:ForceKill(true)
											end
										end, "fixing bug",0)
	Convars:RegisterCommand( "deepdebugging", function()
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
														
	Convars:RegisterCommand( "spawn_elite", function(...) if IsInToolsMode() then return self.SpawnTestElites( ... ) end end, "look like someone try to steal my map :D",0)
	
	-- Hook into game events allowing reload of functions at run time
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( CHoldoutGameMode, "OnNPCSpawned" ), self )
	ListenToGameEvent( "player_disconnect", Dynamic_Wrap( CHoldoutGameMode, 'OnPlayerDisconnected' ), self )
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( CHoldoutGameMode, 'OnEntityKilled' ), self )
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( CHoldoutGameMode, "OnGameRulesStateChange" ), self )
	ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap( CHoldoutGameMode, "OnHeroPick"), self )
    ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(CHoldoutGameMode, 'OnAbilityUsed'), self)
	ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(CHoldoutGameMode, 'OnAbilityLearned'), self)
	ListenToGameEvent( "dota_player_gained_level", Dynamic_Wrap( CHoldoutGameMode, "OnHeroLevelUp" ), self )
	
	
	
	-- CustomGameEventManager:RegisterListener('Boss_Master', Dynamic_Wrap( CHoldoutGameMode, 'Boss_Master'))
	CustomGameEventManager:RegisterListener('Demon_Shop', Dynamic_Wrap( CHoldoutGameMode, 'Buy_Demon_Shop_check'))
	CustomGameEventManager:RegisterListener('Tell_Threat', Dynamic_Wrap( CHoldoutGameMode, 'Tell_threat'))
	CustomGameEventManager:RegisterListener('Buy_Perk', Dynamic_Wrap( CHoldoutGameMode, 'Buy_Perk_check'))
	CustomGameEventManager:RegisterListener('Asura_Core', Dynamic_Wrap( CHoldoutGameMode, 'Buy_Asura_Core_shop'))
	CustomGameEventManager:RegisterListener('Tell_Core', Dynamic_Wrap( CHoldoutGameMode, 'Asura_Core_Left'))
	
	
	CustomGameEventManager:RegisterListener('preGameVoting', Dynamic_Wrap( CHoldoutGameMode, 'PreGameVotingHandler'))

	CustomGameEventManager:RegisterListener('mute_sound', Dynamic_Wrap( CHoldoutGameMode, 'mute_sound'))
	CustomGameEventManager:RegisterListener('unmute_sound', Dynamic_Wrap( CHoldoutGameMode, 'unmute_sound'))
	CustomGameEventManager:RegisterListener('Health_Bar_Command', Dynamic_Wrap( CHoldoutGameMode, 'Health_Bar_Command'))

	CustomGameEventManager:RegisterListener('Vote_NG', Dynamic_Wrap( CHoldoutGameMode, 'vote_NG_fct'))
	CustomGameEventManager:RegisterListener('Vote_Round', Dynamic_Wrap( CHoldoutGameMode, 'vote_Round'))
	
	CustomGameEventManager:RegisterListener('playerUILoaded', Dynamic_Wrap( CHoldoutGameMode, 'OnPlayerUIInitialized'))

	-- Register OnThink with the game engine so it is called every 0.25 seconds
	GameRules:GetGameModeEntity():SetDamageFilter( Dynamic_Wrap( CHoldoutGameMode, "FilterDamage" ), self )
	GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( CHoldoutGameMode, "FilterOrders" ), self )
	GameRules:GetGameModeEntity():SetHealingFilter( Dynamic_Wrap( CHoldoutGameMode, "FilterHeal" ), self )
	GameRules:GetGameModeEntity():SetModifierGainedFilter( Dynamic_Wrap( CHoldoutGameMode, "FilterModifiers" ), self )
	GameRules:GetGameModeEntity():SetAbilityTuningValueFilter( Dynamic_Wrap( CHoldoutGameMode, "FilterAbilityValues" ), self )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, 1 )
	
	StatsScreen:StartStatsScreen()
	RelicManager:Initialize()
end

function CHoldoutGameMode:vote_Round (event)
 	local ID = event.pID
 	local vote = event.vote
 	local player = PlayerResource:GetPlayer(ID)

 	if player~= nil then
	 	if vote == 1 then
	 		GameRules.voteRound_Yes = GameRules.voteRound_Yes + 1
			GameRules.voteRound_No = GameRules.voteRound_No - 1

			local event_data =
			{
				No = GameRules.voteRound_No,
				Yes = GameRules.voteRound_Yes,
			}
			CustomGameEventManager:Send_ServerToAllClients("RoundVoteResults", event_data)
		end
	end
end

function CHoldoutGameMode:FilterModifiers( filterTable )
	local parent_index = filterTable["entindex_parent_const"]
    local caster_index = filterTable["entindex_caster_const"]
	local ability_index = filterTable["entindex_ability_const"]
    if not parent_index or not caster_index or not ability_index then
        return true
    end
	local duration = filterTable["duration"]
    local parent = EntIndexToHScript( parent_index )
    local caster = EntIndexToHScript( caster_index )
	local ability = EntIndexToHScript( ability_index )
	local name = filterTable["name_const"]
	if parent and caster and duration ~= -1 then
		local params = {caster = caster, target = parent, duration = duration, ability = ability, modifier_name = name}
		for _, modifier in ipairs( caster:FindAllModifiers() ) do
			if modifier.GetModifierStatusAmplify_Percentage then
				filterTable["duration"] = filterTable["duration"] * (1 + modifier:GetModifierStatusAmplify_Percentage( params )/100)
			end
			if modifier.OnModifierAdded then
				modifier:GetModifierStatusAmplify_Percentage( params )
			end
		end
		if parent:GetTeam() ~= caster:GetTeam() then
			local resistance = 0
			local stackResist = 0
			for _, modifier in ipairs( parent:FindAllModifiers() ) do
				if modifier.GetModifierStatusResistanceStacking and modifier:GetModifierStatusResistanceStacking(params) then
					stackResist = stackResist + modifier:GetModifierStatusResistanceStacking(params)
				end
				if modifier.GetModifierStatusResistance and modifier:GetModifierStatusResistance(params) and modifier:GetModifierStatusResistance(params) > resistance then
					resistance = modifier:GetModifierStatusResistance( params )
				end
			end
			filterTable["duration"] = filterTable["duration"] * (1 - resistance/100) * (1 - stackResist/100)
		end
	end
	if filterTable["duration"] == 0 then return false end
	return true
end

function CHoldoutGameMode:FilterAbilityValues( filterTable )
    local caster_index = filterTable["entindex_caster_const"]	
	local ability_index = filterTable["entindex_ability_const"]
    if not caster_index or not ability_index then
        return true
    end
	local caster = EntIndexToHScript( caster_index )
    local ability = EntIndexToHScript( ability_index )
	
	if caster:GetName() == "npc_dota_hero_queenofpain" and caster:HasAbility(ability:GetName()) then
		require('lua_abilities/heroes/queenofpain')
		filterTable = SadoMasochism(filterTable)
	end
	return true
end

function CHoldoutGameMode:FilterHeal( filterTable )
	local healer_index = filterTable["entindex_healer_const"]
	local target_index = filterTable["entindex_target_const"]
	local source_index = filterTable["entindex_inflictor_const"]
	local heal = filterTable["heal"]
	local healer, target, source
	
	if healer_index then healer = EntIndexToHScript( healer_index ) end
	if target_index then target = EntIndexToHScript( target_index ) end
	if source_index then source = EntIndexToHScript( source_index ) end
	
	-- if no caster then source is regen
	if source then
		local params = {healer = healer, target = target, heal = heal, ability = source}
		if target then
			for _, modifier in ipairs( target:FindAllModifiers() ) do
				if modifier.GetModifierHealAmplify_Percentage then
					filterTable["heal"] = filterTable["heal"] * math.max(0, (1 + ( modifier:GetModifierHealAmplify_Percentage( params ) or 0 )/100) )
				end
			end
		end
		if healer and healer ~= target then
			for _, modifier in ipairs( healer:FindAllModifiers() ) do
				if modifier.GetModifierHealAmplify_Percentage then
					filterTable["heal"] = filterTable["heal"] * math.max(0, (1 + ( modifier:GetModifierHealAmplify_Percentage( params ) or 0 )/100) )
				end
			end
		end
	end

	if not healer_index or not heal then return true end
	healer.statsDamageHealed = (healer.statsDamageHealed or 0) + filterTable["heal"]
	
	if healer and healer:IsRealHero() and target and healer ~= target and healer:HasRelic("relic_cursed_bloody_silk") then
		target:HealEvent(50, nil, healer, true)
		if not self:GetParent():HasModifier("relic_unique_ritual_candle") then ApplyDamage({victim = healer, attacker = healer, damage = 20, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION }) end
	end
	
	if healer:GetTeam() == DOTA_TEAM_GOODGUYS then
		local totalHealth = 0
		for _, ally in ipairs( healer:FindFriendlyUnitsInRadius( healer:GetAbsOrigin(), -1 ) ) do
			totalHealth = totalHealth + ally:GetMaxHealth()
		end
		healer:ModifyThreat( math.max( target:GetHealthDeficit(), filterTable["heal"] ) / totalHealth)
	end
	
	return true
end

function CHoldoutGameMode:FilterOrders( filterTable )
	if filterTable["order_type"] == DOTA_UNIT_ORDER_TRAIN_ABILITY then
		local talent = EntIndexToHScript( filterTable["entindex_ability"] )
		if talent and string.match( talent:GetAbilityName(), "special_bonus" ) and hero:GetLevel() < (hero.talentsSkilled + 1) * 10 then
			return false
		end
	end
	return true
end

function CHoldoutGameMode:FilterDamage( filterTable )
    local total_damage_team = 0
    local dps = 0
    local victim_index = filterTable["entindex_victim_const"]
    local attacker_index = filterTable["entindex_attacker_const"]
    if not victim_index or not attacker_index then
        return true
    end
	
	local damage = filterTable["damage"] --Post reduction
	local inflictor = filterTable["entindex_inflictor_const"]
    local victim = EntIndexToHScript( victim_index )
    local attacker = EntIndexToHScript( attacker_index )
	local ability = (inflictor ~= nil) and EntIndexToHScript( inflictor )
	local original_attacker = attacker -- make a copy for threat
    local damagetype = filterTable["damagetype_const"]

	if damage <= 0 then return true end
	
	-- VVVVVVVVVVVVVV REMOVE THIS SHIT IN THE FUTURE VVVVVVVVVVV --
	if attacker:IsControllableByAnyPlayer() and not (attacker:IsFakeHero() or attacker:IsCreature() or attacker:IsCreep() or attacker:IsHero()) then 
		if attacker:GetOwner():GetClassname() == player then
			attacker = attacker:GetOwner():GetAssignedHero()
		else
			attacker = attacker:GetOwner()
		end
	end
	
	if attacker:HasModifier("relic_unique_eldritch_rune") and inflictor then
		if damagetype == DAMAGE_TYPE_PHYSICAL then
			ApplyDamage({victim = victim, attacker = attacker, damage = damage * (1- victim:GetPhysicalArmorReduction() / 100 ), damage_type = DAMAGE_TYPE_MAGICAL})
		elseif damagetype == DAMAGE_TYPE_MAGICAL then
			ApplyDamage({victim = victim, attacker = attacker, damage = damage * (1 - victim:GetMagicalArmorValue()), damage_type = DAMAGE_TYPE_PHYSICAL})
		end
		return false
	end
	
	-- CUSTOM DAMAGE PROPERTIES
	-- MODIFIER_PROPERTY_ALLDAMAGE_CONSTANT_BLOCK
	local modifierPropertyAllBlock = victim:GetModifierPropertyValue("MODIFIER_PROPERTY_ALLDAMAGE_CONSTANT_BLOCK")
	if modifierPropertyAllBlock > 0 and victim:IsHero() then
		local damagetype = filterTable["damagetype_const"]
		local block = modifierPropertyAllBlock
		local dmgBlock = damage
		if damagetype == 1 then -- physical
			dmgBlock = damage * (1- victim:GetPhysicalArmorReduction() / 100 )
		elseif damagetype == 2 then -- magical damage
			dmgBlock = damage * (1 - victim:GetMagicalArmorValue())
		elseif damagetype == 4 then -- pure damage
			dmgBlock = damagefilter
		end
		if dmgBlock > block then
			dmgBlock = dmgBlock - block
			if damagetype == 1 then -- physical
				dmgBlock = dmgBlock / (1- victim:GetPhysicalArmorReduction() / 100 )
			elseif damagetype == 2 then -- magical damage
				dmgBlock = dmgBlock / (1 - victim:GetMagicalArmorValue())
			end
			SendOverheadEventMessage( victim, OVERHEAD_ALERT_BLOCK, victim, block, victim )
		else
			filterTable["damage"] = 0
			SendOverheadEventMessage( victim, OVERHEAD_ALERT_BLOCK, victim, dmgBlock, victim )
		end
	end
	
	if inflictor and attacker:IsHero() and not attacker:IsCreature() then
		local ability = EntIndexToHScript( inflictor )
		if ability:GetName() == "item_blade_mail" then
			local reflect = ability:GetSpecialValueFor("reflect_pct") / 100
			filterTable["damage"] = filterTable["damage"] * reflect
		end
		if attacker:GetName() == "npc_dota_hero_leshrac" and attacker:HasAbility(ability:GetName()) then -- reapply damage in pure after all amp/crit
			require('lua_abilities/heroes/leshrac')
			filterTable = InnerTorment(filterTable)
		end
	end

	--- THREAT AND UI NO MORE DAMAGE MANIPULATION ---
	local damage = filterTable["damage"]
	local attacker = original_attacker
	if attacker:GetPlayerOwnerID() then 
		local mainHero = PlayerResource:GetSelectedHeroEntity( attacker:GetPlayerOwnerID() )
		if mainHero then 
			mainHero.statsDamageDealt = (mainHero.statsDamageDealt or 0) + math.min(victim:GetHealth(), damage)
		end
	end
	if attacker:IsCreature() then
		victim.statsDamageTaken = (victim.statsDamageTaken or 0) + math.min(victim:GetHealth(), damage)
		return true 
	end
	if not victim:IsHero() and victim ~= attacker then
		local ability
		if inflictor then
			ability = EntIndexToHScript( inflictor )
		end
		if not inflictor or (ability and not ability:HasNoThreatFlag()) then
			if not victim.threatTable then victim.threatTable = {} end
			if not attacker.threat then attacker.threat = 0 end
			local roundCurrTotalHP = 0
			local threatCounter = 0
			for _,unit in pairs(FindAllEntitiesByClassname("npc_dota_creature")) do
				roundCurrTotalHP = roundCurrTotalHP + unit:GetMaxHealth()
				if threatCounter < 3 then
					threatCounter = threatCounter + 1
				end
			end
			local addedthreat = (damage / roundCurrTotalHP)*threatCounter*100
			local threatcheck = (victim:GetHealth() * threatCounter * 100) / roundCurrTotalHP
			if addedthreat > threatcheck then addedthreat = threatcheck end -- remove threat from overkill damage
			attacker:ModifyThreat( addedthreat )
			attacker.lastHit = GameRules:GetGameTime()
			attacker.statsDamageDealt = (attacker.statsDamageDealt or 0) + math.min(victim:GetHealth(), damage)
			PlayerResource:SortThreat()
			local event_data =
			{
				threat = attacker.threat,
				lastHit = attacker.lastHit,
				aggro = attacker.aggro
			}
			local player = attacker:GetPlayerOwner()
			if player then
				CustomGameEventManager:Send_ServerToPlayer( player, "Update_threat", event_data )
			end
		end
	end
    local attackerID = attacker:GetPlayerOwnerID()
    if attackerID and PlayerResource:HasSelectedHero( attackerID ) then
	    local hero = PlayerResource:GetSelectedHeroEntity(attackerID)
	    local player = PlayerResource:GetPlayer(attackerID)
	    local start = false
	    if hero.damageDone == 0 and damage>0 then 
	    	start = true
	    end
	    hero.damageDone = math.floor(hero.damageDone + damage)
	    if start == true then 
	    	start = false
	    	hero.first_damage_time = GameRules:GetGameTime()
	   	end
	   	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
				if PlayerResource:HasSelectedHero( nPlayerID ) then
					local hero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
					if hero then
						total_damage_team = hero.damageDone + total_damage_team	
					end
				end
			end
		end
		GameRules.TeamDamage = total_damage_team
		for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
				if PlayerResource:HasSelectedHero( nPlayerID ) then
					local hero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
					if hero then
						local key = "player_"..hero:GetPlayerID()
					    -- CustomNetTables:SetTableValue( "Damage",key, {Team_Damage = total_damage_team , Hero_Damage = hero.damageDone , First_hit = hero.first_damage_time} )
					end
				end
			end
		end
    end
	
    return true
end


function GetHeroDamageDone(hero)
    return hero.damageDone
end

function update_asura_core(hero)
		local key = "player_"..hero:GetPlayerID()
		CustomNetTables:SetTableValue( "Asura_core",key, {core = hero.Asura_Core} )
end

function CHoldoutGameMode:OnHeroLevelUp(event)
	local playerID = EntIndexToHScript(event.player):GetPlayerID()
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)
	if hero:GetLevel() < 32 then
		if hero:GetLevel() == 17 or hero:GetLevel() == 19 or (hero:GetLevel() > 20 and hero:GetLevel() < 25) then hero:SetAbilityPoints( hero:GetAbilityPoints() + 1) end
		if hero:GetLevel() % GameRules.gameDifficulty == 0 then
			hero:SetAbilityPoints( hero:GetAbilityPoints() + 1)
		end
	end
end

function CHoldoutGameMode:OnAbilityLearned(event)
	local abilityname = event.abilityname
	local pID = event.PlayerID
	if pID and string.match(abilityname, "special_bonus" ) then
		local hero = PlayerResource:GetSelectedHeroEntity( pID )
		
		if hero:GetLevel() < (hero.talentsSkilled + 1) * 10 then
			local talent = hero:FindAbilityByName(abilityname)
			talent:SetLevel(0)
			for _, modifier in ipairs( hero:FindAllModifiers() ) do
				if modifier:GetAbility() then
					if not modifier:GetAbility():IsInnateAbility() and modifier:GetCaster() == hero and not modifier:GetAbility():IsItem() and modifier:GetAbility():GetName() ~= "item_relic_handler" then -- destroy passive modifiers and any buffs
						modifier:Destroy()
					end
				end
			end
			hero:SetAbilityPoints( hero:GetAbilityPoints() + 1 )
			return false
		end
		
		local talentData = CustomNetTables:GetTableValue("talents", tostring(hero:entindex())) or {}
		if GameRules.AbilityKV[abilityname] then
			if GameRules.AbilityKV[abilityname]["LinkedModifierName"] then
				local modifierName = GameRules.AbilityKV[abilityname]["LinkedModifierName"] 
				for _, unit in ipairs( FindAllUnits() ) do
					if unit:HasModifier(modifierName) then
						local mList = unit:FindAllModifiersByName(modifierName)
						for _, modifier in ipairs( mList ) do
							local remainingDur = modifier:GetRemainingTime()
							modifier:ForceRefresh()
							if remainingDur > 0 then modifier:SetDuration(remainingDur, true) end
						end
					end
				end
			end
			if GameRules.AbilityKV[abilityname]["LinkedAbilityName"] then
				local abilityName = GameRules.AbilityKV[abilityname]["LinkedAbilityName"] or ""
				local ability = hero:FindAbilityByName(abilityName)
				if ability and ability.OnTalentLearned then
					ability:OnTalentLearned(abilityname)
				end
			end
		end
		talentData[abilityname] = true
		CustomNetTables:SetTableValue( "talents", tostring(hero:entindex()), talentData )
		hero.talentsSkilled = hero.talentsSkilled + 1
	end
end

function CHoldoutGameMode:OnAbilityUsed(event)
	--will be used in future :p
    local PlayerID = event.PlayerID
    local abilityname = event.abilityname
		
	local hero = PlayerResource:GetSelectedHeroEntity(PlayerID)
	if not hero then return end
	if not abilityname then return end
	local abilityused = hero:FindAbilityByName(abilityname)
	if not abilityused then abilityused = hero:FindItemByName(abilityname, false) end
	if not abilityused then return end
	if abilityused then
		local addedthreat = abilityused:GetThreat()
		local modifier = 0
		local escapemod = 0
		local talentmodifier = 0
		local negtalentmodifier = 0
		if hero:HasTalentType("mp_regen") then
			talentmodifier = hero:HighestTalentTypeValue("mp_regen")
		end
		if hero:HasTalentType("mp") then
			negtalentmodifier = hero:HighestTalentTypeValue("mp")
		end
		if addedthreat < 0 then
			escapemod = 2
		end
		if abilityused and not abilityused:IsItem() then modifier = (addedthreat*abilityused:GetLevel())/abilityused:GetMaxLevel() end
		if not hero.threat then hero.threat = 0 end
		hero:ModifyThreat(addedthreat + modifier + talentmodifier - negtalentmodifier)
		local player = PlayerResource:GetPlayer(PlayerID)
		hero.lastHit = GameRules:GetGameTime() - escapemod
		PlayerResource:SortThreat()
		local event_data =
		{
			threat = hero.threat,
			lastHit = hero.lastHit,
			aggro = hero.aggro
		}
		if player then
			CustomGameEventManager:Send_ServerToPlayer( player, "Update_threat", event_data )
		end
	end
	if abilityused and abilityused:HasPureCooldown() then
		if abilityname == "viper_nethertoxin" and not hero:HasTalent("special_bonus_unique_viper_3") then return end
		abilityused:EndCooldown()
		if abilityused:GetDuration() > 0 then
			local duration = abilityused:GetDuration()
			if abilityname == "night_stalker_crippling_fear" and not GameRules:IsDaytime() then duration = abilityused:GetTalentSpecialValueFor("duration_night") end
			for _, modifier in ipairs( hero:FindAllModifiers() ) do
				if modifier.GetModifierStatusAmplify_Percentage then
					duration = duration * (1 + modifier:GetModifierStatusAmplify_Percentage( params )/100)
				end
			end
			abilityused:StartDelayedCooldown(duration)
		else
			abilityused:StartCooldown(abilityused:GetCooldown(-1))
		end
	end
	if abilityname == "pangolier_shield_crash" then
		hero:AddNewModifier(hero, abilityused, "modifier_pangolier_shield_crash_buff", {duration = abilityused:GetTalentSpecialValueFor("duration")}):SetStackCount( abilityused:GetTalentSpecialValueFor("hero_stacks") )
	end
	if hero:GetName() == "npc_dota_hero_rubick"  and abilityname ~= "rubick_spell_steal" and hero:IsRealHero() then
		local spell_echo = hero:FindAbilityByName("rubick_spell_echo")
		if spell_echo:GetLevel()-1 >= 0 then
			if hero:FindAbilityByName(abilityname) then
				local ability = hero:FindAbilityByName(abilityname)
				spell_echo.echo = ability
				spell_echo.echotime = GameRules:GetGameTime()
				if ability:GetCursorTarget() then
					spell_echo.echotarget = ability:GetCursorTarget()
					spell_echo.type = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
				elseif ability:GetCursorTargetingNothing() then
					spell_echo.echotarget = ability:GetCursorTargetingNothing()
					spell_echo.type = DOTA_ABILITY_BEHAVIOR_NO_TARGET
				elseif ability:GetCursorPosition() then
					spell_echo.echotarget = ability:GetCursorPosition()
					spell_echo.type = DOTA_ABILITY_BEHAVIOR_POINT
				end
			end
		end
	end
end

function CHoldoutGameMode:Tell_threat(event)
	--print ("show asura core count")
	local pID = event.pID
	local player = PlayerResource:GetPlayer(pID)
	local hero = player:GetAssignedHero() 
	if not hero.threat then hero.threat = 0 end
	local result = math.floor( hero.threat*10 + 0.5 ) / 10
	if result == 0 then result = "no" end
	local message = "I have "..result.." threat!"
	hero.tellThreatDelayTimer = hero.tellThreatDelayTimer or GameRules:GetGameTime()
	if GameRules:GetGameTime() > hero.tellThreatDelayTimer + 1 then
		Say(player, message, true)
		hero.tellThreatDelayTimer = GameRules:GetGameTime()
	end
end

function CHoldoutGameMode:OnHeroPick (event)
 	local hero = EntIndexToHScript(event.heroindex)
	if not hero then return end

	if hero.hasBeenInitialized then return end
	if hero:IsFakeHero() then return end
	Timers:CreateTimer(0.03, function() 
		if hero:IsFakeHero() or hero:IsIllusion() then return end
		for i = 0, 17 do
			local skill = hero:GetAbilityByIndex(i)
			if skill and skill:IsInnateAbility() then
				skill:UpgradeAbility(true)
			end
		end
		hero.damageDone = 0
		hero.hasBeenInitialized = true
		
		StatsScreen:RegisterPlayer(hero)
		RelicManager:RegisterPlayer( hero:GetPlayerID() )
		
		hero:AddExperience(GameRules.XP_PER_LEVEL[7],false,false)
		hero:SetBaseMagicalResistanceValue(0)

		hero:SetRespawnPosition( GetGroundPosition(Vector(973, 99, 0), nil) )
		CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "heroLoadIn", {}) -- wtf is this retarded shit stop force-setting my garbage
		local ID = hero:GetPlayerID()
		if not ID then return end
		PlayerResource:SetCustomBuybackCooldown(ID, 120)
		local playerName = PlayerResource:GetPlayerName( ID )
		if not IsInToolsMode() then
			if PlayerResource:IsDeveloper(ID) then
				
				local messageinfo = {
				text = "You are playing with a developer! Say hi to "..playerName.."!",
				duration = 10
				}
				Notifications:TopToAll(messageinfo)
				ParticleManager:FireParticle("particles/roles/dev/dev_particle.vpcf", PATTACH_POINT_FOLLOW, hero)
			elseif PlayerResource:IsManager(ID) then
				ParticleManager:FireParticle("particles/roles/dev/com_particle.vpcf", PATTACH_POINT_FOLLOW, hero)
			elseif PlayerResource:IsVIP(ID) then
				local messageinfo = {
				text = "You are playing with a VIP! "..playerName.." is supporting the development of Epic Boss Fight!",
				duration = 10
				}
				Notifications:TopToAll(messageinfo)
				ParticleManager:FireParticle("particles/roles/dev/vip_particle.vpcf", PATTACH_POINT_FOLLOW, hero)
			end
		end
		local gold = 250 + 150 * ( GameRules.BasePlayers - PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) )
		hero:SetGold( 0, true )
		if PlayerResource:HasRandomed( ID ) then
			gold = gold + 350
		end
		hero:SetGold( gold, true )
		
		hero:SetDayTimeVisionRange(hero:GetDayTimeVisionRange() * 1.5)
		hero:SetNightTimeVisionRange(hero:GetNightTimeVisionRange() * 1.25)

			
		local player = PlayerResource:GetPlayer(ID)
		if not player then return end
		player.HB = true
		player.Health_Bar_Open = false
	end)
end


-- Read and assign configurable keyvalues if applicable
function CHoldoutGameMode:_ReadGameConfiguration()
	local kv = LoadKeyValues( "scripts/maps/" .. GetMapName() .. ".txt" )
	kv = kv or {} -- Handle the case where there is not keyvalues file
	
	self._bAlwaysShowPlayerGold = kv.AlwaysShowPlayerGold or false
	self._bRestoreHPAfterRound = kv.RestoreHPAfterRound or false
	self._bRestoreMPAfterRound = kv.RestoreMPAfterRound or false
	self._bRewardForTowersStanding = kv.RewardForTowersStanding or false
	self._bUseReactiveDifficulty = kv.UseReactiveDifficulty or false

	self._flPrepTimeBetweenRounds = tonumber( kv.PrepTimeBetweenRounds or 0 )
	self._flItemExpireTime = tonumber( kv.ItemExpireTime or 10.0 )

	self:_ReadRandomSpawnsConfiguration( kv["RandomSpawns"] )
	self:_ReadLootItemDropsConfiguration( kv["ItemDrops"] )
	self:_ReadRoundConfigurations( kv )
	GameRules.maxRounds = #self._vRounds
end

-- Verify spawners if random is set
function CHoldoutGameMode:OnConnectFull()
	SendToServerConsole("dota_combine_models 0")
    SendToConsole("dota_combine_models 0") 
    SendToServerConsole("dota_health_per_vertical_marker 1000")
end

function CHoldoutGameMode:ChooseRandomSpawnInfo()
	if #self._vRandomSpawnsList == 0 then
		error( "Attempt to choose a random spawn, but no random spawns are specified in the data." )
		return nil
	end
	return self._vRandomSpawnsList[ RandomInt( 1, #self._vRandomSpawnsList ) ]
end

-- Verify valid spawns are defined and build a table with them from the keyvalues file
function CHoldoutGameMode:_ReadRandomSpawnsConfiguration( kvSpawns )
	self._vRandomSpawnsList = {}
	if type( kvSpawns ) ~= "table" then
		return
	end
	for _,sp in pairs( kvSpawns ) do			-- Note "_" used as a shortcut to create a temporary throwaway variable
		table.insert( self._vRandomSpawnsList, {
			szSpawnerName = sp.SpawnerName or "",
			szFirstWaypoint = sp.Waypoint or ""
		} )
	end
end


-- If random drops are defined read in that data
function CHoldoutGameMode:_ReadLootItemDropsConfiguration( kvLootDrops )
	self._vLootItemDropsList = {}
	if type( kvLootDrops ) ~= "table" then
		return
	end
	for _,lootItem in pairs( kvLootDrops ) do
		table.insert( self._vLootItemDropsList, {
			szItemName = lootItem.Item or "",
			nChance = tonumber( lootItem.Chance or 0 )
		})
	end
end


-- Set number of rounds without requiring index in text file
function CHoldoutGameMode:_ReadRoundConfigurations( kv )
	self._vRounds = {}
	while true do
		local szRoundName = string.format("Round%d", #self._vRounds + 1 )
		local kvRoundData = kv[ szRoundName ]
		if kvRoundData == nil then
			return
		end
		local roundObj = CHoldoutGameRound()
		roundObj:ReadConfiguration( kvRoundData, self, #self._vRounds + 1 )
		table.insert( self._vRounds, roundObj )
	end
end

function CHoldoutGameMode:OnPlayerUIInitialized(keys)
	local playerID = keys.PlayerID
	local player = PlayerResource:GetPlayer(playerID)
	Timers:CreateTimer(0.03, function()
		if PlayerResource:GetSelectedHeroEntity(playerID) then
			local hero = PlayerResource:GetSelectedHeroEntity(playerID)
			CustomGameEventManager:Send_ServerToPlayer(player,"dota_player_updated_relic_drops", {playerID = pID, drops = hero.relicsToSelect})
			if StatsScreen:IsPlayerRegistered(hero) and not hero:HasModifier("modifier_stats_system_handler") then hero:AddNewModifier(hero, nil, "modifier_stats_system_handler", {}) end
			CustomGameEventManager:Send_ServerToAllClients( "updateQuestLife", { lives = GameRules._life, maxLives = GameRules._maxLives } )
			CustomGameEventManager:Send_ServerToPlayer(player, "heroLoadIn", {})
			if GameRules.holdOut._flPrepTimeEnd then
				local timeLeft = GameRules.holdOut._flPrepTimeEnd - GameRules:GetGameTime()
				CustomGameEventManager:Send_ServerToAllClients( "updateQuestPrepTime", { prepTime = math.floor(timeLeft + 0.5) } )
			end
			if GameRules.UnitKV[hero:GetUnitName()]["Abilities"] and not hero.hasSkillsSelected then
				CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "checkNewHero", {})
			end
			if GameRules.holdOut._currentRound then CustomGameEventManager:Send_ServerToAllClients( "updateQuestRound", { roundNumber = GameRules.holdOut._nRoundNumber, roundText = GameRules.holdOut._currentRound._szRoundQuestTitle } ) end
		elseif not PlayerResource:HasSelectedHero(playerID) then
			player:MakeRandomHeroSelection()
			local newHero = CreateHeroForPlayer(PlayerResource:GetSelectedHeroName( playerID ), player)
			newHero:RespawnHero(false, true, false)
			newHero:SetPlayerID( playerID )
			newHero:SetOwner( player )
			newHero:SetControllableByPlayer(playerID, true)
			return 0.03
		else
			return 0.03
		end
	end)
end

function CHoldoutGameMode:OnPlayerDisconnected(keys) 
	local playerID = keys.PlayerID
	if not playerID then return end
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)
	if hero then hero.disconnect = GameRules:GetGameTime() end
end

-- When game state changes set state in script
function CHoldoutGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	if nNewState >= DOTA_GAMERULES_STATE_INIT and not statCollection.doneInit and not IsInToolsMode() and not IsCheatMode() then
		statCollection:init()
		customSchema:init()
		statCollection.doneInit = true
		print("start")
    end
	if nNewState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		print("setup")
	elseif nNewState == 3 then
		print("pregame")
		Timers:CreateTimer(79,function()
			if GameRules:State_Get() == 3 then
				for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
					if not PlayerResource:HasSelectedHero( nPlayerID ) and PlayerResource:GetPlayer( nPlayerID ) then
						local player = PlayerResource:GetPlayer( nPlayerID )
						player:MakeRandomHeroSelection()
						PlayerResource:SetHasRandomed( nPlayerID )
					end
				end
			end
		end)
	elseif nNewState == 7 then
		
		-- Voting system handler
		-- CHoldoutGameMode:InitializeRoundSystem()
		for _,dummy_target in ipairs(Entities:FindAllByName("dummy_target")) do
			local dummy = CreateUnitByName("npc_dummy_vision", dummy_target:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)
			dummy:FindAbilityByName("hide_hero"):SetLevel(1)
			if GameRules.gameDifficulty <= 2 then
				local dummy = CreateUnitByName("npc_dummy_vision", dummy_target:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS)
				dummy:FindAbilityByName("hide_hero"):SetLevel(1)
			end
		end
		Timers:CreateTimer(0.1,function()
			CustomGameEventManager:Send_ServerToAllClients( "updateQuestLife", { lives = GameRules._life, maxLives = GameRules._maxLives } )
			CustomGameEventManager:Send_ServerToAllClients("heroLoadIn", {})
			-- for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
				-- if not PlayerResource:HasSelectedHero( nPlayerID ) and PlayerResource:GetPlayer( nPlayerID ) then
					-- local player = PlayerResource:GetPlayer( nPlayerID )
					-- player:MakeRandomHeroSelection()
					-- CreateHeroForPlayer(PlayerResource:GetSelectedHeroName( nPlayerID ), player)
					-- local hero = PlayerResource:ReplaceHeroWith(nPlayerID, PlayerResource:GetSelectedHeroName( nPlayerID ), 650, 0)
					-- hero:SetPlayerID( nPlayerID )
					-- hero:SetOwner( player )
					-- hero:SetControllableByPlayer(nPlayerID, true)
				-- end
			-- end
		end)
	elseif nNewState == 8 then
		CustomGameEventManager:Send_ServerToAllClients( "updateQuestLife", { lives = GameRules._life, maxLives = GameRules._maxLives } )
		self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
		-- Say(nil, "You can support the development of Epic Boss Fight by becoming a patron at\nhttps://www.patreon.com/houthakker", false)
		-- Timers:CreateTimer(6, function() Say(nil, "You can also support through donations at https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=DVVMPE8L27YAG", false) end)
	end
end

function CHoldoutGameMode:DegradeThreat()
	if not GameRules:IsGamePaused() then
		local heroes = HeroList:GetAllHeroes()
		local holdaggro = { ["item_asura_plate"] = true, 
							["item_bahamut_chest"] = true, 
							["item_divine_armor"] = true, 
							["item_titan_armor"] = true, 
							["item_assault"] = true,
							["item_blade_mail"] = true,
							["item_blade_mail2"] = true,
							["item_blade_mail3"] = true,
							["item_blade_mail4"] = true}
		local currTime = GameRules:GetGameTime()
		decayDelay = 2
		for _,hero in pairs(heroes) do
			for i=0, 5, 1 do
				local current_item = hero:GetItemInSlot(i)
				if current_item ~= nil and holdaggro[ current_item:GetName() ] then
					decayDelay = 5
				end
			end
			if hero.threat then
				if not hero:IsAlive() then
					hero.threat = 0
				end
				if hero.threat < 0 then hero.threat = 0 end
			else hero.threat = 0 end
			if hero.lastHit then
				if hero.lastHit + decayDelay <= currTime and hero.threat > 0 then
					hero.threat = hero.threat - (hero.threat/10)
				end
			else hero.lastHit = currTime end
			PlayerResource:SortThreat()
			local event_data =
			{
				threat = hero.threat,
				lastHit = hero.lastHit,
				aggro = hero.aggro or 0
			}
			local player = hero:GetPlayerOwner()
			if player then
				CustomGameEventManager:Send_ServerToPlayer( player, "Update_threat", event_data )
			end
		end
	end
end

function CHoldoutGameMode:_regenlifecheck()
	if self._regenround25 == false and self._nRoundNumber >= 26 and GameRules.gameDifficulty < 3 then
		self._regenround25 = true
		local messageinfo = {
		message = "One life has been gained , you just hit a checkpoint !",
		duration = 5
		}
		SendToServerConsole("dota_health_per_vertical_marker 100000")
		FireGameEvent("show_center_message",messageinfo)   
		self._checkpoint = 26
		-- Life._MaxLife = Life._MaxLife + 1
		-- Life._life = Life._life + 1
		GameRules._life = GameRules._life + 1
		GameRules._maxLives = GameRules._maxLives + 1
		CustomGameEventManager:Send_ServerToAllClients( "updateQuestLife", { lives = GameRules._life, maxLives = GameRules._maxLives } )
		-- Life:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, Life._life )
   		-- Life:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, Life._MaxLife )
		-- value on the bar
		-- LifeBar:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, Life._life )
		-- LifeBar:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, Life._MaxLife )
	end
	if self._regenround13 == false and self._nRoundNumber >= 14 and GameRules.gameDifficulty < 4 then
		self._regenround13 = true
		local messageinfo = {
		message = "One life has been gained , you just hit a checkpoint !",
		duration = 5
		}
		SendToConsole("dota_combine_models 0")
		SendToServerConsole("dota_health_per_vertical_marker 10000")
		FireGameEvent("show_center_message",messageinfo)   
		self._checkpoint = 14
		
		GameRules._life = GameRules._life + 1
		GameRules._maxLives = GameRules._maxLives + 1
		CustomGameEventManager:Send_ServerToAllClients( "updateQuestLife", { lives = GameRules._life, maxLives = GameRules._maxLives } )
		-- Life._MaxLife = Life._MaxLife + 1
		-- Life._life = Life._life + 1
		-- GameRules._live = Life._life
		-- Life:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, Life._life )
   		-- Life:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, Life._MaxLife )
		-- value on the bar
		-- LifeBar:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, Life._life )
		-- LifeBar:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, Life._MaxLife )
	end
	if self._regenNG == false and self._NewGamePlus == true then
		self._regenNG = true
		
		local messageinfo = {
		message = "Five life has been gained , Welcome to NewGame + .Mouahahaha !",
		duration = 5
		}
		SendToConsole("dota_combine_models 0")
		SendToServerConsole("dota_health_per_vertical_marker 100000")
		FireGameEvent("show_center_message",messageinfo)   
		self._checkpoint = 1
		
		
		GameRules._life = GameRules._life + 5 - math.floor(GameRules.gameDifficulty + 0.5)
		GameRules._maxLives = GameRules._maxLives + 5 - math.floor(GameRules.gameDifficulty + 0.5)
		CustomGameEventManager:Send_ServerToAllClients( "updateQuestLife", { lives = GameRules._life, maxLives = GameRules._maxLives } )
			
		-- GameRules._live = Life._life
		-- Life:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, Life._life )
   		-- Life:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, Life._MaxLife )
		-- value on the bar
		-- LifeBar:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, Life._life )
		-- LifeBar:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, Life._MaxLife )
	end
end

function CHoldoutGameMode:_Start_Vote()
	CustomGameEventManager:Send_ServerToAllClients("Display_Vote", {})
	local tickTime = 0
	Timers:CreateTimer(1,function()
		tickTime = tickTime + 1
		CustomGameEventManager:Send_ServerToAllClients("refresh_time", {tickTime = 60-tickTime})
		if tickTime >= 60 or (GameRules.vote_Yes + GameRules.vote_No) == PlayerResource:GetTeamPlayerCount() then
			CustomGameEventManager:Send_ServerToAllClients("Close_Vote", {})
			if GameRules.vote_Yes >= GameRules.vote_No then
				self:_EnterNG()
				self._nRoundNumber = 1
				self._flPrepTimeEnd = GameRules:GetGameTime() + 70-tickTime
			else
				SendToConsole("dota_health_per_vertical_marker 250")
				GameRules:SetCustomVictoryMessage ("Congratulations!")
				GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
				GameRules.Winner = DOTA_TEAM_GOODGUYS
				GameRules._finish = true
				GameRules.EndTime = GameRules:GetGameTime()
				statCollection:submitRound(true)
			end
		else
			return 1
		end
	end)
end

function CHoldoutGameMode:spawn_unit( place , unitname , radius , unit_number)
    if radius == nil then radius = 400 end
    if core == nil then core = false end
    if unit_number == nil then unit_number = 1 end
    for i = 0, unit_number-1 do
        --print   ("spawn unit : "..unitname)
        PrecacheUnitByNameAsync( unitname, function() 
        local unit = CreateUnitByName( unitname ,place + RandomVector(RandomInt(radius,radius)), true, nil, nil, DOTA_TEAM_BADGUYS ) 
            Timers:CreateTimer(0.03,function()
            end)
        end,
        nil)
    end
end

if simple_item == nil then
    print ( '[simple_item] creating simple_item' )
    simple_item = {} -- Creates an array to let us beable to index simple_item when creating new functions
    simple_item.__index = simple_item
    simple_item.midas_gold_on_round = 0
    simple_item._round = 1
end

function simple_item:start() -- Runs whenever the simple_item.lua is ran
    print('[simple_item] simple_item started!')
end

function CHoldoutGameMode:CheckHP()
	local dontdelete = {["npc_dota_lone_druid_bear"] = true}
	for _,unit in ipairs ( FindAllEntitiesByClassname("npc_dota_creature")) do
		if unit:GetAbsOrigin().z < GetGroundHeight(unit:GetAbsOrigin(), unit) or unit:GetAbsOrigin().z > 1800 +  GetGroundHeight(unit:GetAbsOrigin(), unit) then
			local currOrigin = unit:GetAbsOrigin()
			FindClearSpaceForUnit(unit, GetGroundPosition(currOrigin, unit), true)
		end
		if unit:GetHealth() <= 0 and unit:IsCreature() then
			if not unit:IsNull() then
				unit:SetBaseMaxHealth( 1 )
				unit:SetMaxHealth( 1 )
				unit:SetHealth( 1 )
				
				unit:ForceKill( false )
			end
		end
	end
	if not GameRules:IsGamePaused() and GameRules:State_Get() >= 7 and GameRules:State_Get() <= 8 then
		for _,unit in ipairs ( FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0), nil, -1, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false) ) do
			if (not unit:IsFakeHero()) or unit:IsCreature() then
				MapHandler:CheckAndResolvePositions(unit)
			end
		end
	end
	if not GameRules:IsGamePaused() then
		for _, hero in ipairs ( HeroList:GetAllHeroes() ) do
			if not hero:IsFakeHero() then
				local data = CustomNetTables:GetTableValue("hero_properties", hero:GetUnitName()..hero:entindex() ) or {}
				local barrier = 0
				for _, modifier in ipairs( hero:FindAllModifiers() ) do
					if modifier.ModifierBarrier_Bonus and hero:IsRealHero() then
						barrier = barrier + modifier:ModifierBarrier_Bonus()
					end
				end
				if barrier > 0 or hero:GetBarrier() ~= barrier then
					hero:SetBarrier(barrier)
					data.barrier = math.floor(barrier)
				end
				data.strength = hero:GetStrength()
				data.intellect = hero:GetIntellect()
				data.agility = hero:GetAgility()
				CustomNetTables:SetTableValue("hero_properties", hero:GetUnitName()..hero:entindex(), data )
			end
		end
	end
end

function CHoldoutGameMode:SetHealthMarkers()
	local averagehp = 0
	local heroes = HeroList:GetAllHeroes()
	for _,unit in pairs ( heroes ) do
		if not unit:IsFakeHero() then
			averagehp = averagehp + unit:GetMaxHealth()
		end
	end
	averagehp = averagehp / #heroes
	SendToConsole("dota_health_per_vertical_marker "..averagehp/16)
end

function CHoldoutGameMode:CheckMidas()
	local playerData = {}
	local players = {}
	for _,unit in pairs ( HeroList:GetAllHeroes() ) do
		if not unit:IsFakeHero() then
			local midas_modifier = 0
			local ngmodifier = 0
			if self._NewGamePlus then ngmodifier = math.floor(GameRules:GetMaxRound()/2) end
			local round = math.floor((self._nRoundNumber + ngmodifier))
			if unit:HasModifier("passive_midas_3") or unit:FindItemByName("item_midas_3", false) then
				midas_modifier = 15
			elseif unit:HasModifier("passive_midas_2") or unit:FindItemByName("item_midas_2", false) then
				midas_modifier = 10
			elseif unit:HasModifier("passive_midas_1") or unit:FindItemByName("item_hand_of_midas", false) then
				midas_modifier = 5
			end
			local interest = math.floor( unit:GetGold()*midas_modifier / 100 + 0.5 )
			if interest > midas_modifier*10*round then interest = midas_modifier*10*round end
			local player = unit:GetPlayerOwner()
			unit.midasGold = unit.midasGold or 0
			
			playerData[unit:GetPlayerID()] = {DT = unit.statsDamageTaken or 0, DD = unit.statsDamageDealt or 0, DH = unit.statsDamageHealed or 0}
			if player then
				CustomGameEventManager:Send_ServerToPlayer( player, "player_update_gold", { gold = unit.midasGold, interest = interest} )
			end
		end
	end
	CustomGameEventManager:Send_ServerToAllClients( "player_update_stats", playerData )
end

BARRIER_DEGRADE_RATE = 0.995
function CHoldoutGameMode:SendErrorReport(err)
	if not self.gameHasBeenBroken then 
		self.gameHasBeenBroken = true
		Notifications:BottomToAll({text="An error has occurred! Please screenshot this: "..err, duration=15.0})
		print(err)
	end
end

DAY_TIME = 0
NIGHT_TIME = 1
TEMPORARY_NIGHT = 2
NIGHT_STALKER_NIGHT = 3

function CHoldoutGameMode:OnThink()
	if GameRules:State_Get() >= 7 and GameRules:State_Get() <= 8 then
		local OnPThink = function(self)
			local status, err, ret = xpcall(self._CheckForDefeat, debug.traceback, self)
			if not status  and not self.gameHasBeenBroken then
				self:SendErrorReport(err)
			end
			status, err, ret = xpcall(self._regenlifecheck, debug.traceback, self)
			if not status  and not self.gameHasBeenBroken then
				self:SendErrorReport(err)
			end
			status, err, ret = xpcall(self.CheckHP, debug.traceback, self)
			if not status  and not self.gameHasBeenBroken then
				self:SendErrorReport(err)
			end
			status, err, ret = xpcall(self.CheckMidas, debug.traceback, self)
			if not status  and not self.gameHasBeenBroken then
				self:SendErrorReport(err)
			end
			status, err, ret = xpcall(self.DegradeThreat, debug.traceback, self)
			if not status  and not self.gameHasBeenBroken then
				self:SendErrorReport(err)
			end
			local timeofday = GameRules:IsDaytime()
			if GameRules:IsTemporaryNight() then timeofday = TEMPORARY_NIGHT end
			if GameRules:IsNightstalkerNight() then timeofday = NIGHT_STALKER_NIGHT end
			CustomNetTables:SetTableValue( "game_info", "timeofday", {timeofday = timeofday} )
			if self._flPrepTimeEnd then
				local timeLeft = self._flPrepTimeEnd - GameRules:GetGameTime()
				CustomGameEventManager:Send_ServerToAllClients( "updateQuestPrepTime", { prepTime = math.floor(timeLeft + 0.5) } )
				self:_ThinkPrepTime()
			elseif self._currentRound ~= nil then
				local RoundHandler = function(self)
					self._currentRound:Think()
					if self._currentRound:IsFinished() then
						self._currentRound:End(true)
						GameRules:SetGoldTickTime( 0 )
						GameRules:SetGoldPerTick( 0 )
						self._nRoundNumber = self._nRoundNumber + 1
						boss_meteor:SetRoundNumer(self._nRoundNumber)
						GameRules._roundnumber = self._nRoundNumber
						CustomGameEventManager:Send_ServerToAllClients( "round_has_ended", {} )
						self._currentRound = nil
						-- Heal all players
						if self.boss_master_id ~= -1 then
							local boss_master = PlayerResource:GetSelectedHeroEntity(self.boss_master_id)
							boss_master:HeroLevelUp(true)
						end
						local ngmodifier = 0
						if self._NewGamePlus then ngmodifier = math.floor(GameRules:GetMaxRound()/2) end
						local round = math.floor((self._nRoundNumber + ngmodifier))
						local passive_gold = round*30
						local abandonGold = 0
						local shareCount = 0
						for _,unit in pairs ( HeroList:GetAllHeroes()) do
							if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS and not unit:IsFakeHero() then
								PlayerResource:SetCustomBuybackCost(unit:GetPlayerID(), self._nRoundNumber * 40)
								if unit:HasOwnerAbandoned() then
									abandonGold = abandonGold + unit:GetGold()
									unit:SetGold(0, false)
									unit:SetGold(0, true)
								else
									shareCount = shareCount + 1
								end
								local midas_modifier = 0
								if unit:HasModifier("passive_midas_3") then
									midas_modifier = 15
								elseif unit:HasModifier("passive_midas_2") then
									midas_modifier = 10
								elseif unit:HasModifier("passive_midas_1") or unit:FindItemByName("item_hand_of_midas", false) then
									midas_modifier = 5
								end
								local interest = math.floor( unit:GetGold()*midas_modifier / 100 + 0.5 )
								if interest > midas_modifier*10*round then interest = midas_modifier*10*round end
								local totalgold = unit:GetGold() + passive_gold + interest
								unit.midasGold = unit.midasGold or 0
								unit.midasGold = unit.midasGold + interest
								unit:SetGold(0 , false)
								unit:SetGold(totalgold, true)
								local player = unit:GetPlayerOwner()
								if player then
									CustomGameEventManager:Send_ServerToPlayer( player, "player_update_gold", { gold = unit.midasGold, interest = interest} )
								end
							end
						end
						for _, unit in ipairs( HeroList:GetActiveHeroes() ) do
							if not unit:HasOwnerAbandoned() then
								local newGold = unit:GetGold() + math.floor(abandonGold / shareCount)
								unit:SetGold(0 , false)
								unit:SetGold(newGold, true)
							end
						end
						-- if math.random(1,25) == 25 then
							-- self:spawn_unit( Vector(0,0,0) , "npc_dota_treasure" , 2000)
							-- for _,unit in pairs ( Entities:FindAllByModel( "models/courier/flopjaw/flopjaw.vmdl")) do
								-- Waypoint = Entities:FindByName( nil, "path_invader1_1" )
								-- unit:SetInitialGoalEntity(Waypoint) 
								-- Timers:CreateTimer(15,function()
									-- unit:ForceKill(true)
								-- end)
							-- end
							-- self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds + 15

						-- end 
						if self._nRoundNumber > #self._vRounds then
							-- if self._NewGamePlus == false then
								-- self:_Start_Vote()
							-- else
								SendToConsole("dota_health_per_vertical_marker 250")
								GameRules:SetCustomVictoryMessage ("Congratulations!")
								GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
								GameRules.Winner = DOTA_TEAM_GOODGUYS
								GameRules._finish = true
								GameRules.EndTime = GameRules:GetGameTime()
								statCollection:submitRound(true)
							-- end
						else
							self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
							
							GameRules.voteRound_No = PlayerResource:GetTeamPlayerCount()
							GameRules.voteRound_Yes = 0
							
							
				
							CustomGameEventManager:Send_ServerToAllClients("Display_RoundVote", {})
							local event_data =
							{
								No = GameRules.voteRound_No,
								Yes = GameRules.voteRound_Yes,
							}
							CustomGameEventManager:Send_ServerToAllClients("RoundVoteResults", event_data)

							Timers:CreateTimer(1,function()
								if GameRules.voteRound_No <= 0 then
									CustomGameEventManager:Send_ServerToAllClients("Close_RoundVote", {})
									if self._flPrepTimeEnd~= nil then
										self._flPrepTimeEnd = 0
									end
								else
									return 1
								end
							end)
						end
					end
				end
				status, err, ret = xpcall(RoundHandler, debug.traceback, self)
				if not status  and not self.gameHasBeenBroken then
					self:SendErrorReport(err)
				end
			end
		end
		status, err, ret = xpcall(OnPThink, debug.traceback, self)
		if not status  and not self.gameHasBeenBroken then
			self:SendErrorReport(err)
		end
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then		-- Safe guard catching any state that may exist beyond DOTA_GAMERULES_STATE_POST_GAME
		return nil
	end
	return 0.25
end

function CDOTA_PlayerResource:SortThreat()
	local currThreat = 0
	local secondThreat = 0
	local aggrounit 
	local aggrosecond
	for _,unit in pairs ( HeroList:GetAllHeroes()) do
		if not unit.threat then unit.threat = 0 end
		if not unit:IsFakeHero() then
			local data = CustomNetTables:GetTableValue("hero_properties", unit:GetUnitName()..unit:entindex() ) or {}
			data.threat = unit.threat
			CustomNetTables:SetTableValue("hero_properties", unit:GetUnitName()..unit:entindex(), data )
			if unit.threat > currThreat then
				currThreat = unit.threat
				aggrounit = unit
			elseif unit.threat > secondThreat and unit.threat < currThreat then
				secondThreat = unit.threat
				aggrosecond = unit
			end
		end
	end
	for _,unit in pairs ( HeroList:GetAllHeroes()) do
		if unit == aggrosecond then unit.aggro = 2
		elseif unit == aggrounit then unit.aggro = 1
		else unit.aggro = 0 end
	end
end

function CHoldoutGameMode:_RefreshPlayers()
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			if PlayerResource:HasSelectedHero( nPlayerID ) then
				local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
				if hero ~=nil then
					if not hero:IsAlive() then
						hero:RespawnHero(false, false)
					end
					hero:SetHealth( hero:GetMaxHealth() )
					hero:SetMana( hero:GetMaxMana() )
					hero.threat = 0
					ResolveNPCPositions( hero:GetAbsOrigin(), hero:GetHullRadius() + hero:GetCollisionPadding() )
				end
			end
		end
	end
end


function CHoldoutGameMode:_CheckForDefeat()
	if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		return
	end
	self._check_dead = false
	local AllRPlayersDead = true
	local PlayerNumberRadiant = 0
	GameRules.playersDisconnected = 0
	GameRules.playersAbandoned = 0
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			PlayerNumberRadiant = PlayerNumberRadiant + 1
			if not PlayerResource:HasSelectedHero( nPlayerID ) and self._nRoundNumber == 1 and self._currentRound == nil then
				AllRPlayersDead = false
			elseif PlayerResource:HasSelectedHero( nPlayerID ) then
				local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
				if hero and hero:NotDead() then
					AllRPlayersDead = false
					if PlayerResource:GetConnectionState(hero:GetPlayerID()) == 3 then
						GameRules.playersDisconnected = GameRules.playersDisconnected + 1
					end
					if hero:HasOwnerAbandoned() then
						GameRules.playersAbandoned = GameRules.playersAbandoned + 1
					end
				end
			end
		end
	end

	if not GameRules.deathTimerCheck and AllRPlayersDead and GameRules._life > 0 then
		GameRules.deathTimerCheck = true
		Timers:CreateTimer(ROUND_END_DELAY, function()
			for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
				if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
					if PlayerResource:HasSelectedHero( nPlayerID ) then
						local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
						if hero and hero:IsAlive() then
							AllRPlayersDead = false
						end
					end
				end
			end
			
			if AllRPlayersDead then
				if self._currentRound ~= nil then
					self._currentRound:End()
					self._currentRound = nil
				end
				self._flPrepTimeEnd = GameRules:GetGameTime() + 20
				GameRules._life = GameRules._life - 1
				GameRules._used_life = GameRules._used_life + 1
				CustomGameEventManager:Send_ServerToAllClients( "updateQuestLife", { lives = GameRules._life, maxLives = GameRules._maxLives } )
				for _,unit in pairs ( HeroList:GetAllHeroes()) do
					if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS and not unit:IsFakeHero() then
						unit:AddGold(self._nRoundNumber * 100)
						unit:AddExperience(self._nRoundNumber * 100,false,false)
					end
				end
			end
			GameRules.deathTimerCheck = false
		end)
	end
	if PlayerNumberRadiant == 1 then GameRules.playersDisconnected = 0 end -- ignore solo players
	if PlayerNumberRadiant == 0 or GameRules._life == 0 or (GameRules.playersDisconnected + GameRules.playersAbandoned) >= PlayerNumberRadiant or AllPlayersAbandoned() then
		self:_OnLose()
	end
end


function CHoldoutGameMode:_OnLose()
	SendToConsole("dota_health_per_vertical_marker 250")
	GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )
	GameRules.Winner = DOTA_TEAM_BADGUYS
	GameRules.EndTime = GameRules:GetGameTime()
	statCollection:submitRound(true)
end


function CHoldoutGameMode:_ThinkPrepTime()
	if GameRules:GetGameTime() >= self._flPrepTimeEnd then
		CustomGameEventManager:Send_ServerToAllClients("Close_RoundVote", {})
		self._flPrepTimeEnd = nil

		if self._nRoundNumber > #self._vRounds then
			GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
			GameRules.Winner = DOTA_TEAM_GOODGUYS
			GameRules.EndTime = GameRules:GetGameTime()
			statCollection:submitRound(true)
			return false
		end
		self._currentRound = self._vRounds[ self._nRoundNumber ]
		self._currentRound:Begin()
		GameRules:SetGoldTickTime( 1 )
		GameRules:SetGoldPerTick( 1 )
		for _,unit in pairs ( HeroList:GetAllHeroes() ) do
			if not unit:IsFakeHero() then
				unit.statsDamageDealt = 0
				unit.statsDamageTaken = 0
				unit.statsDamageHealed = 0
			end
		end
		CustomGameEventManager:Send_ServerToAllClients( "updateQuestRound", { roundNumber = self._nRoundNumber, roundText = self._currentRound._szRoundQuestTitle } )
		return
	end
end


function CHoldoutGameMode:OnNPCSpawned( event )
	Timers:CreateTimer(function()
		local spawnedUnit = EntIndexToHScript( event.entindex )
		if not spawnedUnit or spawnedUnit:GetClassname() == "npc_dota_thinker" or spawnedUnit:IsPhantom() or spawnedUnit:IsFakeHero()then
			return
		end
		if spawnedUnit:GetTeam() == DOTA_TEAM_GOODGUYS then
			if spawnedUnit:IsRealHero() then
				spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_tombstone_respawn_immunity", {duration = 3})
			end
		end
		if spawnedUnit:IsCourier() then
			spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_invulnerable", {})
		end
		if spawnedUnit:IsCreature() and spawnedUnit:GetTeam() == DOTA_TEAM_BADGUYS and spawnedUnit:GetUnitName() ~= "npc_dota_boss36" and spawnedUnit:GetUnitName() ~= "npc_dota_boss4_tomb" then
			local expectedHP = spawnedUnit:GetHealth() * RandomFloat(0.9, 1.15)
			if GetMapName() == "epic_boss_fight_hardcore" then expectedHP = expectedHP * 1.35 end
			local playerHPMultiplier = 0.35
			local playerDMGMultiplier = 0.05
			if GetMapName() == "epic_boss_fight_hardcore" then 
				playerHPMultiplier = 0.5 
				local playerDMGMultiplier = 0.07
			end
			local effective_multiplier = (HeroList:GetActiveHeroCount() - 1)
			local effPlayerHPMult = 1 + effective_multiplier * playerHPMultiplier
			local effPlayerDMGMult = 0.9 + effective_multiplier * playerDMGMultiplier

			expectedHP = expectedHP * effPlayerHPMult
			spawnedUnit:SetBaseMaxHealth(expectedHP)
			spawnedUnit:SetMaxHealth(expectedHP)
			spawnedUnit:SetHealth(expectedHP)
			spawnedUnit:SetAverageBaseDamage(spawnedUnit:GetAverageBaseDamage() * effPlayerDMGMult * RandomFloat(0.85, 1.15), 30)
			spawnedUnit:SetBaseHealthRegen(GameRules._roundnumber * RandomFloat(0.85, 1.15) )
			
			spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_boss_attackspeed", {})
			spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_spawn_immunity", {duration = 4/GameRules.gameDifficulty})
			
			if spawnedUnit:GetHullRadius() >= 16 then
				spawnedUnit:SetHullRadius( math.ceil(16 * spawnedUnit:GetModelScale()) )
			end
		end
	end)
end

function CHoldoutGameMode:OnEntityKilled( event )
	local check_tombstone = true
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	if not killedUnit or killedUnit:IsFakeHero() then return end
	local DeathHandler = function(self, killedUnit )
		if killedUnit.Asura_To_Give ~= nil then
			for _,hero in pairs ( HeroList:GetRealHeroCount()) do
				if not hero:IsFakeHero() then
					hero.Asura_Core = (hero.Asura_Core or 0) + killedUnit.Asura_To_Give
					update_asura_core(hero)
				end
			end
			Notifications:TopToAll({text="You have received an Asura Core", duration=3.0})
		end
		if killedUnit:IsRealHero() then
			local player = killedUnit:GetPlayerOwner()
			if player then
				Timers:CreateTimer(0.03, function()
					player:SetKillCamUnit(nil)
				end)
			end
			if killedUnit:NotDead() then
				self._check_check_dead = true
				check_tombstone = false
				self._check_dead = false
				if GameRules._life == 1 then
					AllRPlayersDead = false
				end
			end
			-- if GetMapName() == "epic_boss_fight_hardcore" then
				-- check_tombstone = false
			-- end
			if check_tombstone == true and killedUnit.NoTombStone ~= true then
				local newItem = CreateItem( "item_tombstone", killedUnit, killedUnit )
				newItem:SetPurchaseTime( 0 )
				newItem:SetPurchaser( killedUnit )
				local tombstone = SpawnEntityFromTableSynchronous( "dota_item_tombstone_drop", {} )
				tombstone:SetContainedItem( newItem )
				tombstone:SetAngles( 0, RandomFloat( 0, 360 ), 0 )
				FindClearSpaceForUnit( tombstone, killedUnit:GetAbsOrigin(), true )
				killedUnit.tombstoneEntity = newItem
			elseif killedUnit.NoTombStone == true then
				killedUnit.NoTombStone = false
			end
		end
	end
	status, err, ret = xpcall(DeathHandler, debug.traceback, self, killedUnit)
	if not status  and not self.gameHasBeenBroken then
		self:SendErrorReport(err)
	end
end

function CHoldoutGameMode:CheckForLootItemDrop( killedUnit )
	for _,itemDropInfo in pairs( self._vLootItemDropsList ) do
		if RollPercentage( itemDropInfo.nChance ) then
			local newItem = CreateItem( itemDropInfo.szItemName, nil, nil )
			newItem:SetPurchaseTime( 0 )
			local drop = CreateItemOnPositionSync( killedUnit:GetAbsOrigin(), newItem )
			drop.Holdout_IsLootDrop = true
		end
	end
end


-- Custom game specific console command "holdout_test_round"
function CHoldoutGameMode:_TestRoundConsoleCommand( cmdName, roundNumber, delay, NG)
	local nRoundToTest = tonumber( roundNumber )
	-- print( "Testing round %d", nRoundToTest )
	if nRoundToTest <= 0 or nRoundToTest > #self._vRounds then
		print( "Cannot test invalid round %d", nRoundToTest )
		return
	end
	GameRules._roundnumber = nRoundToTest
	--print (NG)
	if NG then
		self:_EnterNG()
	end

	local nExpectedGold = 0
	local nExpectedXP = 0
	for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
		if PlayerResource:IsValidPlayer( nPlayerID ) then
			PlayerResource:SetBuybackCooldownTime( nPlayerID, 0 )
			PlayerResource:SetBuybackGoldLimitTime( nPlayerID, 0 )
			PlayerResource:ResetBuybackCostTime( nPlayerID )
		end
	end

	if self._currentRound ~= nil then
		self._currentRound:End()
		self._currentRound = nil
	end

	for _,item in pairs( Entities:FindAllByClassname( "dota_item_drop")) do
		local containedItem = item:GetContainedItem()
		if containedItem then
			UTIL_RemoveImmediate( containedItem )
		end
		UTIL_RemoveImmediate( item )
	end

	self._flPrepTimeEnd = GameRules:GetGameTime() + 5
	self._nRoundNumber = nRoundToTest

	if delay ~= nil then
		self._flPrepTimeEnd = GameRules:GetGameTime() + tonumber( delay )
	end
end

function CHoldoutGameMode:SpawnTestElites(elite, amount, bossname)
	if IsInToolsMode() or IsCheatMode() then
		local spawns = 1
		if amount then
			spawns = amount
		end
		local spawnName = bossname
		if not spawnName then
			spawnName = "npc_dota_treasure"
		end
		for i = 1, spawns do
			local spawnLoc = Entities:FindByName(nil, "spawner"..RandomInt(1, 5)):GetAbsOrigin()
			PrecacheUnitByNameAsync( spawnName, function()
				local entUnit = CreateUnitByName( spawnName, spawnLoc, true, nil, nil, DOTA_TEAM_BADGUYS )
				if elite then
					entUnit:AddAbilityPrecache(elite):SetLevel(1)
					local nParticle = ParticleManager:CreateParticle( "particles/econ/courier/courier_onibi/courier_onibi_yellow_ambient_smoke_lvl21.vpcf", PATTACH_ABSORIGIN_FOLLOW, entUnit )
					ParticleManager:ReleaseParticleIndex( nParticle )
					entUnit:SetModelScale(entUnit:GetModelScale()*1.5)
				end
			end)
		end
	end
end


function CHoldoutGameMode:_StatusReportConsoleCommand( cmdName )
	print( "*** Holdout Status Report ***" )
	print( string.format( "Current Round: %d", self._nRoundNumber ) )
	if self._currentRound then
		self._currentRound:StatusReport()
	end
	print( "*** Holdout Status Report End *** ")
end