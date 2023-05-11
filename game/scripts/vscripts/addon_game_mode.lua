MAXIMUM_ATTACK_SPEED	= 9999
MINIMUM_ATTACK_SPEED	= 50

ROUND_END_DELAY = 3

DOTA_LIFESTEAL_SOURCE_NONE = 0
DOTA_LIFESTEAL_SOURCE_ATTACK = 1
DOTA_LIFESTEAL_SOURCE_ABILITY = 2

MAP_CENTER = Vector(332, -1545)
GAME_MAX_LEVEL = 80
EVENT_MAX = 40

HERO_SELECTION_TIME = 80

GLOBAL_STUN_LIST = {}

if CHoldoutGameMode == nil then
	CHoldoutGameMode = class({})
end

function SendErrorReport(err, context)
	Notifications:BottomToAll({text="An error has occurred! Please screenshot this: "..err, duration=15.0})
	print(err)
	if context then context.gameHasBeenBroken = true end
end

require("eventmanager")
require("lua_map/map")
require( "libraries/Timers" )
require( "libraries/notifications" )
-- require( "statcollection/init" )
require("libraries/utility")
require( "libraries/clientserver" )
require( "libraries/vector_targeting" )
require("libraries/animations")
require("talentmanager")
require("itemmanager")
require("relicmanager")
require("roundmanager")
require( "ai/ai_core" )
require( "ai/ai_timers")

-- Precache resources
function Precache( context )
	print("precaching shit")
	
	PrecacheResource( "model", "models/props_gameplay/tombstoneb01.vmdl", context )
	PrecacheModel( "models/props_gameplay/tombstoneb01.vmdl", context ) 
	
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
	
	-- map stuff
	PrecacheResource( "particle", "particles/units/heroes/hero_doom_bringer/doom_bringer_doom.vpcf", context)
	PrecacheResource( "particle", "particles/alacrity_fire.vpcf", context)
	PrecacheResource( "particle", "particles/econ/items/ember_spirit/ember_spirit_vanishing_flame/ember_spirit_vanishing_flame_ambient_smoke.vpcf", context)
	

	-- Hero Precaches
	PrecacheResource("particle", "particles/warlock_deepfire_ember.vpcf", context)
	
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
	PrecacheResource("particle", "particles/units/elite_warning_defense_overhead.vpcf", context)
	PrecacheResource("particle", "particles/units/elite_warning_special_overhead.vpcf", context)
	PrecacheResource("particle", "particles/units/elite_warning_offense_overhead.vpcf", context)
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
	
	
	local delay = 0.1
	for unit, info in pairs( LoadKeyValues("scripts/npc/npc_units_custom.txt") ) do
		PrecacheUnitByNameSync( unit, context )
	end
	
	GameRules._Elites = LoadKeyValues( "scripts/kv/elites.kv" )
	
	RoundManager:Initialize(context)
end

-- Actually make the game mode when we activate
function Activate()
	GameRules.bossHuntersEntity = CHoldoutGameMode()
	GameRules.bossHuntersEntity:InitGameMode()
	require("projectilemanager")
	-- require('statsmanager')
end

