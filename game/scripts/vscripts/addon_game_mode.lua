MAXIMUM_ATTACK_SPEED	= 700
MINIMUM_ATTACK_SPEED	= 20

ROUND_END_DELAY = 3

DOTA_LIFESTEAL_SOURCE_NONE = 0
DOTA_LIFESTEAL_SOURCE_ATTACK = 1
DOTA_LIFESTEAL_SOURCE_ABILITY = 2

MAP_CENTER = Vector(332, -1545)
GAME_MAX_LEVEL = 400

GLOBAL_STUN_LIST = {}

if CHoldoutGameMode == nil then
	CHoldoutGameMode = class({})
end

function SendErrorReport(err, context)
	Notifications:BottomToAll({text="An error has occurred! Please screenshot this: "..err, duration=15.0})
	print(err)
	if context then context.gameHasBeenBroken = true end
end

require("lua_map/map")
require( "libraries/Timers" )
require( "libraries/notifications" )
require( "statcollection/init" )
require("libraries/utility")
require( "libraries/clientserver" )
require("libraries/animations")
require("stats_screen")
require("relicmanager")
require("roundmanager")
require("eventmanager")
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
	
	RoundManager:Initialize(context)
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
	GameRules._Elites = LoadKeyValues( "scripts/kv/elites.kv" )
	GameRules._maxLives = 10
	GameRules.gameDifficulty = 1
	
	GameRules.UnitKV = LoadKeyValues("scripts/npc/npc_heroes.txt")
	GameRules.UnitKV = MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_heroes_custom.txt"))
	GameRules.UnitKV = MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_units.txt"))
	GameRules.UnitKV = MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_units_custom.txt"))
	
	GameRules.AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
	GameRules.AbilityKV = MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/npc_abilities_override.txt"))
	GameRules.AbilityKV = MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/npc_items_custom.txt"))
	GameRules.AbilityKV = MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/items.txt"))
	
	GameRules.HeroList = LoadKeyValues("scripts/npc/activelist.txt")
	
	print(GetMapName())
	
	self._message = false
	
	GameRules:SetHeroSelectionTime( 80.0 )
	if IsInToolsMode() then
		GameRules:SetPreGameTime( 9999.0 )
	else
		GameRules:SetPreGameTime( 30.0 )
	end
	GameRules:SetShowcaseTime( 0 )
	GameRules:SetStrategyTime( 0 )
	GameRules:SetCustomGameSetupAutoLaunchDelay( 0 ) -- fix valve bullshit
	
	local mapInfo = LoadKeyValues( "addoninfo.txt" )[GetMapName()]
	
	GameRules.BasePlayers = mapInfo.MaxPlayers
	GameRules._maxLives =  mapInfo.Lives
	GameRules.gameDifficulty =  mapInfo.Difficulty
	CustomNetTables:SetTableValue( "game_info", "difficulty", {difficulty = GameRules.gameDifficulty} )
	CustomNetTables:SetTableValue( "game_info", "timeofday", {timeofday = 0} )

	GameRules._lives = GameRules._maxLives
	CustomGameEventManager:Send_ServerToAllClients( "updateQuestLife", { lives = GameRules._lives, maxLives = GameRules._maxLives } )
	
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, mapInfo.MaxPlayers)
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0)
	
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetUseUniversalShopMode( true )

	GameRules:SetTreeRegrowTime( 30.0 )
	GameRules:SetCreepMinimapIconScale( 4 )
	GameRules:SetRuneMinimapIconScale( 1.5 )
	GameRules:SetGoldTickTime( 1 )
	GameRules:SetGoldPerTick( 1 )
	
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
	Convars:RegisterCommand( "game_tools_ask_nettable_info", function()
																local player = Convars:GetDOTACommandClient()
																Timers:CreateTimer(function()
																	if not player or player:IsNull() then return end
																	CustomGameEventManager:Send_ServerToPlayer( player, "game_tools_ask_nettable_info", {} )
																	return 1
																end)
															end, "test",0)
	Convars:RegisterCommand( "bh_test_round", function( command, zone, roundName, roundType )
											print( command, zone, roundName, roundType )
											if Convars:GetDOTACommandClient() and IsInToolsMode() then
												RoundManager:EndEvent(false)
												RoundManager:EndPrepTime(true)
												local event = BaseEvent(zone, roundType, roundName )
												RoundManager.zones[RoundManager.currentZone][1][1] = event
												GameRules:SetLives(3)
												RoundManager:StartPrepTime()
											end
										end, "adding relics",0)
	Convars:RegisterCommand( "bh_unit_stress_test", function( command, units )
											if Convars:GetDOTACommandClient() and IsInToolsMode() then
												local hero = Convars:GetDOTACommandClient():GetAssignedHero()
												units = units or 10
												for i = 1, units do 
													CreateUnitByNameAsync(
														"npc_dota_creature_spiderling",
														hero:GetAbsOrigin() + RandomVector(600),
														false,
														nil,
														nil,
														DOTA_TEAM_BADGUYS,
														function(unit)
															
														end
													)
												end
											end
										end, "adding relics",0)
	Convars:RegisterCommand( "clear_relics", function()
											if Convars:GetDOTACommandClient() and IsInToolsMode() then
												local player = Convars:GetDOTACommandClient()
												RelicManager:ClearRelics(player:GetPlayerID(), true) 
											end
										end, "adding relics",0)
	Convars:RegisterCommand( "add_relic", function(command, relicName)
											if Convars:GetDOTACommandClient() then
												local player = Convars:GetDOTACommandClient()
												if not ( PlayerResource:IsDeveloper( player:GetPlayerID() ) or PlayerResource:IsManager( player:GetPlayerID() ) ) then return end
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
	
	ListenToGameEvent( "player_disconnect", Dynamic_Wrap( CHoldoutGameMode, 'OnPlayerDisconnected' ), self )
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( CHoldoutGameMode, "OnGameRulesStateChange" ), self )
	ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap( CHoldoutGameMode, "OnHeroPick"), self )
    ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(CHoldoutGameMode, 'OnAbilityUsed'), self)
	ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(CHoldoutGameMode, 'OnAbilityLearned'), self)
	ListenToGameEvent( "dota_player_gained_level", Dynamic_Wrap( CHoldoutGameMode, "OnHeroLevelUp" ), self )
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( RoundManager, "OnNPCSpawned" ), RoundManager )
	ListenToGameEvent( "dota_holdout_revive_complete", Dynamic_Wrap( RoundManager, 'OnHoldoutReviveComplete' ), RoundManager )
	
	CustomGameEventManager:RegisterListener('Tell_Threat', Dynamic_Wrap( CHoldoutGameMode, 'Tell_threat'))
	CustomGameEventManager:RegisterListener('bh_notify_modifier', Dynamic_Wrap( CHoldoutGameMode, 'NotifyBuffs'))
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
		local amp = 0
		for _, modifier in ipairs( caster:FindAllModifiers() ) do
			if modifier.GetModifierStatusAmplify_Percentage then
				amp = amp + modifier:GetModifierStatusAmplify_Percentage( params )
			end
		end
		filterTable["duration"] = filterTable["duration"] * math.max( 0.25, 1 + (amp / 100) )
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
			filterTable["duration"] = filterTable["duration"] * math.max(0, (1 - resistance/100)) * math.max(0, (1 - stackResist/100))
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
	local params = {healer = healer, target = target, heal = heal, ability = source}
	healFactorSelf = 1
	healFactorAllied = 1
	if target then
		for _, modifier in ipairs( target:FindAllModifiers() ) do
			if modifier.GetModifierHealAmplify_Percentage then
				healFactorSelf = healFactorSelf + (modifier:GetModifierHealAmplify_Percentage( params ) or 0 )/100
			end
		end
		if RoundManager:GetAscensions() >= 3 then
			healFactorSelf = healFactorSelf - 0.75
		end
	end
	if healer and healer ~= target then
		for _, modifier in ipairs( healer:FindAllModifiers() ) do
			if modifier.GetModifierHealAmplify_Percentage then
				healFactorAllied = healFactorAllied + ( modifier:GetModifierHealAmplify_Percentage( params ) or 0 )/100
			end
		end
		if RoundManager:GetAscensions() >= 3 then
			healFactorAllied = healFactorAllied - 0.75
		end
	end
	
	if not healer_index or not heal then return true end
	filterTable["heal"] = math.max(0, heal * healFactorSelf * healFactorAllied)
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
	if RoundManager:GetCurrentEvent() 
	and RoundManager:GetCurrentEvent():IsEvent()
	and RoundManager:GetCurrentEvent()._playerChoices
	and RoundManager:GetCurrentEvent()._playerChoices[ filterTable["issuer_player_id_const"] ] == nil
	and (filterTable["order_type"] == DOTA_UNIT_ORDER_DROP_ITEM 
	or filterTable["order_type"] == DOTA_UNIT_ORDER_GIVE_ITEM
	or filterTable["order_type"] == DOTA_UNIT_ORDER_PURCHASE_ITEM
	or filterTable["order_type"] == DOTA_UNIT_ORDER_DISASSEMBLE_ITEM
	or filterTable["order_type"] == DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH ) then
		return false
	end
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
			ApplyDamage({victim = victim, attacker = attacker, damage = damage * (1- victim:GetPhysicalArmorReduction() / 100 ), damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
		elseif damagetype == DAMAGE_TYPE_MAGICAL then
			ApplyDamage({victim = victim, attacker = attacker, damage = damage * (1 - victim:GetMagicalArmorValue()), damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
		end
		return false
	end

	if original_attacker:GetTeam() == DOTA_TEAM_BADGUYS then
		AddFOWViewer(DOTA_TEAM_GOODGUYS, original_attacker:GetAbsOrigin(), 256, 1, false)
	else
		AddFOWViewer(DOTA_TEAM_BADGUYS, original_attacker:GetAbsOrigin(), 256, 1, false)
	end

	--- THREAT AND UI NO MORE DAMAGE MANIPULATION ---
	local damage = filterTable["damage"]
	local attacker = original_attacker
	if attacker:GetPlayerOwnerID() then 
		local mainHero = PlayerResource:GetSelectedHeroEntity( attacker:GetPlayerOwnerID() )
		if mainHero and mainHero ~= attacker then 
			mainHero.statsDamageDealt = (mainHero.statsDamageDealt or 0) + math.min(victim:GetHealth(), damage)
		end
	end
	if attacker:IsCreature() then
		victim.statsDamageTaken = (victim.statsDamageTaken or 0) + math.min(victim:GetHealth(), damage)
		return true 
	end
	if not victim:IsHero() and victim ~= attacker then
		if not ability or (ability and not ability:HasNoThreatFlag()) then
			-- if not victim.threatTable then victim.threatTable = {} end
			if not attacker.threat then attacker.threat = 0 end
			local roundCurrTotalHP = 0
			local enemies = FindAllUnits({team = DOTA_UNIT_TARGET_TEAM_ENEMY})
			for _,unit in ipairs( enemies ) do
				roundCurrTotalHP = roundCurrTotalHP + unit:GetMaxHealth()
			end
			local addedthreat = math.min( (damage / roundCurrTotalHP)*#enemies*100, (victim:GetHealth() * #enemies * 100) / roundCurrTotalHP )
			if addedthreat > 0.15 then
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

function CHoldoutGameMode:OnHeroLevelUp(event)
	local playerID = EntIndexToHScript(event.player):GetPlayerID()
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)
	if hero:GetLevel() <= 27 then
		hero.bonusSkillPoints = (hero.bonusSkillPoints or 0) + 1
		if hero:GetLevel() == 17 or hero:GetLevel() == 19 or (hero:GetLevel() > 20 and hero:GetLevel() < 25) then 
			hero:SetAbilityPoints( hero:GetAbilityPoints() + 1)
			hero.bonusSkillPoints = (hero.bonusSkillPoints or 0) + 1
		end
		if hero:GetLevel() % GameRules.gameDifficulty == 0 then
			hero:SetAttributePoints( hero:GetAttributePoints() + 1 )
			hero.bonusAbilityPoints = (hero.bonusAbilityPoints or 0) + 1
		end
	else
		hero:SetAttributePoints( hero:GetAttributePoints() + 1 )
		hero.bonusAbilityPoints = (hero.bonusAbilityPoints or 0) + 1
		if not ( hero:GetLevel() == 30
		or hero:GetLevel() == 31
		or hero:GetLevel() == 36
		or hero:GetLevel() == 40
		or hero:GetLevel() == 50
		or hero:GetLevel() == 60
		or hero:GetLevel() == 70
		or hero:GetLevel() == 80) then
			hero:SetAbilityPoints( hero:GetAbilityPoints() - 1)
		else
			hero.bonusSkillPoints = (hero.bonusSkillPoints or 0) + 1
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
	local hero = EntIndexToHScript( event.caster_entindex )
	
	if not hero then return end
	if not abilityname then return end
	AddFOWViewer(DOTA_TEAM_BADGUYS, hero:GetAbsOrigin(), 256, 3, false)
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
	hero.tellThreatDelayTimer = hero.tellThreatDelayTimer or 0
	if GameRules:GetGameTime() > hero.tellThreatDelayTimer + 1 then
		Say(player, message, true)
		hero.tellThreatDelayTimer = GameRules:GetGameTime()
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

function CHoldoutGameMode:OnPlayerUIInitialized(keys)
	local playerID = keys.PlayerID
	local player = PlayerResource:GetPlayer(playerID)
	Timers:CreateTimer(0.03, function()
		if PlayerResource:GetSelectedHeroEntity(playerID) then
			local hero = PlayerResource:GetSelectedHeroEntity(playerID)
			CustomGameEventManager:Send_ServerToPlayer(player,"dota_player_updated_relic_drops", {playerID = pID, drops = hero.relicsToSelect})
			if StatsScreen:IsPlayerRegistered(hero) and not hero:HasModifier("modifier_stats_system_handler") then hero:AddNewModifier(hero, nil, "modifier_stats_system_handler", {}) end
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
	for pID = 0, 24 do -- check if game has to die
		if PlayerResource:IsValidPlayerID( pID ) and PlayerResource:GetConnectionState() == DOTA_CONNECTION_STATE_CONNECTED then
			return
		end
	end
	RoundManager:GameIsFinished(false)
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
		Timers:CreateTimer(0.1,function()
			CustomGameEventManager:Send_ServerToAllClients( "updateQuestLife", { lives = GameRules._lives, maxLives = GameRules._maxLives } )
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
		RoundManager:StartGame()
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

function CHoldoutGameMode:CheckHP()
	local dontdelete = {["npc_dota_lone_druid_bear"] = true}
	for _,unit in ipairs ( FindAllEntitiesByClassname("npc_dota_creature")) do
		if unit:GetAbsOrigin().z < GetGroundHeight(unit:GetAbsOrigin(), unit) or unit:GetAbsOrigin().z > 1800 +  GetGroundHeight(unit:GetAbsOrigin(), unit) then
			local currOrigin = unit:GetAbsOrigin()
			FindClearSpaceForUnit(unit, GetGroundPosition(currOrigin, unit), true)
		end
		if ( unit:GetHealth() <= 0 and unit:IsAlive() ) or ( unit:GetHealth() > 0 and not unit:IsAlive() ) then
			if not unit:IsNull() then
				unit:SetBaseMaxHealth( 1 )
				unit:SetMaxHealth( 1 )
				unit:SetHealth( 1 )
				
				unit:ForceKill( false )
			end
		end
	end
	for _,unit in ipairs ( FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0), nil, -1, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false) ) do
		MapHandler:CheckAndResolvePositions(unit)
	end
	if not GameRules:IsGamePaused() then
		local playerData = {}
		for _, hero in ipairs ( HeroList:GetAllHeroes() ) do
			if not hero:IsFakeHero() then
				local data = CustomNetTables:GetTableValue("hero_properties", hero:GetUnitName()..hero:entindex() ) or {}
				if hero:GetMaxHealth() <= 0 then
					hero:SetMaxHealth(1)
					hero:SetHealth(1)
				end
				
				data.strength = hero:GetStrength()
				data.intellect = hero:GetIntellect()
				data.agility = hero:GetAgility()
				if hero:GetPlayerOwner() and hero:GetAttackTarget() then
					CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "bh_update_attack_target", {entindex = hero:GetAttackTarget():entindex()} )
				end
				CustomNetTables:SetTableValue("hero_properties", hero:GetUnitName()..hero:entindex(), data )
				playerData[hero:GetPlayerID()] = {DT = hero.statsDamageTaken or 0, DD = hero.statsDamageDealt or 0, DH = hero.statsDamageHealed or 0}
			end
		end
		CustomGameEventManager:Send_ServerToAllClients( "player_update_stats", playerData )
	end
end

function CHoldoutGameMode:OnThink()
	DAY_TIME = 1
	NIGHT_TIME = 0
	TEMPORARY_NIGHT = 2
	NIGHT_STALKER_NIGHT = 3
	local timeofday = 1
	if not GameRules:IsDaytime() then timeofday = NIGHT_TIME end
	if GameRules:IsTemporaryNight() then timeofday = TEMPORARY_NIGHT end
	if GameRules:IsNightstalkerNight() then timeofday = NIGHT_STALKER_NIGHT end
	CustomNetTables:SetTableValue( "game_info", "timeofday", {timeofday = timeofday} )
	if GameRules:State_Get() >= 7 and GameRules:State_Get() <= 8 then
		local OnPThink = function(self)
			status, err, ret = xpcall(self.CheckHP, debug.traceback, self)
			if not status  and not self.gameHasBeenBroken then
				SendErrorReport(err, self)
			end
			status, err, ret = xpcall(self.DegradeThreat, debug.traceback, self)
			if not status  and not self.gameHasBeenBroken then
				SendErrorReport(err, self)
			end
		end
		status, err, ret = xpcall(OnPThink, debug.traceback, self)
		if not status  and not self.gameHasBeenBroken then
			SendErrorReport(err, self)
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
			local spawnLoc = Vector(900,300)
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