function CHoldoutGameMode:InitGameMode()
	print ("Initializing Boss Hunters")
	GameRules._maxLives = 10
	GameRules.gameDifficulty = 1
	
	GameRules.UnitKV = LoadKeyValues("scripts/npc/npc_heroes.txt")
	GameRules.UnitKV = MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_heroes_custom.txt"))
	-- GameRules.UnitKV = MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_units.txt"))
	GameRules.UnitKV = MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_units_custom.txt"))
	
	print( GameRules.UnitKV )
	
	GameRules.AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
	GameRules.AbilityKV = MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/npc_items_custom.txt"))
	GameRules.AbilityKV = MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/items.txt"))
	
	GameRules.HeroList = LoadKeyValues("scripts/npc/activelist.txt")
	
	print(GetMapName())
	
	self._message = false
	
	
	if IsInToolsMode() then
		GameRules:SetPreGameTime( 9999.0 )
		HERO_SELECTION_TIME = 9999
	else
		GameRules:SetPreGameTime( 30.0 )
	end
	GameRules:SetHeroSelectionTime( HERO_SELECTION_TIME )
	GameRules:SetShowcaseTime( 0 )
	GameRules:SetStrategyTime( 0 )
	GameRules:SetPostGameTime( 30 )
	GameRules:SetCustomGameEndDelay( 15.0 )
	GameRules:SetCustomGameSetupAutoLaunchDelay( 0 ) -- fix valve bullshit
	
	local mapInfo = LoadKeyValues( "addoninfo.txt" )[GetMapName()]
	
	GameRules.BasePlayers = mapInfo.MaxPlayers
	GameRules._maxLives =  mapInfo.MaxLives
	GameRules._startingLives =  mapInfo.StartingLives
	GameRules.gameDifficulty =  mapInfo.Difficulty
	CustomNetTables:SetTableValue( "game_info", "difficulty", {difficulty = GameRules.gameDifficulty} )
	CustomNetTables:SetTableValue( "game_info", "timeofday", {timeofday = 0} )
	
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, mapInfo.MaxPlayers)
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0)
	
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetUseUniversalShopMode( true )

	GameRules:SetTreeRegrowTime( 30.0 )
	GameRules:SetCreepMinimapIconScale( 4 )
	GameRules:SetRuneMinimapIconScale( 1.5 )
	GameRules:SetGoldTickTime( 1 )
	GameRules:SetGoldPerTick( 1 )
	
	GameRules:SetEnableAlternateHeroGrids( false )
	
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	GameRules:GetGameModeEntity():SetCustomBuybackCooldownEnabled(true)
	GameRules:GetGameModeEntity():SetCustomBuybackCostEnabled(true)
	GameRules:GetGameModeEntity():SetCameraDistanceOverride(1400)
	GameRules:GetGameModeEntity():SetDaynightCycleAdvanceRate( 0.00 )
	GameRules:GetGameModeEntity():SetDaynightCycleDisabled( false )
	GameRules:SetTimeOfDay( 0.51 )
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
	GameRules:GetGameModeEntity():SetInnateMeleeDamageBlockAmount( 30 )
	GameRules:GetGameModeEntity():SetInnateMeleeDamageBlockPerLevelAmount( 5 )
	GameRules:GetGameModeEntity():SetInnateMeleeDamageBlockPercent( 40 )
	GameRules:GetGameModeEntity():SetTPScrollSlotItemOverride("item_dust_of_stasis")
	GameRules:GetGameModeEntity():SetDefaultStickyItem("item_potion_of_recovery")
	GameRules:GetGameModeEntity():SetNeutralStashEnabled(false)
	GameRules:GetGameModeEntity():SetNeutralStashTeamViewOnlyEnabled(true)
	GameRules:GetGameModeEntity():SetGiveFreeTPOnDeath(false)
	
	-- Custom console commands
	Convars:RegisterCommand( "bh_test_round", function( command, zone, roundName, roundType )
											print( zone, roundName, roundType )
											if Convars:GetDOTACommandClient() and IsInToolsMode() then
												local event = BaseEvent(zone, roundType, roundName )
												table.insert( RoundManager.zones[RoundManager.currentZone][1], 1, {event} )
												RoundManager:StartPrepTime(30, true)
											end
										end, "adding relics",0)
	Convars:RegisterCommand( "bh_test_stat_register", function( command )
											if Convars:GetDOTACommandClient() and IsInToolsMode() then
												local itemData = {}
												for _, hero in ipairs( HeroList:GetRealHeroes() ) do
													if PlayerResource:GetConnectionState( hero:GetPlayerID() ) ~= DOTA_CONNECTION_STATE_ABANDONED then
														RoundManager:RegisterStatsForHero( hero, bWon )
														for i=0, 5, 1 do
															local item = hero:GetItemInSlot(i)
															if item ~= nil then
																local itemName = string.sub(item:GetName(), 1, -3)
																local itemLevel = tonumber( string.sub(item:GetName(), -1, -1) )
																if not itemLevel then
																	itemName = item:GetName()
																	itemLevel = 1
																end
																itemData[itemName] = itemData[itemName] or {}
																itemData[itemName].plays = ( itemData[itemName].plays or 0 ) + 1
																itemData[itemName].levels = itemData[itemName].levels or {}
																itemData[itemName].levels[itemLevel] = itemData[itemName].levels[itemLevel] or {}
																itemData[itemName].levels[itemLevel].plays = ( itemData[itemName].levels[itemLevel].plays or 0 ) + 1
															end
														end 
													end
												end
												RoundManager:RegisterStatsForItems( itemData, bWon )
											end
										end, "adding relics",0)
	Convars:RegisterCommand( "clear_relics", function()
											if Convars:GetDOTACommandClient() and IsInToolsMode() then
												local player = Convars:GetDOTACommandClient()
												RelicManager:ClearRelics(player:GetPlayerID(), true) 
											end
										end, "adding relics",0)
	Convars:RegisterCommand( "add_relic", function(command, relicName)
											if Convars:GetDOTACommandClient() and ( GameRules:IsCheatMode( ) or ( PlayerResource:IsDeveloper( player:GetPlayerID() ) or PlayerResource:IsManager( player:GetPlayerID() ) ) ) then
												local player = Convars:GetDOTACommandClient()
												local hero = player:GetAssignedHero()
												hero:AddRelic(relicName)
											end
										end, "adding relics",0)
	Convars:RegisterCommand( "team_add_relic", function(command, relicName)
											if Convars:GetDOTACommandClient() then
												local player = Convars:GetDOTACommandClient()
												if not ( PlayerResource:IsDeveloper( player:GetPlayerID() ) or PlayerResource:IsManager( player:GetPlayerID() ) ) then return end
												for _, hero in ipairs( HeroList:GetRealHeroes() ) do
													hero:AddRelic(relicName)
												end
											end
										end, "adding relics",0)
	Convars:RegisterCommand( "add_all_relics", function(command)
											if Convars:GetDOTACommandClient() and IsInToolsMode() then
												local player = Convars:GetDOTACommandClient()
												local hero = player:GetAssignedHero()
												for id, relicPool in ipairs( hero.internalRNGPools ) do
													for relicName, weight in pairs(relicPool) do
														hero:AddRelic(relicName)
													end
												end
											end
										end, "adding relics",0)
	Convars:RegisterCommand( "roll_relics", function(command, fBoss)
											if Convars:GetDOTACommandClient() and IsInToolsMode() then
												local player = Convars:GetDOTACommandClient()
												local hero = player:GetAssignedHero()
												if fBoss then
													RelicManager:RollBossRelicsForPlayer( player:GetPlayerID() )
												else
													RelicManager:RollEliteRelicsForPlayer( player:GetPlayerID() )
												end
											end
										end, "adding relics",0)
	Convars:RegisterCommand( "simulate_round", function(command, cNewRound )
											if Convars:GetDOTACommandClient() and IsInToolsMode() then
												local player = Convars:GetDOTACommandClient()
												local hero = player:GetAssignedHero()
												
												local eventsBeaten = tonumber( cNewRound )
												local currEvents = RoundManager.eventsFinished
												local currRaids = RoundManager.raidsFinished
												local currZones = RoundManager.zonesFinished
												local currAscensions = RoundManager.ascensionLevel
												if eventsBeaten > currEvents then
													local moneyGained = 0
													local xpGained = 0
													
													local raidsBeaten = math.floor( eventsBeaten / 5 )
													local zonesBeaten = math.floor(raidsBeaten / 2 )
													local ascensionsBeaten = math.floor(zonesBeaten / 4 )
													
													RoundManager.eventsFinished = eventsBeaten
													RoundManager.raidsFinished = raidsBeaten
													RoundManager.zonesFinished = zonesBeaten
													RoundManager.ascensionLevel = ascensionsBeaten
													if RoundManager.zonesFinished % 4 == 0 then
														RoundManager.currentZone = "Grove"
													elseif RoundManager.zonesFinished % 4 == 1 then
														RoundManager.currentZone = "Sepulcher"
													elseif RoundManager.zonesFinished % 4 == 2 then
														RoundManager.currentZone = "Solitude"
													else
														RoundManager.currentZone = "Elysium"
													end
													RoundManager.raidNumber = raidsBeaten % 2
													RoundManager:LoadSpawns()
													local playerScaling = 1 + ( GameRules.BasePlayers - HeroList:GetActiveHeroCount() ) / 10
													for i = currEvents, eventsBeaten - 1 do
														local eventScaling = i * 0.75
														local raidGPScaling = 1 + math.floor( i / 5 ) * 0.125
														local raidXPScaling = 1 + math.min( RoundManager:GetRaidsFinished(), EVENT_MAX ) * 0.15

														
														local baseXP = ( ( 150 + ( 35 * eventScaling ) ) + (275 * raidXPScaling) ) * playerScaling
														local baseGold = ( ( 200 + ( 20 * eventScaling ) ) + (80 * raidGPScaling) ) * playerScaling
														
														if (i % 5) == 0 then
															baseXP = baseXP * 1.5
															baseGold = baseGold * 1.5
														else
															baseXP = baseXP * 0.7 
															baseGold = baseGold * 0.7
														end
														
														moneyGained = moneyGained + baseGold
														xpGained = xpGained + baseXP
													end
													hero:AddGold( moneyGained )
													hero:AddXP( xpGained )
												end
											end
										end, "simulating round",0)
	Convars:RegisterCommand( "getdunked", function()
											if Convars:GetDOTACommandClient() then
												local player = Convars:GetDOTACommandClient()
												local hero = player:GetAssignedHero() 
												if not hero:IsAlive() then
													hero:RespawnHero(false, false)
												end
												hero:SetHealth(1)
												hero:ForceKill(true)
											end
										end, "fixing bug",0)
	Convars:RegisterCommand( "hide_hero", function()
											if Convars:GetDOTACommandClient() and IsInToolsMode() then
												local player = Convars:GetDOTACommandClient()
												local hero = player:GetAssignedHero()
												if not hero.hasBeenConsoleCommandHidden then
													hero:AddNoDraw()
													hero.hasBeenConsoleCommandHidden = true
												else
													hero:RemoveNoDraw()
													hero.hasBeenConsoleCommandHidden = false
												end
											end
										end, "fixing bug",0)
	Convars:RegisterCommand( "reload_modifiers", function()
											if Convars:GetDOTACommandClient() and IsInToolsMode() then
												local player = Convars:GetDOTACommandClient()
												local hero = PlayerResource:GetSelectedHeroEntity( 0 )
												if hero then
													local modifierTable = {}
													for _, modifier in ipairs( hero:FindAllModifiers() ) do
														local modifierInfo = {}
														modifierInfo.caster = modifier:GetCaster()
														modifierInfo.ability = modifier:GetAbility()
														modifierInfo.name = modifier:GetName()
														modifierInfo.duration = modifier:GetDuration()
														
														table.insert( modifierTable, modifierInfo )
														modifier:Destroy()
													end
													for _, modifierInfo in ipairs ( modifierTable ) do
														hero:AddNewModifier( modifierInfo.caster, modifierInfo.ability, modifierInfo.name, {duration = modifierInfo.duration})
													end
												end
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
															local namewhat = tostring(info.namewhat)
															if name ~= "__index" then
																print("Call: ".. src .. " -- " .. name .. " -- " .. namewhat)
															end
														end, "c")
													else
														print("Stopped DebugCalls")
														GameRules.DebugCalls = false
														debug.sethook(nil, "c")
													end
												end, "fixing bug",0)
	Convars:RegisterCommand( "listentotomb", function()
											if Convars:GetDOTACommandClient() and IsInToolsMode() then
												local player = Convars:GetDOTACommandClient()
												local hero = player:GetAssignedHero() 
												ListenToGameEvent( "entity_killed", require("events/base_combat"), self )
											end
										end, "fixing bug",0)													
	Convars:RegisterCommand( "spawn_elite", function(...) if IsInToolsMode() then return self.SpawnTestElites( ... ) end end, "",0)
	
	-- Hook into game events allowing reload of functions at run time
	
	ListenToGameEvent( "player_disconnect", Dynamic_Wrap( CHoldoutGameMode, 'OnPlayerDisconnected' ), self )
	
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( CHoldoutGameMode, "OnGameRulesStateChange" ), self )
	ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap( CHoldoutGameMode, "OnHeroPick"), self )
    ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(CHoldoutGameMode, 'OnAbilityUsed'), self)
    ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(CHoldoutGameMode, 'OnAbilityLearned'), self)
    ListenToGameEvent('dota_hero_inventory_item_change', Dynamic_Wrap(CHoldoutGameMode, 'OnInventoryChanged'), self)
	ListenToGameEvent( "dota_player_gained_level", Dynamic_Wrap( CHoldoutGameMode, "OnHeroLevelUp" ), self )
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( RoundManager, "OnNPCSpawned" ), RoundManager )
	ListenToGameEvent( "dota_holdout_revive_complete", Dynamic_Wrap( RoundManager, 'OnHoldoutReviveComplete' ), RoundManager )
	
	CustomGameEventManager:RegisterListener('Tell_Threat', Dynamic_Wrap( CHoldoutGameMode, 'Tell_threat'))
	CustomGameEventManager:RegisterListener('bh_notify_modifier', Dynamic_Wrap( CHoldoutGameMode, 'NotifyBuffs'))
	CustomGameEventManager:RegisterListener('playerUILoaded', Dynamic_Wrap( CHoldoutGameMode, 'OnPlayerUIInitialized'))
	CustomGameEventManager:RegisterListener('server_dota_push_to_chat', Dynamic_Wrap( CHoldoutGameMode, 'OnPushToChat'))

	-- Register OnThink with the game engine so it is called every 0.25 seconds
	GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( CHoldoutGameMode, "FilterOrders" ), self )
	GameRules:GetGameModeEntity():SetDamageFilter( Dynamic_Wrap( CHoldoutGameMode, "FilterDamage" ), self )
	GameRules:GetGameModeEntity():SetHealingFilter( Dynamic_Wrap( CHoldoutGameMode, "FilterHeal" ), self )
	GameRules:GetGameModeEntity():SetModifierGainedFilter( Dynamic_Wrap( CHoldoutGameMode, "FilterModifiers" ), self )
	GameRules:GetGameModeEntity():SetTrackingProjectileFilter( Dynamic_Wrap( CHoldoutGameMode, "FilterTrackingProjectiles" ), self )
	
	-- GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter( Dynamic_Wrap( CHoldoutGameMode, "FilterItemAddedToInventory" ), self ) -- fuck off valve
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, 1 )
	
	-- Custom stats
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP, 25) 
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP_REGEN, 0.1) 
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ARMOR, 0) 
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA, 20)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA_REGEN, 0.05)
	
	GameRules:GetGameModeEntity():SetPlayerHeroAvailabilityFiltered( true )
	
	TalentManager:StartTalentManager()
	ItemManager:StartItemManager()
	RelicManager:Initialize()
	
	SendToConsole("rate 200000")
end

function CHoldoutGameMode:OnPushToChat( event )
	local playerID = event.PlayerID
	local player = PlayerResource:GetPlayer(playerID)
	
	player.tellThreatDelayTimer = player.tellThreatDelayTimer or 0
	if Time() > player.tellThreatDelayTimer + 1 then
		if event.abilityID then	
			local ability = EntIndexToHScript( event.abilityID )
			event.abilityLevel = ability:GetLevel()
		end
		if event.isTeam and toboolean( event.isTeam ) then
			CustomGameEventManager:Send_ServerToTeam( PlayerResource:GetTeam( playerID ), "dota_push_to_chat", event )
		else
			CustomGameEventManager:Send_ServerToAllClients( "dota_push_to_chat", event )
		end
		player.tellThreatDelayTimer = Time();
	end
end

-- function CHoldoutGameMode:FilterItemAddedToInventory( filterTable )
	-- print( filterTable )
-- end

function CHoldoutGameMode:FilterTrackingProjectiles( filterTable )
	local target_index = filterTable["entindex_target_const"]
	local target = EntIndexToHScript( target_index )
	local attacker_index = filterTable["entindex_source_const"]
	local attacker = EntIndexToHScript( attacker_index )
	local ability_index = filterTable["entindex_ability_const"]
	local ability = EntIndexToHScript( ability_index )
	
	local dodgeable = toboolean( filterTable["dodgeable"] )
	local isAttack = toboolean( filterTable["is_attack"] )
	if isAttack and target then
		local params = {unit = attacker, target = target, is_attack = isAttack, dodgeable = dodgeable, ability = ability}
		for _, unit in ipairs( FindAllUnits() ) do
			if unit ~= target then
				for _, modifier in ipairs( unit:FindAllModifiers() ) do
					if modifier.GetTrackingProjectileRedirectChance and modifier:RollPRNG( modifier:GetTrackingProjectileRedirectChance(params) ) then
						attacker:PerformGenericAttack( unit )
						return false
					end
				end
			end
		end
	end
	return true
end

function CHoldoutGameMode:FilterModifiers( filterTable )
	local parent_index = filterTable["entindex_parent_const"]
    local caster_index = filterTable["entindex_caster_const"]
	local ability_index = filterTable["entindex_ability_const"]
	local name = filterTable["name_const"]
    if not parent_index or not caster_index then
        return true
    end
	local duration = filterTable["duration"]
    local parent = EntIndexToHScript( parent_index )
    local caster = EntIndexToHScript( caster_index )
	local ability 
	if ability_index then
		ability = EntIndexToHScript( ability_index )
	end
	local FilterModifiers = function( ... )
		if name == "modifier_item_ultimate_scepter" or  name == "modifier_item_ultimate_scepter_consumed" then
			for i = 0, parent:GetAbilityCount() - 1 do
				local scepterAbility = parent:GetAbilityByIndex( i )
				if scepterAbility and scepterAbility.OnInventoryContentsChanged then
					scepterAbility:OnInventoryContentsChanged()
				end
			end
		end
		-- if duration ~= -1 and parent and caster then
			-- local params = {caster = caster, target = parent, duration = duration, ability = ability, modifier_name = name}
			-- duration = duration * caster:GetStatusAmplification( params )
			-- if parent:GetTeam() ~= caster:GetTeam() then
				-- duration = duration * parent:GetStatusResistance( params )
			-- end
		-- end
		if parent then
			local params = {caster = caster, unit = parent, duration = duration, ability = ability, modifier_name = name}
			for _, modifier in ipairs( parent:FindAllModifiers() ) do
				if modifier.OnUnitModifierAdded then
					modifier:OnUnitModifierAdded(params)
				end
			end
		end
		if caster then
			local params = {caster = caster, unit = parent, duration = duration, ability = ability, modifier_name = name}
			for _, modifier in ipairs( caster:FindAllModifiers() ) do
				if modifier.OnUnitModifierAdded then
					modifier:OnUnitModifierAdded(params)
				end
			end
		end
		if parent == caster and parent:IsIllusion() and duration ~= -1 then
			for _, hero in ipairs( HeroList:GetRealHeroes() ) do
				if hero:GetUnitName() == parent:GetUnitName() and hero:HasModifier(name) then
					duration = hero:FindModifierByName(name):GetRemainingTime()
				end
				break
			end
		end
		if duration == 0 then return false end
		filterTable["duration"] = duration
		return true
	end
	status, err, ret = xpcall(FilterModifiers, debug.traceback, self, fPrep )
	if not status  and not self.gameHasBeenBroken then
		SendErrorReport(err, self)
	end
	return true
end

-- function CHoldoutGameMode:FilterGold( filterTable )
	-- PrintAll( filterTable )
	-- print("gold sold")
	-- return true
-- end

function CHoldoutGameMode:FilterHeal( filterTable )
	local healer_index = filterTable["entindex_healer_const"]
	local target_index = filterTable["entindex_target_const"]
	local source_index = filterTable["entindex_inflictor_const"]
	local heal = filterTable["heal"]
	local healer, target, source
	if healer_index then healer = EntIndexToHScript( healer_index ) end
	if target_index then target = EntIndexToHScript( target_index ) end
	if source_index then source = EntIndexToHScript( source_index ) end
	if not heal then return true end
	if target:GetHealth() <= 0 then return end
	if not target:IsAlive() then return end
	-- if no caster then source is regen
	local params = {healer = healer, target = target, heal = heal, ability = source}
	healFactorSelf = 1
	healFactorAllied = 1
	
	if healer and healer:IsRealHero() and target and healer ~= target and healer:HasRelic("relic_cursed_bloody_silk") then
		heal = heal + 50
		if not self:GetParent():HasModifier("relic_unique_ritual_candle") then ApplyDamage({victim = healer, attacker = healer, damage = 20, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION }) end
		if RoundManager:GetAscensions() >= 3 then
			healFactorSelf = healFactorSelf * 0.25
		end
	end
	local healing = math.max(0, heal * healFactorSelf * healFactorAllied) + (target.getLastExcessHealing or 0)
	target.getLastExcessHealing = healing % 1
	
	filterTable["heal"] = math.max(0, math.floor(healing) )
	if healer then healer.statsDamageHealed = (healer.statsDamageHealed or 0) + filterTable["heal"] end
	if healer and healer:GetTeam() == DOTA_TEAM_GOODGUYS then
		local realHeal =  math.min( target:GetHealthDeficit(), filterTable["heal"] ) 
		if realHeal > 1 then
			healer:ModifyThreat( (realHeal / 100) * math.log10(realHeal) )
		end 
	end
	
	return true
end

function CHoldoutGameMode:FilterOrders( filterTable )
	if not filterTable or not filterTable.units or not filterTable.units["0"] then return end
	local hero = EntIndexToHScript( filterTable.units["0"] )
	if not hero:IsRealHero() then return true end
	if filterTable["order_type"] == DOTA_UNIT_ORDER_SELL_ITEM then
		PrintAll(filterTable)
		local item = EntIndexToHScript( filterTable.entindex_ability )
		if item:GetPurchaseTime( ) + 10 <= GameRules:GetGameTime() or not item:IsCooldownReady() then
			local sellGold = item:GetCost() / 2
			hero:AddGold( -sellGold, false )
			hero:AddGold( sellGold, true, true )
		end
	end
	if filterTable["order_type"] == DOTA_UNIT_ORDER_PURCHASE_ITEM then
		hero.runeSlotSnapShot = {}
		for i=0, 25, 1 do
			local item = hero:GetItemInSlot(i)
			if item ~= nil then
				local itemData = {}
				itemData.entindex = item:entindex()
				itemData.runes = table.copy( item.itemData )
				hero.runeSlotSnapShot[i] = itemData
			end
		end
		PrintAll( hero.runeSlotSnapShot )
		Timers:CreateTimer(  function()
			for i=0, 5, 1 do
				local item = hero:GetItemInSlot(i)
				if item ~= nil then 
				end
				if item ~= nil 
				and (item.IsRuneStone and item:IsRuneStone()) 
				and item:GetAbilityName() == filterTable.shop_item_name then
					local itemModifier = hero:FindModifierByNameAndAbility( item:GetIntrinsicModifierName(), item )
					if itemModifier then itemModifier:ForceRefresh() end
				end
			end
		end)
	end
	if filterTable["order_type"] == DOTA_UNIT_ORDER_MOVE_ITEM then
		local item = EntIndexToHScript( filterTable.entindex_ability )
		local targetItem = hero:GetItemInSlot( filterTable["entindex_target"] )
		if not item or (item.IsRuneStone and item:IsRuneStone() and targetItem and targetItem:GetRuneSlots() > 0) then
			return false
		end
	end
	if filterTable["order_type"] == DOTA_UNIT_ORDER_PICKUP_ITEM then
		local itemContainer = EntIndexToHScript( filterTable.entindex_target )
		if itemContainer then
			local item = itemContainer:GetContainedItem()
			if item:GetName() == "item_tombstone" and hero:IsMuted() then
				EventManager:ShowErrorMessage(filterTable.issuer_player_id_const, "Cannot resurrect while muted.")
				return false
			end
		end
	end
	if RoundManager:IsRoundGoing()
	and RoundManager:GetCurrentEvent() 
	and RoundManager:GetCurrentEvent():IsEvent()
	and RoundManager:GetCurrentEvent()._playerChoices
	and RoundManager:GetCurrentEvent()._playerChoices[ filterTable["issuer_player_id_const"] ] == nil
	and (filterTable["order_type"] == DOTA_UNIT_ORDER_DROP_ITEM 
	or filterTable["order_type"] == DOTA_UNIT_ORDER_GIVE_ITEM
	or filterTable["order_type"] == DOTA_UNIT_ORDER_PURCHASE_ITEM
	or filterTable["order_type"] == DOTA_UNIT_ORDER_DISASSEMBLE_ITEM
	or filterTable["order_type"] == DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH ) then
		EventManager:ShowErrorMessage(filterTable.issuer_player_id_const, "Cannot manipulate inventory during events until voted.")
		return false
	end
	if GameRules:State_Get() < DOTA_GAMERULES_STATE_GAME_IN_PROGRESS 
	and ( filterTable["order_type"] == DOTA_UNIT_ORDER_CAST_POSITION
	or filterTable["order_type"] == DOTA_UNIT_ORDER_CAST_TARGET 
	or filterTable["order_type"] == DOTA_UNIT_ORDER_CAST_TARGET_TREE 
	or filterTable["order_type"] == DOTA_UNIT_ORDER_CAST_NO_TARGET 
	or filterTable["order_type"] == DOTA_UNIT_ORDER_CAST_TOGGLE ) 
	and not IsInToolsMode() then
		EventManager:ShowErrorMessage(filterTable.issuer_player_id_const, "Cannot cast abilities during pregame.")
		return false
	end
	if filterTable["order_type"] == DOTA_UNIT_ORDER_TRAIN_ABILITY then
		local talent = EntIndexToHScript( filterTable["entindex_ability"] )
		if talent and string.match( talent:GetAbilityName(), "special_bonus" ) and hero:GetLevel() < (hero.talentsSkilled + 1) * 10 then
			return false
		end
	end
	return VectorTarget:OrderFilter(filterTable)
	-- return VectorTarget:OrderFilter(filterTable)
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
	if attacker:GetTeam() == DOTA_TEAM_GOODGUYS and ( not attacker:IsRealHero() or attacker:IsFakeHero() ) and attacker:GetOwner() then 
		if attacker:GetOwner():IsPlayer() then
			attacker = attacker:GetOwner():GetAssignedHero()
		else
			attacker = attacker:GetOwner()
		end
	end
	if original_attacker:GetTeam() ~= victim:GetTeam() and not victim:CanEntityBeSeenByMyTeam(original_attacker) then
		original_attacker:MakeVisibleDueToAttack( victim:GetTeam(), 128 )
	end
	--- DAMAGE MANIPULATION ---
	if ( victim:IsHero() and victim:HasRelic("relic_unbridled_power") and not victim:HasRelic("relic_ritual_candle") ) or ( attacker:IsHero() and attacker:HasRelic("relic_unbridled_power") ) then
		if damagetype == DAMAGE_TYPE_MAGICAL then
			filterTable["damage"] = filterTable["damage"] / ( 1 - victim:GetMagicalArmorValue() )
		elseif damagetype == DAMAGE_TYPE_PHYSICAL then
			filterTable["damage"] = filterTable["damage"] / ( 1 - victim:GetPhysicalArmorReduction()/100 )
		end
		filterTable["damagetype_const"] = DAMAGE_TYPE_PURE
	end
	--- THREAT AND UI NO MORE DAMAGE MANIPULATION ---
	local damage = filterTable["damage"]
	local attacker = original_attacker
	if attacker:GetTeam() == DOTA_TEAM_BADGUYS then
		if victim:IsRealHero() then
			victim.statsDamageTaken = (victim.statsDamageTaken or 0) + math.min(victim:GetHealth(), damage)
		end
		return true 
	end
	if not victim:IsHero() and victim ~= attacker and damage > 1 then
		-- if not victim.threatTable then victim.threatTable = {} end
		if not attacker.threat then attacker.threat = 0 end
		local addedthreat = damage / 100 * math.log10(damage)
		if addedthreat > 0.01 then
			original_attacker:ModifyThreat( addedthreat )
		end
	end
    local attackerID = attacker:GetPlayerOwnerID()
    if attackerID and PlayerResource:HasSelectedHero( attackerID ) then
	    local hero = PlayerResource:GetSelectedHeroEntity(attackerID)
	    local player = PlayerResource:GetPlayer(attackerID)
		if hero then
			if victim:GetTeam() == DOTA_TEAM_BADGUYS then
				hero.statsDamageDealt = (hero.statsDamageDealt or 0) + math.min(victim:GetHealth(), damage)
			end
		end
    end
	
    return true
end


function GetHeroDamageDone(hero)
    return hero.damageDone
end

function CHoldoutGameMode:OnInventoryChanged( event )
	local hero = EntIndexToHScript( event.hero_entindex )
	local item = EntIndexToHScript( event.item_entindex )
	local vector_data = {}
	if item and item:GetName() == "item_aghanims_shard" then
		local talents = hero.heroTalentDataContainer.uniqueTalents
		
		local talentsToChoose = {}
		for ability, talentTable in pairs( talents ) do
			for talentName, levelRequirement in pairs( talentTable ) do
				if levelRequirement ~= -1 then
					table.insert( talentsToChoose, talentName )
				end
			end
		end
		
		local randomTalent = talentsToChoose[RandomInt(1, #talentsToChoose)]
		local talentEntity = hero:FindAbilityByName(randomTalent)
		if talentEntity then
			talentEntity:SetLevel(1)
			for ability, talentTable in pairs( talents ) do
				if talentTable[randomTalent] then
					for talentID, levelRequirement in pairs(talentTable) do
						if talentID == randomTalent then
							talentTable[talentID] = -1
						end
					end
				end
			end
			local talentData = CustomNetTables:GetTableValue("talents", tostring(hero:entindex())) or {}
			if GameRules.AbilityKV[randomTalent] then
				if GameRules.AbilityKV[randomTalent]["LinkedModifierName"] then
					local modifierName = GameRules.AbilityKV[randomTalent]["LinkedModifierName"] 
					for _, unit in ipairs( FindAllUnits() ) do
						if unit:HasModifier(modifierName) then
							local mList = unit:FindAllModifiersByName(modifierName)
							for _, modifier in ipairs( mList ) do
								if modifier:HasAuraOrigin() then
									modifier:Destroy()
								else
									local remainingDur = modifier:GetRemainingTime()
									modifier:ForceRefresh()
									if remainingDur > 0 then modifier:SetDuration(remainingDur, true) end
								end
							end
						end
					end
				end
				if GameRules.AbilityKV[randomTalent]["LinkedAbilityName"] then
					local randomTalent = GameRules.AbilityKV[randomTalent]["LinkedAbilityName"] or ""
					local ability = hero:FindAbilityByName(randomTalent)
					if ability and ability.OnTalentLearned then
						ability:OnTalentLearned(randomTalent)
					end
				end
				talentData[randomTalent] = true
				CustomNetTables:SetTableValue( "talents", tostring(hero:entindex()), talentData )
				hero.talentsSkilled = hero.talentsSkilled + 1
				
				GameRules.bossHuntersEntity:OnAbilityLearned( {PlayerID = hero:GetPlayerID(), abilityname = randomTalent} )
				CustomGameEventManager:Send_ServerToAllClients("dota_player_talent_update", {PlayerID = pID, hero_entindex = entindex} )
			end
		end
	end
	if item and HasBit( item:GetBehavior(), DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING ) then
		if not event.removed then
			vector_data.startWidth = item:GetVectorTargetStartRadius()
			vector_data.endWidth = item:GetVectorTargetEndRadius()
			vector_data.castLength = item:GetVectorTargetRange()
		else
			vector_data = nil
		end
		CustomNetTables:SetTableValue( "vector_targeting", item:entindex().."", vector_data )
	end
end

function CHoldoutGameMode:OnAbilityLearned( event )
	local playerID = event.PlayerID
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)
	local ability = hero:FindAbilityByName(event.abilityname)
	local vector_data = {}
	if ability and HasBit( ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING ) then
		vector_data.startWidth = ability:GetVectorTargetStartRadius()
		vector_data.endWidth = ability:GetVectorTargetEndRadius()
		vector_data.castLength = ability:GetVectorTargetRange()
		CustomNetTables:SetTableValue( "vector_targeting", ability:entindex().."", vector_data )
	end
end

function CHoldoutGameMode:OnHeroLevelUp(event)
	local unit = EntIndexToHScript(event.hero_entindex)
	local playerID = unit:GetPlayerID()
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)
	if hero == unit then
		if hero:GetLevel() % 10 == 0 then
			hero:ModifyTalentPoints(1)
		end
		if hero:GetLevel() < 27 or hero:GetLevel() == 30 then
			hero.bonusSkillPoints = ( hero.bonusSkillPoints or ( hero:GetAbilityPoints() - 1 ) ) + 1
			if hero:GetLevel() == 17 or hero:GetLevel() == 19 or (hero:GetLevel() > 20 and hero:GetLevel() < 27) or hero:GetLevel() == 30 then
				hero:SetAbilityPoints( hero:GetAbilityPoints() + 1)
			end
		elseif (hero:GetLevel() == 31
			or hero:GetLevel() == 36
			or hero:GetLevel() == 40
			or hero:GetLevel() == 50
			or hero:GetLevel() == 60
			or hero:GetLevel() == 70
			or hero:GetLevel() == 80) then
				hero:SetAbilityPoints( hero:GetAbilityPoints() + 1)
				hero.bonusSkillPoints = (hero.bonusSkillPoints or 0) + 1
		else
			hero:SetAbilityPoints( hero:GetAbilityPoints() + 1)
		end
		-- fix valve's bullshit auto-talent leveling
		-- take snapshot at lv 29
		if hero:GetLevel() == 29 then
			hero.savedTalentData = CustomNetTables:GetTableValue("talents", tostring(hero:entindex())) or {}
			hero.savedTalentsSkilled = hero.talentsSkilled
		end
		-- reset to snapshot at 30
		if hero:GetLevel() == 30 then
			Timers:CreateTimer(0.1, function()
				local talentData = hero.savedTalentData
				hero.talentsSkilled = hero.savedTalentsSkilled
				for i = 0, 23 do
					local ability = hero:GetAbilityByIndex(i)
					if ability then
						abilityname = ability:GetAbilityName()
						if string.match(abilityname, "special_bonus" ) and not talentData[abilityname] then
							ability:SetLevel(0)
							if GameRules.AbilityKV[abilityname] then
								if GameRules.AbilityKV[abilityname]["LinkedModifierName"] then
									local modifierName = GameRules.AbilityKV[abilityname]["LinkedModifierName"] 
									for _, unit in ipairs( FindAllUnits() ) do
										if unit:HasModifier(modifierName) then
											local mList = unit:FindAllModifiersByName(modifierName)
											for _, modifier in ipairs( mList ) do
												if modifier:HasAuraOrigin() then
													modifier:Destroy()
												else
													local remainingDur = modifier:GetRemainingTime()
													modifier:ForceRefresh()
													if remainingDur > 0 then modifier:SetDuration(remainingDur, true) end
												end
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
						end
					end
				end
				CustomNetTables:SetTableValue( "talents", tostring(hero:entindex()), talentData )
				CustomGameEventManager:Send_ServerToAllClients("dota_player_upgraded_stats", {playerID = hero:GetPlayerID()} )
			end)
		end
	end
end

function CHoldoutGameMode:OnAbilityUsed(event)
    local PlayerID = event.PlayerID
    local abilityname = event.abilityname
	local hero = EntIndexToHScript( event.caster_entindex )
	
	if not hero then return end
	if not abilityname then return end
	AddFOWViewer(DOTA_TEAM_BADGUYS, hero:GetAbsOrigin(), 256, 1.5, false)
	local abilityused = hero:FindAbilityByName(abilityname)
	if not abilityused then abilityused = hero:FindItemByName(abilityname, false) end
	if not abilityused then return end
	-- if abilityused then
		-- local addedthreat = abilityused:GetThreat()
		-- local modifier = 0
		-- local escapemod = 0
		-- local talentmodifier = 0
		-- local negtalentmodifier = 0
		
		-- if addedthreat < 0 then
			-- escapemod = 2
		-- end
		-- if abilityused and not abilityused:IsItem() then modifier = (addedthreat*abilityused:GetLevel())/abilityused:GetMaxLevel() end
		-- if not hero.threat then hero.threat = 0 end
		-- hero:ModifyThreat(addedthreat + modifier + talentmodifier - negtalentmodifier)
		-- local player = PlayerResource:GetPlayer(PlayerID)
		-- hero.lastHit = GameRules:GetGameTime() - escapemod
		-- PlayerResource:SortThreat()
		-- local event_data =
		-- {
			-- threat = hero.threat,
			-- lastHit = hero.lastHit,
			-- aggro = hero.aggro
		-- }
		-- if player then
			-- CustomGameEventManager:Send_ServerToPlayer( player, "Update_threat", event_data )
		-- end
	-- end
	-- if abilityused and abilityused:HasPureCooldown() then
		-- if abilityname == "viper_nethertoxin" and not hero:HasTalent("special_bonus_unique_viper_3") then return end
		-- abilityused:EndCooldown()
		-- if abilityused:GetDuration() > 0 then
			-- local duration = abilityused:GetDuration()
			-- for _, modifier in ipairs( hero:FindAllModifiers() ) do
				-- if modifier.GetModifierStatusAmplify_Percentage then
					-- duration = duration * (1 + modifier:GetModifierStatusAmplify_Percentage( params )/100)
				-- end
			-- end
			-- abilityused:StartDelayedCooldown(duration)
		-- else
			-- abilityused:StartCooldown(abilityused:GetCooldown(-1))
		-- end
	-- end
end

function CHoldoutGameMode:Tell_threat(event)
	--print ("show asura core count")
	local pID = event.PlayerID
	local player = PlayerResource:GetPlayer(pID)
	player.tellThreatDelayTimer = player.tellThreatDelayTimer or 0
	if GameRules:GetGameTime() > player.tellThreatDelayTimer + 1 then
		Say(player, event.threatText, true)
		player.tellThreatDelayTimer = GameRules:GetGameTime()
	end
end

function CHoldoutGameMode:NotifyBuffs(event)
	--print ("show asura core count")
	local pID = event.pID
	local player = PlayerResource:GetPlayer(pID)
	local hero = player:GetAssignedHero() 
	if not hero.threat then hero.threat = 0 end
	local result = math.floor( hero.threat*10 + 0.5 ) / 10
	if result == 0 then result = "no" end
	local message = "Enemy "..event.unitname.." is affected by: "..event.buffname.." - "..event.duration.." seconds remaining!"
	hero.tellBuffDelayTimer = hero.tellBuffDelayTimer or 0
	if GameRules:GetGameTime() > hero.tellBuffDelayTimer + 1 then
		Say(player, message, true)
		hero.tellBuffDelayTimer = GameRules:GetGameTime()
	end
end


function CHoldoutGameMode:OnHeroPick (event)
 	local hero = EntIndexToHScript(event.heroindex)
	if not hero then return end
	if hero.hasBeenInitialized then return end
	if hero:IsFakeHero() then return end
	Timers:CreateTimer(0.03, function()
		if hero:IsFakeHero() then return end
		
		hero.damageDone = 0
		hero.hasBeenInitialized = true
		
		TalentManager:RegisterPlayer(hero)
		RelicManager:RegisterPlayer( hero:GetPlayerID() )
		hero:AddItemByName("item_potion_of_recovery")
		hero:AddItemByName("item_potion_of_essence")
		
		for i = 0, 17 do
			local skill = hero:GetAbilityByIndex(i)
			if skill and skill:IsInnateAbility() then
				skill:UpgradeAbility(true)
			end
		end
		-- hero:AddExperience(GameRules.XP_PER_LEVEL[7],false,false)
		if GameRules:GetGameDifficulty() > 2 then
		else
			 hero:AddExperience(GameRules.XP_PER_LEVEL[3],false,false)
		end
		if hero:IsRangedAttacker() then
			hero:SetBaseMagicalResistanceValue(15.1)
		else
			hero:SetBaseMagicalResistanceValue(25.1)
		end
		hero:SetPhysicalArmorBaseValue( hero:GetPhysicalArmorBaseValue() + hero:GetAgility() * 0.17 )
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
			if PlayerResource:IsKarien(ID) then
				ParticleManager:FireParticle("particles/roles/karien_trail_spirit.vpcf", PATTACH_POINT_FOLLOW, hero)
			end
			if PlayerResource:IsSunrise(ID) then
				ParticleManager:FireParticle("particles/roles/sunrise/sunrise_trail_water.vpcf", PATTACH_POINT_FOLLOW, hero)
			end
		end
		local gold = 200 + 150 * ( GameRules.BasePlayers - PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) )
		hero:SetGold( 0, true )
		if PlayerResource:HasRandomed( ID ) then
			gold = gold + 500
		end
		hero:SetGold( gold, true )
	end)
end

function CHoldoutGameMode:OnPlayerUIInitialized(keys)
	local playerID = keys.PlayerID
	local player = PlayerResource:GetPlayer(playerID)
	Timers:CreateTimer(0.03, function()
		if PlayerResource:GetSelectedHeroEntity(playerID) then
			local hero = PlayerResource:GetSelectedHeroEntity(playerID)
			CustomGameEventManager:Send_ServerToPlayer(player,"dota_player_updated_relic_drops", {playerID = pID, drops = hero.relicsToSelect})
			if TalentManager:IsPlayerRegistered(hero) and not hero:HasModifier("modifier_stats_system_handler") then hero:AddNewModifier(hero, nil, "modifier_stats_system_handler", {}) end
			CustomGameEventManager:Send_ServerToPlayer(player, "heroLoadIn", {})
			if GameRules.UnitKV[hero:GetUnitName()]["Abilities"] and not hero.hasSkillsSelected then
				CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "checkNewHero", {})
			end
			if GameRules.bossHuntersEntity._currentRound then CustomGameEventManager:Send_ServerToAllClients( "updateQuestRound", { roundNumber = GameRules.bossHuntersEntity._nRoundNumber, roundText = GameRules.bossHuntersEntity._currentRound._szRoundQuestTitle } ) end
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
	for pID = 0, 24 do -- check if game has to die
		if PlayerResource:IsValidPlayerID( pID ) and PlayerResource:GetConnectionState( pID ) == DOTA_CONNECTION_STATE_CONNECTED then
			return
		end
	end
	RoundManager:GameIsFinished(false)
end

-- When game state changes set state in script
function CHoldoutGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	-- if nNewState >= DOTA_GAMERULES_STATE_INIT and not statCollection.doneInit then
		-- statCollection:init()
		-- print("start")
    -- end
	if nNewState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		print("setup")
		for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			if PlayerResource:IsValidPlayerID( nPlayerID ) then
				PlayerResource:SetCustomTeamAssignment(nPlayerID, DOTA_TEAM_GOODGUYS)
			end
		end
	elseif nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		print("pregame")
		
		local heroList = {}
		heroList["DOTA_ATTRIBUTE_STRENGTH"] = {}
		heroList["DOTA_ATTRIBUTE_AGILITY"] = {}
		heroList["DOTA_ATTRIBUTE_INTELLECT"] = {}
		heroList["DOTA_ATTRIBUTE_ALL"] = {}
		for hero, active in pairs( GameRules.HeroList ) do
			if tonumber(active) == 0 then
				-- activeList[hero] = nil
			else
				local primaryAttribute = GameRules.UnitKV[hero].AttributePrimary
				table.insert( heroList[primaryAttribute], hero )
			end
		end
		for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			local listCpy = MergeTables( heroList, {} )
			if PlayerResource:IsValidPlayerID( nPlayerID ) then
				-- if PlayerResource:IsDeveloper( nPlayerID ) then
					for category, heroes in pairs( listCpy ) do
						for _, hero in ipairs( heroes ) do
							GameRules:AddHeroToPlayerAvailability( nPlayerID, DOTAGameManager:GetHeroIDByName( hero ) )
						end
					end
				-- else
					-- for category, heroes in pairs( listCpy ) do
						-- for i = 1, 3 do
							-- local selected = RandomInt( 1, #heroes )
							-- local randomHero = heroes[selected]
							-- table.remove( heroes, selected )
							-- GameRules:AddHeroToPlayerAvailability( nPlayerID, DOTAGameManager:GetHeroIDByName( randomHero ) )
						-- end
					-- end
				-- end
			end
		end
		
		RoundManager.spawnPositions = {}
		RoundManager.boundingBox = "grove_raid_1"
		for _,spawnPos in ipairs( Entities:FindAllByName( RoundManager.boundingBox.."_spawner" ) ) do
			table.insert( RoundManager.spawnPositions, spawnPos:GetAbsOrigin() )
		end
		RoundManager.heroSpawnPosition = RoundManager.heroSpawnPosition or nil
		for _,spawnPos in ipairs( Entities:FindAllByName( RoundManager.boundingBox.."_heroes") ) do
			RoundManager.heroSpawnPosition = spawnPos:GetAbsOrigin()
			break
		end
		
		ClientServer:Initialize()
		Timers:CreateTimer(HERO_SELECTION_TIME - 1,function()
			for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
				if not PlayerResource:HasSelectedHero( nPlayerID ) and PlayerResource:GetPlayer( nPlayerID ) then
					local player = PlayerResource:GetPlayer( nPlayerID )
					player:MakeRandomHeroSelection()
					PlayerResource:SetHasRandomed( nPlayerID )
				end
			end
		end)
	elseif nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		-- Voting system handler
		-- CHoldoutGameMode:InitializeRoundSystem()
		Timers:CreateTimer(0.1,function()
			CustomGameEventManager:Send_ServerToAllClients( "updateQuestLife", { lives = GameRules._lives, maxLives = GameRules._maxLives } )
			local say = false
			CustomGameEventManager:Send_ServerToAllClients("heroLoadIn", {})
			for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
				if PlayerResource:GetPlayer( nPlayerID ) and not say then
					say = true
					Say( PlayerResource:GetPlayer( nPlayerID ), "Alt-clicking event cards will minimize them", true)
				end
			end
		end)
	elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		RoundManager:StartGame()
		Timers:CreateTimer(1,function()
			if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
				if RoundManager:GetCurrentEvent() and not RoundManager:GetCurrentEvent():IsEvent() then
					for _, hero in ipairs( HeroList:GetRealHeroes() ) do
						hero:AddGold(1, false)
					end
				end
				return 1
			end
			
		end)
	end
end

function CHoldoutGameMode:OnThink()
	DAY_TIME = 1
	NIGHT_TIME = 0
	TEMPORARY_NIGHT = 2
	NIGHT_STALKER_NIGHT = 3
	local timeofday = 1
	
	if GameRules:IsGamePaused() then return 1 end
	if not GameRules:IsDaytime() then timeofday = NIGHT_TIME end
	if GameRules:IsTemporaryNight() then timeofday = TEMPORARY_NIGHT end
	if GameRules:IsNightstalkerNight() then timeofday = NIGHT_STALKER_NIGHT end
	CustomNetTables:SetTableValue( "game_info", "timeofday", {timeofday = timeofday} )
	if GameRules:State_Get() >= 7 and GameRules:State_Get() <= 9 then
		local OnPThink = function(self)
			local playerData = {}
			local currTime = GameRules:GetGameTime()
			-- for _,unit in ipairs ( FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0), nil, -1, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_DEAD, FIND_ANY_ORDER, false) ) do
				-- if not unit:IsNull() and not unit:IsRealHero() and unit:GetHealth() <= 0 and not unit.confirmTheKill then
					-- unit.confirmTheKill = true
					-- unit:SetHealth(1)
					-- unit:ForceKill( false )
					-- if not unit:IsRealHero() and not unit:UnitCanRespawn() then
						-- Timers:CreateTimer(1, function()
							-- if not unit:IsNull() then UTIL_Remove( unit ) end
						-- end)
					-- end
				-- end
			-- end
			for _,unit in ipairs ( HeroList:GetActiveHeroes() ) do
				if unit:IsRealHero() and not unit:IsFakeHero() then
					if unit:GetPlayerOwner() and unit:GetAttackTarget() and unit.lastAttackTargetUI ~= unit:GetAttackTarget() then
						unit.lastAttackTargetUI = unit:GetAttackTarget()
						CustomGameEventManager:Send_ServerToPlayer( unit:GetPlayerOwner(), "bh_update_attack_target", {entindex = unit:GetAttackTarget():entindex()} )
					end
					playerData[unit:GetPlayerID()] = {damageTaken = unit.statsDamageTaken or 0, damageDealt = unit.statsDamageDealt or 0, damageHealed = unit.statsDamageHealed or 0, deaths = unit.statsDeaths or 0 }
					-- Threat
					if unit.threat then
					if not unit:IsAlive() then
						unit.threat = 0
					end
					if unit.threat < 0 then unit.threat = 0 end
					else unit.threat = 0 end
					if unit.lastHit then
						if unit.lastHit + 2 <= currTime and unit.threat > 0 then
							unit:ModifyThreat( -math.max( 0.5, unit.threat/10 ) )
						end
					else unit.lastHit = currTime end
				end	
			end
			CustomGameEventManager:Send_ServerToAllClients( "player_update_stats", playerData )
		end
		status, err, ret = pcall(OnPThink, self)
		if not status  and not self.gameHasBeenBroken then
			SendErrorReport(err, self)
		end
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then		-- Safe guard catching any state that may exist beyond DOTA_GAMERULES_STATE_POST_GAME
		return nil
	end
	return 0.33
end

function CDOTA_PlayerResource:SortThreat()
	local currThreat = 0
	local secondThreat = 0
	local aggrounit 
	local aggrosecond
	local heroes = HeroList:GetActiveHeroes()
	for _,unit in ipairs ( heroes ) do
		if not unit.threat then unit.threat = 0 end
		if not unit:IsFakeHero() then
			if unit.threat > currThreat then
				currThreat = unit.threat
				aggrounit = unit
			elseif unit.threat > secondThreat and unit.threat < currThreat then
				secondThreat = unit.threat
				aggrosecond = unit
			end
		end
	end
	for _,unit in pairs ( heroes ) do
		if unit == aggrosecond then unit.aggro = 2
		elseif unit == aggrounit then unit.aggro = 1
		else unit.aggro = 0 end
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
			local spawnLoc = RoundManager:PickRandomSpawn()
			PrecacheUnitByNameAsync( spawnName, function()
				local entUnit = CreateUnitByName( spawnName, spawnLoc, true, nil, nil, DOTA_TEAM_BADGUYS )
				if elite then
					entUnit:AddAbilityPrecache(elite):UpgradeAbility(true)
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