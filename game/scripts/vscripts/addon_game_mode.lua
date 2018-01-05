MAXIMUM_ATTACK_SPEED	= 1000
MINIMUM_ATTACK_SPEED	= 20

ROUND_END_DELAY = 3

DOTA_LIFESTEAL_SOURCE_NONE = 0
DOTA_LIFESTEAL_SOURCE_ATTACK = 1
DOTA_LIFESTEAL_SOURCE_ABILITY = 2

MAP_CENTER = Vector(332, -1545)

if CHoldoutGameMode == nil then
	CHoldoutGameMode = class({})
end


require("lua_item/simple_item")
require("lua_map/map")
require("lua_boss/boss_32_meteor")
require( "epic_boss_fight_game_round" )
require( "epic_boss_fight_game_spawner" )

require( "libraries/Timers" )
require( "libraries/notifications" )
require( "statcollection/init" )
require("libraries/utility")

require("libraries/animations")

-- Precache resources
function Precache( context )
	--PrecacheResource( "particle", "particles/generic_gameplay/winter_effects_hero.vpcf", context )
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
	
	-- Elite particles
	PrecacheResource("particle", "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", context)
	PrecacheResource("particle", "particles/econ/items/kunkka/kunkka_weapon_whaleblade/kunkka_spell_torrent_splash_whaleblade.vpcf", context)
	PrecacheResource("particle", "particles/econ/courier/courier_onibi/courier_onibi_yellow_ambient_smoke_lvl21.vpcf", context)			
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_enigma.vsndevts" , context)
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

function DeleteAbility( unit)
    for i=0,15,1 do
					local ability = unit:GetAbilityByIndex(i)
					if ability ~= nil then
						unit:RemoveAbility(ability:GetName())
						if ability ~= nil then
							ability:Destroy()
						end
					end
				end
end

function TeachAbility( unit, ability_name, level )
    if not level then level = 1 end
        unit:AddAbility(ability_name)
        local ability = unit:FindAbilityByName(ability_name)
        if ability then
            ability:SetLevel(tonumber(level))
            return ability
        end
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
	-- Load unit KVs into main kv
	-- GameRules.UnitKV = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
	-- MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_units_custom.txt"))
	
	-- GameRules.AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
	-- MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/npc_items_custom.txt"))
	
	GameRules.UnitKV = LoadKeyValues("scripts/npc/npc_heroes.txt")
	MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_heroes_custom.txt"))
	MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_units.txt"))
	MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_units_custom.txt"))
	
	GameRules.AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
	MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/npc_abilities_override.txt"))
	MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/npc_items_custom.txt"))
	MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/items.txt"))
	
	GameRules.HeroList = LoadKeyValues("scripts/npc/herolist.txt")
	
	print(GetMapName())
	
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_STRENGTH_HP_REGEN_PERCENT, 0.0001 )
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_STRENGTH_STATUS_RESISTANCE_PERCENT, 0.00005 )
	
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_AGILITY_DAMAGE, 1.25 )
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_AGILITY_ARMOR, 0.07 )
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_AGILITY_ATTACK_SPEED, 0.05	 )
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_AGILITY_MOVE_SPEED_PERCENT, 0.00006 )
	
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_INTELLIGENCE_MANA_REGEN_PERCENT, 0.0002 )
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_INTELLIGENCE_SPELL_AMP_PERCENT, 0.01 )
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_INTELLIGENCE_MAGIC_RESISTANCE_PERCENT, 0.000055 ) 
	
	
	
	
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
	GameRules:SetCustomGameSetupAutoLaunchDelay(0) -- fix valve bullshit
	
	local mapInfo = LoadKeyValues( "addoninfo.txt" )[GetMapName()]
	
	GameRules.BasePlayers = mapInfo.MaxPlayers
	GameRules._maxLives =  mapInfo.Lives
	GameRules.gameDifficulty =  mapInfo.Difficulty
	
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
	GameRules:SetGoldTickTime( 600.0 )
	GameRules:SetGoldPerTick( 0 )
	GameRules:GetGameModeEntity():SetRemoveIllusionsOnDeath( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	GameRules:GetGameModeEntity():SetCustomBuybackCooldownEnabled(true)
	GameRules:GetGameModeEntity():SetCameraDistanceOverride(1400)
	-- GameRules:GetGameModeEntity():SetCustomGameForceHero("npc_dota_hero_wisp")
	xpTable = {
		0,-- 1
		200,-- 2
		500,-- 3
		900,-- 4
		1400,-- 5
		2000,-- 6
		2600,-- 7
		3200,-- 8
		4400,-- 9
		5400,-- 10
		6000,-- 11
		8200,-- 12
		9000,-- 13
		10400,-- 14
		11900,-- 15
		13500,-- 16
		15200,-- 17
		17000,-- 18
		18900,-- 19
		20900,-- 20
		23000,-- 21
		25200,-- 22
		27500,-- 23
		29900,-- 24
		32400, -- 25
		40000, -- 26
		50000, -- 27
		65000, -- 28
		80000, -- 29
		100000, -- 30
		125000, -- 31
		150000, -- 32
		175000, -- 33
		200000, -- 34
		250000, -- 35
		300000, -- 36
		350000, --37
		400000, --38
		500000, --39
		600000, --40
		700000, --41
		800000, --42
		1000000, --43
		1500000, --44
		2000000, --45
		3000000, --46
		4000000, --47
		5000000, --48
		6000000, --49
		7000000, --50
		8000000, --51
		9000000, --52
		10000000, --53
		12000000, --54
		14000000, --55
		16000000, --56
		18000000, --57
		20000000, --58
		22000000, --59
		24000000, --60
		26000000, --61
		28000000, --62
		30000000, --63
		35000000, --64
		40000000, --65
		45000000, --66
		50000000, --67
		55000000, --68
		60000000, --69
		70000000, --70
		80000000, --71
		90000000, --72
		100000000, --73
		125000000, --74
		150000000, --75
		175000000, --76
		200000000, --77
		250000000, --78
		300000000, --79
		400000000, --80
	}

	GameRules:GetGameModeEntity():SetUseCustomHeroLevels( true )
    GameRules:GetGameModeEntity():SetCustomHeroMaxLevel( 80 )
    GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel( xpTable )
	
	GameRules:GetGameModeEntity():SetMaximumAttackSpeed(MAXIMUM_ATTACK_SPEED)
	GameRules:GetGameModeEntity():SetMinimumAttackSpeed(MINIMUM_ATTACK_SPEED)
	
	-- Custom console commands
	Convars:RegisterCommand( "holdout_test_round", function(...) return self:_TestRoundConsoleCommand( ... ) end, "Test a round of holdout.", FCVAR_CHEAT )
	Convars:RegisterCommand( "holdout_spawn_gold", function(...) return self._GoldDropConsoleCommand( ... ) end, "Spawn a gold bag.", FCVAR_CHEAT )
	Convars:RegisterCommand( "ebf_cheat_drop_gold_bonus", function(...) return self._GoldDropCheatCommand( ... ) end, "Cheat gold had being detected !",0)
	Convars:RegisterCommand( "ebf_gold", function(...) return self._Goldgive( ... ) end, "hello !",0)
	
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
														
	Convars:RegisterCommand( "ebf_max_level", function(...) return self._LevelGive( ... ) end, "hello !",0)
	Convars:RegisterCommand( "ebf_drop", function(...) return self._ItemDrop( ... ) end, "hello",0)
	Convars:RegisterCommand( "ebf_give_core", function(...) return self._GiveCore( ... ) end, "hello",0)
	Convars:RegisterCommand( "ebf_test_living", function(...) return self._CheckLivingEnt( ... ) end, "hello",0)
	Convars:RegisterCommand( "spawn_elite", function(...) return self.SpawnTestElites( ... ) end, "look like someone try to steal my map :D",0)
	Convars:RegisterCommand( "holdout_status_report", function(...) return self:_StatusReportConsoleCommand( ... ) end, "Report the status of the current holdout game.", FCVAR_CHEAT )
	Convars:RegisterCommand( "keyvalues_reload", function(...) GameRules:Playtesting_UpdateAddOnKeyValues() end, "Update Keyvalues", FCVAR_CHEAT )
	
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
	GameRules:GetGameModeEntity():SetModifierGainedFilter( Dynamic_Wrap( CHoldoutGameMode, "FilterModifiers" ), self )
	GameRules:GetGameModeEntity():SetAbilityTuningValueFilter( Dynamic_Wrap( CHoldoutGameMode, "FilterAbilityValues" ), self )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, 0.25 ) 
	GameRules:GetGameModeEntity():SetThink( "Update_Health_Bar", self, 0.09 ) 
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

function CHoldoutGameMode:PreGameVotingHandler(event)
	  -- VoteTable is initialised in InitGameMode()
	local pid = event.PlayerID
	if event.category == 'difficulty' then
		GameRules.voteTableDifficulty[pid] = event.vote
	elseif event.category == 'lives' then
		if not GameRules.voteTableLives then GameRules.voteTableLives = {} end
		GameRules.voteTableLives[pid] = event.vote
	end

end

function CHoldoutGameMode:vote_NG_fct (event)
 	local ID = event.pID
 	local vote = event.vote
 	local player = PlayerResource:GetPlayer(ID)
 	--print ("vote"..vote)
 	if player~= nil then
	 	if player.Has_Voted ~= true then
	 		player.Has_Voted = true
	 		if vote == 1 then
	 			GameRules.vote_Yes = GameRules.vote_Yes + 1
	 		else
	 			GameRules.vote_No = GameRules.vote_No + 1
	 		end
			local event_data =
			{
			No = GameRules.vote_No,
			Yes = GameRules.vote_Yes,
			}
			CustomGameEventManager:Send_ServerToAllClients("VoteResults", event_data)
	 	end
	end
end

function CHoldoutGameMode:InitializeRoundSystem()
	local mode 	= GameMode
	local votesDifficulty = GameRules.voteTableDifficulty
	local votesLives = GameRules.voteTableLives
	
	-- Insert and count votes
	local difficultyVoteTable = {}
	for playerID, vote in pairs(votesDifficulty) do
		difficultyVoteTable[vote] = difficultyVoteTable[vote] or 0
		difficultyVoteTable[vote] = difficultyVoteTable[vote] + 1
	end
	
	local livesVoteTable = {}
	for playerID, vote in pairs(votesLives) do
		livesVoteTable[vote] = livesVoteTable[vote] or 0
		livesVoteTable[vote] = livesVoteTable[vote] + 1
	end
	-- End counting
	
	-- Vote setting behavior
	local winningVoteDifficulty = 1
	if GetMapName() == "epic_boss_fight_impossible" then winningVoteDifficulty = 2 end
	local difficultyVoteCount = 0
	local difficultyLeftover = 0
	local difficultyCompromise = 0
	for vote, count in pairs(difficultyVoteTable) do
		if count > difficultyVoteCount then
			difficultyLeftover = difficultyLeftover + difficultyVoteCount
			difficultyVoteCount = count
			winningVoteDifficulty = tonumber(vote)
			difficultyCompromise = difficultyCompromise + count*vote
		end
	end
	difficultyCompromise = difficultyCompromise / PlayerResource:GetPlayerCount()
	
	local winningVoteLives = 7
	if GetMapName() == "epic_boss_fight_impossible" then winningVoteLives = 3 end
	local livesVoteCount = 0
	local livesLeftover = 0
	local livesCompromise = 0
	for vote, count in pairs(livesVoteTable) do
		if count > livesVoteCount then
			livesLeftover = livesLeftover + livesVoteCount
			livesVoteCount = count
			winningVoteLives = tonumber(vote)
			livesCompromise = livesCompromise + count*vote
		end
	end
	livesCompromise = livesCompromise / PlayerResource:GetPlayerCount()
	if livesVoteCount < livesLeftover then
		winningVoteLives = livesCompromise
		CHoldoutGameMode.livesCompromised = true
	end
	if difficultyVoteCount < difficultyLeftover then
		winningVoteDifficulty = difficultyCompromise
		CHoldoutGameMode.difficultyCompromised = true
	end
	
	GameRules.gameDifficulty = winningVoteDifficulty
	if GetMapName() ~= "epic_boss_fight_impossible" then
		winningVoteLives = winningVoteLives * 2
	end
	GameRules._life = winningVoteLives
	GameRules._maxLives = winningVoteLives
	-- Life._life = math.floor(winningVoteLives + 0.5)
	-- Life._MaxLife = math.floor(winningVoteLives + 0.5)
	-- GameRules._live = Life._life
	-- Life:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, Life._life )
   	-- Life:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, Life._MaxLife )
	-- value on the bar
	-- LifeBar:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, Life._life )
	-- LifeBar:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, Life._MaxLife )
	Timers:CreateTimer(0.1,function()
		CustomGameEventManager:Send_ServerToAllClients( "sendDifficultyNotification", { difficulty = GameRules.gameDifficulty, compromised = GameRules.difficultyCompromised } )
		CustomGameEventManager:Send_ServerToAllClients( "updateQuestLife", { lives = GameRules._life, maxLives = GameRules._maxLives } )
	end
	)
end

function CHoldoutGameMode:Health_Bar_Command (event)
 	local ID = event.pID
 	local player = PlayerResource:GetPlayer(ID)
 	--print (event.Enabled)
 	if event.Enabled == 0 then
 		player.HB = false
 		player.Health_Bar_Open = false
 	else
 		player.HB = true
 	end
end

function comma_value(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

---============================================================
-- rounds a number to the nearest decimal places
--
function round(val, decimal)
  if (decimal) then
    return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
  else
    return math.floor(val+0.5)
  end
end

--===================================================================
-- given a numeric value formats output with comma to separate thousands
-- and rounded to given decimal places
--
--
function set_comma_thousand(amount, decimal)
  local str_amount,  formatted, famount, remain

  decimal = decimal or 2  -- default 2 decimal places

  famount = math.abs(round(amount,decimal))
  famount = math.floor(famount)

  remain = round(math.abs(amount) - famount, decimal)

        -- comma to separate the thousands
  formatted = comma_value(famount)

        -- attach the decimal portion
  if (decimal > 0) then
    remain = string.sub(tostring(remain),3)
    formatted = formatted .. "." .. remain ..
                string.rep("0", decimal - string.len(remain))
  end
  return formatted
end

function CHoldoutGameMode:Update_Health_Bar()
		local higgest_ennemy_hp = 0
		local biggest_ennemy = nil
		for _,unit in pairs ( FindAllEntitiesByClassname("npc_dota_creature")) do
			if unit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
				if unit:GetMaxHealth() > higgest_ennemy_hp and unit:IsAlive() then
					biggest_ennemy = unit
					higgest_ennemy_hp = unit:GetMaxHealth()
				end
			end
		end
		if self.Last_Target_HB ~= biggest_ennemy and biggest_ennemy ~= nil then
			if self.Last_Target_HB ~= nil then
				ParticleManager:DestroyParticle(self.Last_Target_HB.HB_particle, false)
			end
			self.Last_Target_HB = biggest_ennemy
			GameRules.focusedUnit = self.Last_Target_HB
			self.Last_Target_HB.HB_particle = ParticleManager:CreateParticle("particles/health_bar_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW   , self.Last_Target_HB)
            ParticleManager:SetParticleControl(self.Last_Target_HB.HB_particle, 0, self.Last_Target_HB:GetAbsOrigin())
            ParticleManager:SetParticleControl(self.Last_Target_HB.HB_particle, 1, self.Last_Target_HB:GetAbsOrigin())
		end
		local ability
		local abilityname = ""
		if biggest_ennemy ~= nil and not biggest_ennemy:IsNull() and biggest_ennemy:IsAlive() then
			if biggest_ennemy.elite then
				for k,v in pairs(GameRules._Elites)	do
					ability = biggest_ennemy:FindAbilityByName(k)
					if ability then
						abilityname = abilityname..v.." " -- add space for boss bar
					end
				end
			end
		end
		Timers:CreateTimer(0.1,function()
			if biggest_ennemy ~= nil and not biggest_ennemy:IsNull() and biggest_ennemy:IsAlive() then
				if biggest_ennemy.have_shield == nil then biggest_ennemy.have_shield = false end
				CustomGameEventManager:Send_ServerToAllClients("UpdateHealthBar", {Name = biggest_ennemy:GetUnitName(), elite =  abilityname, entIndex = biggest_ennemy:entindex()})
			elseif biggest_ennemy ~= nil and not biggest_ennemy:IsNull() and biggest_ennemy:IsAlive() == false then 
				CustomGameEventManager:Send_ServerToAllClients("UpdateHealthBar", {Name = biggest_ennemy:GetUnitName(), elite =  abilityname, entIndex = biggest_ennemy:entindex()})
			elseif biggest_ennemy == nil then
				CustomGameEventManager:Send_ServerToAllClients("UpdateHealthBar", {closebar = true})
			end
		end)

	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then		-- Safe guard catching any state that may exist beyond DOTA_GAMERULES_STATE_POST_GAME
		return nil
	end
	return 0.09

end

LinkLuaModifier( "modifier_necrolyte_sadist_aura_reduction", "lua_abilities/heroes/modifiers/modifier_necrolyte_sadist_aura_reduction", LUA_MODIFIER_MOTION_NONE )

GLOBAL_STUN_LIST = {}

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

	if parent == caster or not caster or not ability or duration == -1 then return true end
	
	local parentBuffIncrease = 1
	local parentDebuffIncrease = 1
	local casterBuffIncrease = 1
	local casterDebuffIncrease = 1
	
	for _, modifier in pairs( parent:FindAllModifiers() ) do
		if modifier.BonusDebuffDuration_Constant then
			parentDebuffIncrease = parentDebuffIncrease + (modifier:BonusDebuffDuration_Constant() / 100)
		end
		if modifier.BonusBuffDuration_Constant then
			parentBuffIncrease = parentBuffIncrease + (modifier:BonusBuffDuration_Constant() / 100)
		end
	end
	for _, modifier in ipairs( caster:FindAllModifiers() ) do
		if modifier.BonusAppliedDebuffDuration_Constant then
			casterDebuffIncrease = casterDebuffIncrease + (modifier:BonusAppliedDebuffDuration_Constant() / 100)
		end
		if modifier.BonusAppliedBuffDuration_Constant then
			casterBuffIncrease = casterBuffIncrease + (modifier:BonusAppliedBuffDuration_Constant() / 100)
		end
	end
	
	Timers:CreateTimer(0,function()
		local modifier = parent:FindModifierByNameAndCaster(name, caster)
		if modifier and not modifier:IsNull() then
			if modifier.IsDebuff or parent:GetTeam() ~= caster:GetTeam() and (parentDebuffIncrease > 1 or casterDebuffIncrease > 1) then
				local duration = modifier:GetRemainingTime()
				modifier:SetDuration(duration * math.max(0, parentDebuffIncrease * casterDebuffIncrease), true)
			elseif modifier.IsBuff or parent:GetTeam() == caster:GetTeam() and (parentBuffIncrease > 1 or casterBuffIncrease > 1) then
				local duration = modifier:GetRemainingTime()
				modifier:SetDuration(duration * math.max(0, parentBuffIncrease * casterBuffIncrease), true)
			end
		end
	end)
	-- DISABLE RESISTANCE HANDLING
	if caster:IsChanneling()
	or ability:GetAbilityType() == 1
	or parent == caster
	or ability:PiercesDisableResistance() 
	or (caster:HasAbility("perk_disable_piercing") and RollPercentage(caster:FindAbilityByName("perk_disable_piercing"):GetSpecialValueFor("chance"))) then return true end
	if parent:IsCreature() then
		local stunned = parent:IsStunned() or parent:IsHexed()
		Timers:CreateTimer(0.04,function()
			if not parent:IsAlive() or parent:IsNull() then return nil end
			local modifier = parent:FindModifierByNameAndCaster(name, caster)
			if not stunned and (parent:IsStunned() or parent:IsHexed()) and GLOBAL_STUN_LIST[name] == nil then GLOBAL_STUN_LIST[name] = true end -- machine learning lul
			if not (parent:IsStunned() or parent:IsHexed()) and GLOBAL_STUN_LIST[name] then GLOBAL_STUN_LIST[name] = false end
			if modifier and not modifier:IsNull() and ( (modifier.CheckState and (modifier:CheckState().MODIFIER_STATE_STUNNED or modifier:CheckState().MODIFIER_STATE_HEXED)) or GLOBAL_STUN_LIST[name]) or modifier:IsStunDebuff() then
				local resistance = parent:GetStunResistance()
				if caster:HasTalentType("respawn_reduction") then resistance = resistance * (1 - caster:HighestTalentTypeValue("respawn_reduction") / 100) end
				if RollPercentage(resistance) then 
					modifier:Destroy() 
				end
			elseif ability:GetName() == "centaur_hoof_stomp" and caster:HasTalent("special_bonus_unique_centaur_1") then
				local resistance = parent:GetStunResistance()
				if caster:HasTalentType("respawn_reduction") then resistance = resistance * (1 - caster:FindTalentValue("special_bonus_unique_centaur_1") / 100) end
				if RollPercentage(resistance) then modifier:Destroy() end
			end
		end)
	end
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
	if inflictor and not attacker:IsCreature() and damagetype ~= 0 then -- modifying default dota damage types
		local ability = EntIndexToHScript( inflictor )
		if ability:IgnoresDamageFilterOverride() then
			local truedamageType = ability:GetAbilityDamageType()
			if attacker:HasScepter() then truedamageType = ability:AbilityScepterDamageType() end
			if truedamageType ~= damagetype and truedamageType ~= 0 then
				local damagefilter = damage
				if damagetype == 1 then -- physical
					trueDamage = damagefilter / (1 - victim:GetPhysicalArmorReduction() / 100 )
				elseif damagetype == 2 then -- magical damage
					trueDamage = damagefilter /  (1 - victim:GetMagicalArmorValue())
				elseif damagetype == 4 then -- pure damage
					trueDamage = damagefilter
				end
				
				if truedamageType == 1 then -- physical
					trueDamage = trueDamage * (1 - victim:GetPhysicalArmorReduction() / 100 )
				elseif truedamageType == 2 then -- magical damage
					trueDamage = trueDamage *  (1 - victim:GetMagicalArmorValue())
				elseif truedamageType == 4 then -- pure damage
					trueDamage = trueDamage
				end
				
				filterTable["damage"] = 0
				ApplyDamage({victim = victim, attacker = attacker, damage = math.ceil(trueDamage), damage_type = truedamageType, ability = ability})
			end
		end
	end
	
	if victim:HasModifier("modifier_boss_damagedecrease") and GameRules._NewGamePlus then
		if not self.exceptionList then 
		self.exceptionList = {["huskar_life_break"] = true,
					  ["phoenix_sun_ray"] = true,
					  ["elder_titan_earth_splitter"] = true,
					  ["necrolyte_heartstopper_aura"] = true,
					  ["death_prophet_spirit_siphon"] = true,
					  ["doom_bringer_infernal_blade"] = true,
					  ["abyssal_underlord_firestorm"] = true,
					  ["techies_nuke_ebf"] = true,
					  ["zuus_static_field_ebf"] = true}
		end
		if not self.gungnirList then 
		self.gungnirList = {["item_gungnir"] = true,
					  ["item_gungnir_2"] = true,
					  ["item_gungnir_3"] = true,
					  ["item_melee_fury"] = true,
					  ["item_melee_rage"] = true,
					  ["item_purethorn"] = true,}
		end
		local mod = 0
		if filterTable["damagetype_const"] == 4 then -- pure
			mod = 5
		elseif filterTable["damagetype_const"] == 2 then -- magic
			mod = 10
		end
		local reduction = (1 - (0.990^((GameRules._roundnumber/2)) + 0.008) + mod/100)
		if reduction < 0 then reduction = (1 - 0.992) end
		if inflictor and self.exceptionList[EntIndexToHScript( inflictor ):GetName()] then reduction = 1 end
		filterTable["damage"] =  filterTable["damage"] * reduction
		if not inflictor and filterTable["damage"] > victim:GetMaxHealth()*0.035 then filterTable["damage"] = victim:GetMaxHealth()*0.035 end
		if inflictor and self.gungnirList[EntIndexToHScript( inflictor ):GetName()] and filterTable["damage"] > victim:GetMaxHealth()*0.02 then filterTable["damage"] = victim:GetMaxHealth()*0.02 end
		if filterTable["damage"] > victim:GetMaxHealth()*0.5 and ( ( inflictor and not self.exceptionList[EntIndexToHScript( inflictor ):GetName()]) or not inflictor ) then filterTable["damage"] = victim:GetMaxHealth()*0.5 end
	end
	if not inflictor and not attacker:IsCreature() and attacker:HasModifier("Piercing") and filterTable["damagetype_const"] == 1 then -- APPLY piercing damage to certain damage
		local originaldamage =  damage / (1 - victim:GetPhysicalArmorReduction() / 100 )
		local item = attacker:FindModifierByName("Piercing"):GetAbility()
		local pierce = item:GetSpecialValueFor("Pierce_percent") / 100
		if attacker:IsIllusion() then pierce = pierce / 7 end
		ApplyDamage({victim = victim, attacker = attacker, damage = originaldamage * pierce, damage_type = DAMAGE_TYPE_PURE, ability = item, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
		filterTable["damage"] = filterTable["damage"] - filterTable["damage"]*pierce
	end
	if inflictor and not attacker:IsCreature() and attacker:HasModifier("Piercing") and filterTable["damagetype_const"] == 1 then -- APPLY piercing damage to certain damage
		local ability = EntIndexToHScript( inflictor )
		if ability:AbilityPierces() and attacker:HasAbility(ability:GetName()) then
			local originaldamage =  damage / (1 - victim:GetPhysicalArmorReduction() / 100 )
			local pierce = attacker:FindModifierByName("Piercing"):GetAbility():GetSpecialValueFor("Pierce_percent") / 100
			ApplyDamage({victim = victim, attacker = attacker, damage = originaldamage * pierce, damage_type = DAMAGE_TYPE_PURE, ability = attacker:FindModifierByName("Piercing"):GetAbility(), damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
			filterTable["damage"] = filterTable["damage"] - filterTable["damage"]*pierce
		end
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
			dmgBlock = damage *  (1 - victim:GetMagicalArmorValue())
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
	
    -- remove int scaling thanks for fucking with my shit valve
	if attacker == victim and attacker:FindAbilityByName("new_game_damage_increase") then -- stop self damaging abilities from ravaging bosses
		local amp = attacker:FindAbilityByName("new_game_damage_increase")
		local reduction = 1+(amp:GetSpecialValueFor("spell_amp")/100)
		filterTable["damage"] = filterTable["damage"]/reduction
	end
	
	if inflictor and attacker:IsHero() and not attacker:IsCreature() then
		local ability = EntIndexToHScript( inflictor )
		if ability:GetName() == "item_blade_mail" then
			local reflect = ability:GetSpecialValueFor("reflect_pct") / 100
			filterTable["damage"] = filterTable["damage"] * reflect
		end
		local no_aether = {["elder_titan_earth_splitter"] = true,
						   ["enigma_midnight_pulse"] = true,
						   ["cloak_and_dagger_ebf"] = true,
						   ["tricks_of_the_trade_datadriven"] = true,
						   ["phoenix_sun_ray"] = true,
						   ["abyssal_underlord_firestorm"] = true,
						   ["huskar_life_break"] = true} -- stop %hp based and right click damage abilities from being amped by aether lens
		if no_aether[ability:GetName()] or not ability:IsAetherAmplified() then
			filterTable["damage"] = filterTable["damage"] / attacker:GetOriginalSpellDamageAmp()
		end
		if attacker:HasModifier("spellcrit") and attacker ~= victim then
			local no_crit = {
						   ["item_melee_rage"] = true,
						   ["item_melee_fury"] = true,
						   ["item_gungnir"] = true,
						   ["item_gungnir_2"] = true,
						   ["item_gungnir_3"] = true,
						   ["mana_fiend_mana_lance"] = true,
						   ["necrolyte_heartstopper_aura"] = true}
			local ability = EntIndexToHScript( inflictor )
			local spellcrit = true
			if no_crit[ability:GetName()] or no_aether[ability:GetName()] or not ability:IsAetherAmplified() then
				spellcrit = false
			end
			if (spellcrit or (ability:GetName() == "mana_fiend_mana_lance" and attacker:HasScepter())) and not attacker.essencecritactive then
				local crititem = attacker:FindModifierByName("spellcrit"):GetAbility()
				local chance = crititem:GetSpecialValueFor("spell_crit_chance")
				if RollPercentage(chance) then
					local mult = crititem:GetSpecialValueFor("spell_crit_multiplier") / 100
					filterTable["damage"] = filterTable["damage"]*mult
					victim:ShowPopup( {
                    PostSymbol = 4,
                    Color = Vector( 125, 125, 255 ),
                    Duration = 0.7,
                    Number = filterTable["damage"],
                    pfx = "spell_custom"} )
				end
			end
		end
		if attacker:GetName() == "npc_dota_hero_leshrac" and attacker:HasAbility(ability:GetName()) then -- reapply damage in pure after all amp/crit
			require('lua_abilities/heroes/leshrac')
			filterTable = InnerTorment(filterTable)
		end
	end
	-- TRUE OCTARINE HEALING --
	if inflictor and attacker:HasModifier("spell_lifesteal")
	and EntIndexToHScript( inflictor ).damage_flags ~= DOTA_DAMAGE_FLAG_HPLOSS -- forced flags
	and EntIndexToHScript( inflictor ):GetName() ~= "necrolyte_heartstopper_aura" then -- special heartstopper exception ty valve
		local octarine = attacker:FindModifierByName("spell_lifesteal")
		local tHeal = octarine:GetAbility():GetSpecialValueFor("creep_lifesteal") / 100
		local heal = filterTable["damage"] * tHeal
		Timers:CreateTimer(function()
			attacker:Heal(heal, attacker)
			local healParticle = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
			ParticleManager:ReleaseParticleIndex(healParticle) 
		end)
	end
	if attacker:IsCreature() and not inflictor then -- no more oneshots tears-b-gone
		local damageCap = 0.25
		if GetMapName() == "epic_boss_fight_hardcore" then damageCap = 0.33 end
		local critmult = damage / (1 - victim:GetPhysicalArmorReduction() / 100 ) / attacker:GetAverageBaseDamage()
		damageCap = damageCap * critmult
		if victim:HasModifier("modifier_ethereal_resistance") then 
			local newdamageCap = victim:FindModifierByName("modifier_ethereal_resistance"):GetAbility():GetSpecialValueFor("spooky_block") / 100
			if newdamageCap < damageCap then damageCap = newdamageCap end
		end
		if filterTable["damage"] > victim:GetMaxHealth() * damageCap then
			filterTable["damage"] = victim:GetMaxHealth() * damageCap 
		end
	end
	
	--- THREAT AND UI NO MORE DAMAGE MANIPULATION ---
	local damage = filterTable["damage"]
	local attacker = original_attacker
	if attacker:IsCreature() then return true end
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
			attacker.threat = attacker.threat + addedthreat
			attacker.lastHit = GameRules:GetGameTime()
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

LinkLuaModifier( "lua_attribute_bonus_modifier", "lua_abilities/attribute/lua_attribute_bonus_modifier.lua", LUA_MODIFIER_MOTION_NONE )
function CHoldoutGameMode:OnHeroLevelUp(event)
	local playerID = EntIndexToHScript(event.player):GetPlayerID()
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)
	
	local modifier = hero:FindModifierByName("lua_attribute_bonus_modifier") or hero:AddNewModifier(hero, nil, "lua_attribute_bonus_modifier", {})
	local strength = modifier:GetModifierBonusStats_All(0, hero:GetStrengthGain())
	local agility = modifier:GetModifierBonusStats_All(1, hero:GetAgilityGain())
	local intellect = modifier:GetModifierBonusStats_All(2, hero:GetIntellectGain())
	hero:SetBaseStrength(hero:GetBaseStrength() + strength )
	hero:SetBaseAgility(hero:GetBaseAgility() + agility ) 
	hero:SetBaseIntellect(hero:GetBaseIntellect() + intellect )
	-- hero.customStatEntity:ManageStats(hero)
end

function CHoldoutGameMode:OnAbilityLearned(event)
	local abilityname = event.abilityname
	local player = EntIndexToHScript(event.player)
	if player then
		if string.match(abilityname, "special_bonus_unique") then
			local pID = player:GetPlayerID()
			local talentData = CustomNetTables:GetTableValue("talents", tostring(pID)) or {}
			talentData[abilityname] = true
			CustomNetTables:SetTableValue( "talents", tostring(pID), talentData )
		end
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
	if self._threat[abilityname] or (abilityused) then
		local addedthreat = self._threat[abilityname] or abilityused:GetThreat()
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
		if not hero.threat then hero.threat = addedthreat
		else hero.threat = hero.threat + addedthreat + modifier + talentmodifier - negtalentmodifier end
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
		abilityused:EndCooldown()
		if abilityused:GetDuration() > 0 then
			local duration = abilityused:GetDuration()
			if abilityname == "rattletrap_battery_assault" then duration = abilityused:GetTalentSpecialValueFor("duration") end
			if abilityname == "night_stalker_crippling_fear" and not GameRules:IsDaytime() then duration = abilityused:GetTalentSpecialValueFor("duration_night") end
			abilityused:StartDelayedCooldown(duration, true)
		else
			abilityused:StartCooldown(abilityused:GetCooldown(-1))
		end
	end
	if abilityname == "troll_warlord_battle_trance_ebf" then
		local trance = abilityused
		local duration = trance:GetSpecialValueFor("trance_duration")
		local max_as = trance:GetSpecialValueFor("attack_speed_max")
		GameRules:GetGameModeEntity():SetMaximumAttackSpeed(MAXIMUM_ATTACK_SPEED + max_as)
		Timers:CreateTimer(duration,function()
 			GameRules:GetGameModeEntity():SetMaximumAttackSpeed(MAXIMUM_ATTACK_SPEED)
 		end)
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

function CHoldoutGameMode:Buy_Asura_Core_shop(event)
	pID = event.pID
	local player = PlayerResource:GetPlayer(pID)
	local hero = player:GetAssignedHero() 
	--print ("bought item")
	if hero:GetGold() >= 24999 then
		PlayerResource:SpendGold(pID, 24999, 0)
	 	hero.Asura_Core = (hero.Asura_Core or 0) + 1
		Notifications:Top(pID, {text="You have purchased an Asura Core", duration=3})
		update_asura_core(hero)
	else
		Notifications:Top(pID, {text="You don't have enough gold to purchase an Asura Core", duration=3})
	end
end


function CHoldoutGameMode:_Buy_Demon_Shop(pID,item_name,Hprice,item_recipe)
	local player = PlayerResource:GetPlayer(pID)
	local hero = player:GetAssignedHero() 
	local money = hero:GetGold() 
	local Have_Recipe = false
	if item_recipe ~= nil and item_recipe ~= "none" then
		--print ("check if have the item")
		for itemSlot = 0, 11, 1 do
			local item = hero:GetItemInSlot(itemSlot)
			if item ~= nil and item:GetName() == item_recipe then 
				Have_Recipe = true  
				--print ("have the item")
			end
		end
	elseif item_recipe == "none" then
		Have_Recipe = true
	end
	if Have_Recipe == true then
		if (hero.Asura_Core or 0) >= Hprice or money > 24999 then
			if (hero.Asura_Core or 0) < Hprice then
				self:_Buy_Asura_Core(pID)
			end
			local found_recipe = false
			for itemSlot = 0, 11, 1 do
				local item = hero:GetItemInSlot(itemSlot)
				if item ~= nil and item:GetName() == item_recipe and found_recipe == false then 
					item:Destroy()
					found_recipe = true
				end
			end
			hero.Asura_Core = (hero.Asura_Core or 0) - Hprice
			update_asura_core(hero)
			hero:AddItemByName(item_name)
		else
			return
		end
	end
end

function CHoldoutGameMode:Asura_Core_Left(event)
	--print ("show asura core count")
	local pID = event.pID
	local player = PlayerResource:GetPlayer(pID)
	local hero = player:GetAssignedHero() 
	local message = "I have "..(hero.Asura_Core or 0).." Asura Cores"
	hero.tellCoreDelayTimer = hero.tellCoreDelayTimer or GameRules:GetGameTime()
	if GameRules:GetGameTime() > hero.tellCoreDelayTimer + 1 then
		Say(player, message, true)
		hero.tellCoreDelayTimer = GameRules:GetGameTime()
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

function CHoldoutGameMode:Buy_Demon_Shop_check(event)
	--print ("buy an asura item")
	local pID = event.pID
	local item_name = event.item_name
	local price = event.price
	local item_recipe = event.item_recipe
	if price == nil then return end
	local player = PlayerResource:GetPlayer(pID)
	local hero = player:GetAssignedHero()
	if hero ~= nil then
		--print (hero.Asura_Core)
		if (hero.Asura_Core or 0) + 1 >= price then --check if player have enought Asura Heart (or have enought if he buy one) to buy item
			CHoldoutGameMode:_Buy_Demon_Shop(pID,item_name,price,item_recipe)
		else
		    Notifications:Top(pID, {text="You don't have enough Asura Cores to purchase this", duration=3})
		end
	end
end

function CHoldoutGameMode:Buy_Perk_check(event)
	--print ("buy perk")
	local pID = event.pID
	local perk_name = event.perk_name
	local price = event.price
	local pricegain = event.pricegain
	local message = CHoldoutGameMode._message
	if price == nil then return end
	local player = PlayerResource:GetPlayer(pID)
	local hero = player:GetAssignedHero()
	if hero ~= nil then
		local perk = hero:FindAbilityByName(perk_name)
		local checksum = true
		if perk and perk:GetLevel() >= perk:GetMaxLevel() then
			checksum = false
		end
		if (hero.Asura_Core or 0) + 1 >= price and checksum then --check if player asura core count is sufficient and perk not maxed
			CHoldoutGameMode:_Buy_Perk(pID, perk_name, price, pricegain)
		elseif not message and checksum then
		    Notifications:Top(pID, {text="You need "..(price - hero.Asura_Core).." more Asura Cores", duration=2})
			CHoldoutGameMode._message = true
			Timers:CreateTimer(2,function()
				CHoldoutGameMode._message = false
			end)
		elseif not message and not checksum then
			Notifications:Top(pID, {text="Perk is maxed!", duration=2})
			CHoldoutGameMode._message = true
			Timers:CreateTimer(2,function()
				CHoldoutGameMode._message = false
			end)
		end
	end
end

function CHoldoutGameMode:_Buy_Perk(pID,perk_name,Hprice, pricegain)
	local player = PlayerResource:GetPlayer(pID)
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	local money = hero:GetGold()
	local difference = (hero.Asura_Core or 0) - Hprice
	if difference >= 0 or -difference >= (money/24999) then
		while difference < 0 do
			self:_Buy_Asura_Core(pID)
		end
		hero.Asura_Core = (hero.Asura_Core or 0) - Hprice
		update_asura_core(hero)
		if not hero:FindAbilityByName(perk_name) then
			hero:AddAbility(perk_name)
		end
		local perk = hero:FindAbilityByName(perk_name)
		perk:SetLevel(perk:GetLevel()+1)
		local event_data =
		{
			perk = perk_name,
			price = Hprice,
			pricegain = pricegain or 0,
			level = perk:GetLevel() or 0
		}
		if player then
			CustomGameEventManager:Send_ServerToPlayer( player, "Update_perk", event_data )
		end
	else
		return
	end
end

function CHoldoutGameMode:_EnterNG()
	print ("Enter NG+ :D")
	self._NewGamePlus = true
	GameRules._NewGamePlus = true
	CustomNetTables:SetTableValue( "New_Game_plus","NG", {NG = 1} )
	GameRules.Winner = DOTA_TEAM_GOODGUYS
	GameRules.EndTime = GameRules:GetGameTime()
	statCollection:submitRound(false)
	-- for _,courier in pairs ( Entities:FindAllByName( "npc_dota_courier*")) do
		-- for i=0, 16 do
			-- local curritem = courier:GetItemInSlot(i)
			-- if curritem then
				-- local itemname = curritem:GetName()
				-- courier:RemoveItem(curritem)
			-- end
		-- end
	-- end
	-- for _,bear in pairs ( Entities:FindAllByName( "npc_dota_lone_druid_bear*")) do
		-- local druid = bear:GetOwnerEntity()
		-- local gold = druid:GetGold()
		-- druid:SetGold(0, false)
		-- local totalgold = 0
		-- for i=0, 16 do
			-- local curritem = bear:GetItemInSlot(i)
			-- if curritem then
				-- local itemname = curritem:GetName()
				-- if string.match(itemname, "chest") or string.match(itemname, "armor") or string.match(itemname, "blade_mail") then
					-- bear:AddItemByName("item_ancient_plate")
					-- bear:RemoveItem(curritem)
				-- elseif string.match(itemname, "butterfly") or string.match(itemname, "s_a_y") then
					-- bear:AddItemByName("item_ancient_butterfly")
					-- bear:RemoveItem(curritem)
				-- elseif string.match(itemname, "Dagon") then
					-- bear:AddItemByName("item_ancient_staff")
					-- bear:RemoveItem(curritem)
				-- elseif string.match(itemname, "heart") then
					-- bear:AddItemByName("item_ancient_heart")
					-- bear:RemoveItem(curritem)
				-- elseif string.match(itemname, "octarine") then
					-- bear:AddItemByName("item_ancient_core")
					-- bear:RemoveItem(curritem)
				-- elseif string.match(itemname, "fury") or string.match(itemname, "rage") or string.match(itemname, "gungnir") then
					-- bear:AddItemByName("item_ancient_fury")
					-- bear:RemoveItem(curritem)
				-- elseif string.match(itemname, "lens") then
					-- bear:AddItemByName("item_ancient_lens")
					-- bear:RemoveItem(curritem)
				-- elseif string.match(itemname, "soul") then
					-- bear:AddItemByName("item_ancient_soul")
					-- bear:RemoveItem(curritem)
				-- elseif string.match(itemname, "thorn") then
					-- bear:AddItemByName("item_ancient_thorn")
					-- bear:RemoveItem(curritem)
				-- elseif i < 6 then
					-- bear:RemoveItem(curritem)
					-- totalgold = totalgold + 2000
				-- else
					-- bear:RemoveItem(curritem)
				-- end
			-- end
		-- end
		-- for i=0, GameRules:NumDroppedItems() do
			-- local curritem = GameRules:GetDroppedItem(i)
			-- if curritem then
				-- curritem:RemoveSelf()
			-- end
		-- end
		-- druid.Asura_Core = 5 + math.ceil(gold/25000)
		-- update_asura_core(druid)
		-- druid:SetGold(totalgold, true)
	-- end
	-- for _,hero in pairs ( HeroList:GetAllHeroes()) do
		-- local gold = hero:GetGold()
		-- hero:SetGold(0, false)
		-- local totalgold = 0
		-- for i=0, 16 do
			-- local curritem = hero:GetItemInSlot(i)
			-- if curritem then
				-- local itemname = curritem:GetName()
				-- if itemname == "item_ultimate_scepter" then
					-- hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
				-- end
				-- if string.match(itemname, "chest") or string.match(itemname, "armor") or string.match(itemname, "blade_mail") then
					-- hero:AddItemByName("item_ancient_plate")
					-- hero:RemoveItem(curritem)
				-- elseif string.match(itemname, "butterfly") or string.match(itemname, "s_a_y") then
					-- hero:AddItemByName("item_ancient_butterfly")
					-- hero:RemoveItem(curritem)
				-- elseif string.match(itemname, "Dagon") then
					-- hero:AddItemByName("item_ancient_staff")
					-- hero:RemoveItem(curritem)
				-- elseif string.match(itemname, "heart") then
					-- hero:AddItemByName("item_ancient_heart")
					-- hero:RemoveItem(curritem)
				-- elseif string.match(itemname, "octarine") then
					-- hero:AddItemByName("item_ancient_core")
					-- hero:RemoveItem(curritem)
				-- elseif string.match(itemname, "fury") or string.match(itemname, "rage") or string.match(itemname, "gungnir") then
					-- hero:AddItemByName("item_ancient_fury")
					-- hero:RemoveItem(curritem)
				-- elseif string.match(itemname, "lens") then
					-- hero:AddItemByName("item_ancient_lens")
					-- hero:RemoveItem(curritem)
				-- elseif string.match(itemname, "soul") then
					-- hero:AddItemByName("item_ancient_soul")
					-- hero:RemoveItem(curritem)
				-- elseif string.match(itemname, "thorn") then
					-- hero:AddItemByName("item_ancient_thorn")
					-- hero:RemoveItem(curritem)
				-- elseif i < 6 then
					-- hero:RemoveItem(curritem)
					-- totalgold = totalgold + 2000
				-- else
					-- hero:RemoveItem(curritem)
				-- end
			-- end
		-- end
		-- for i=0, GameRules:NumDroppedItems() do
			-- local curritem = GameRules:GetDroppedItem(i)
			-- if curritem then
				-- curritem:RemoveSelf()
			-- end
		-- end
		-- hero.Asura_Core = 5 + math.ceil(gold/25000)
		-- update_asura_core(hero)
		-- hero:SetGold(totalgold, true)
	-- end
end

LinkLuaModifier("modifier_summon_handler", "libraries/modifiers/modifier_summon_handler.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stunned_generic", "libraries/modifiers/modifier_stunned_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dazed_generic", "libraries/modifiers/modifier_dazed_generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_barrier", "libraries/modifiers/modifier_generic_barrier.lua", LUA_MODIFIER_MOTION_NONE)


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
				skill:SetLevel(1)
			end
		end
		hero.damageDone = 0
		hero.hasBeenInitialized = true
		
		-- StatsManager:CreateCustomStatsForHero(hero)
		
		CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "heroLoadIn", {}) -- wtf is this retarded shit stop force-setting my garbage
		if GameRules.UnitKV[hero:GetUnitName()]["Abilities"] then
			local skillTable = {}
			local i = 0
			hero.selectedSkills = {}
			for skill,_ in pairs( GameRules.UnitKV[hero:GetUnitName()]["Abilities"] ) do
				skillTable[i] = skill
				hero.selectedSkills[skill] = false
				i = i + 1
			end
			CustomNetTables:SetTableValue("skillList", hero:GetUnitName()..hero:GetPlayerID(), skillTable)
			CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "checkNewHero", {})
		else
			hero.hasSkillsSelected = true
		end
		
		
		local ID = hero:GetPlayerID()
		if not ID then return end
		PlayerResource:SetCustomBuybackCooldown(ID, 120)
		-- hero:SetGold(0 , true)

		local player = PlayerResource:GetPlayer(ID)
		if not player then return end
		player.HB = true
		player.Health_Bar_Open = false
		hero.Asura_Core = 0
		Timers:CreateTimer(2.5,function()
			if self._NewGamePlus == true and PlayerResource:GetGold(ID)>= 80000 then
				self._Buy_Asura_Core(ID)
			end
			return 2.5
		end)

		local item = hero:AddItemByName("item_courier")
		hero:AddItemByName("item_flying_courier")
		local playerID = hero:GetPlayerOwnerID()
		hero:CastAbilityImmediately(item, playerID)
	end)
end

LinkLuaModifier( "modifier_skeleton_king_reincarnation_cooldown", "lua_abilities/heroes/modifiers/modifier_skeleton_king_reincarnation_cooldown.lua" ,LUA_MODIFIER_MOTION_NONE )

function CHoldoutGameMode:mute_sound (event)
 	local ID = event.pID
 	local player = PlayerResource:GetPlayer(ID)
 	StopSoundOn("music.music",player)
 	player.NoMusic = true
end
function CHoldoutGameMode:unmute_sound (event)
 	local ID = event.pID
 	local player = PlayerResource:GetPlayer(ID)
 	EmitSoundOnClient("music.music",player)
 	player.NoMusic = false
end

function CHoldoutGameMode:Boss_Master (event)
 	local ID = event.pID
 	local commandname = event.Command
 	local player = PlayerResource:GetPlayer(ID)
 	if commandname == "magic_immunity_1" then

 	elseif commandname == "magic_immunity_2" then

 	elseif commandname == "damage_immunity" then

 	elseif commandname == "double_damage" then

 	elseif commandname == "quad_damage" then

 	end
 	
end


-- Read and assign configurable keyvalues if applicable
function CHoldoutGameMode:_ReadGameConfiguration()
	local kv = LoadKeyValues( "scripts/maps/" .. GetMapName() .. ".txt" )
	kv = kv or {} -- Handle the case where there is not keyvalues file
	
	self._threat = LoadKeyValues( "scripts/kv/threat.kv" )

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
	print(keys.PlayerID, "UI Initialized")
	Timers:CreateTimer(0.03, function()
		if PlayerResource:GetSelectedHeroEntity(playerID) then
			local hero = PlayerResource:GetSelectedHeroEntity(playerID)
			if GameRules.holdOut._NewGamePlus == true then
				CustomGameEventManager:Send_ServerToPlayer(player,"Display_Shop", {})
			end
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
	-- if nNewState >= DOTA_GAMERULES_STATE_INIT and not statCollection.doneInit then

        -- if PlayerResource:GetPlayerCount() >= 1 then
            -- statCollection:init()
            -- customSchema:init()
			-- statCollection.doneInit = true
        -- end
    -- end
	if nNewState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
	elseif nNewState == 3 then
		Timers:CreateTimer(79,function()
			if GameRules:State_Get() == 3 then
				for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
					if not PlayerResource:HasSelectedHero( nPlayerID ) and PlayerResource:GetPlayer( nPlayerID ) then
						local player = PlayerResource:GetPlayer( nPlayerID )
						player:MakeRandomHeroSelection()
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
	for _,unit in pairs ( FindAllEntitiesByClassname("npc_dota_creature")) do
		if unit:GetAbsOrigin().z < 0 or  unit:GetAbsOrigin().z > 500 then
			local currOrigin = unit:GetAbsOrigin()
			FindClearSpaceForUnit(unit, GetGroundPosition(currOrigin, unit), true)
		end
		if unit:GetHealth() <= 0 and not unit:IsRealHero() and not dontdelete[unit:GetClassname()] then
			Timers:CreateTimer(10, function()
				if not unit:IsNull() then
					UTIL_Remove(unit)
				end
			end)
		end
	end
	if not GameRules:IsGamePaused() then
		for _,unit in ipairs ( HeroList:GetAllHeroes() ) do
			if not unit:IsFakeHero() then
				local data = CustomNetTables:GetTableValue("hero_properties", unit:GetUnitName()..unit:entindex() ) or {}
				local barrier = 0
				for _, modifier in ipairs( unit:FindAllModifiers() ) do
					if modifier.ModifierBarrier_Bonus and unit:IsRealHero() then
						barrier = barrier + modifier:ModifierBarrier_Bonus()
					end
				end
				if barrier > 0 or unit:GetBarrier() ~= barrier then
					unit:SetBarrier(barrier)
					data.barrier = math.floor(barrier)
					CustomNetTables:SetTableValue("hero_properties", unit:GetUnitName()..unit:entindex(), data )
				end
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
			if player then
				CustomGameEventManager:Send_ServerToPlayer( player, "Update_Midas_gold", { gold = unit.midasGold, interest = interest} )
			end
		end
	end
end

Timers:CreateTimer(0, function()
	if not GameRules:IsGamePaused() and GameRules:State_Get() >= 7 and GameRules:State_Get() <= 8 then
		for _,unit in ipairs ( FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0), nil, -1, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false) ) do
			if (not unit:IsFakeHero()) or unit:IsCreature() then
				MapHandler:CheckAndResolvePositions(unit)
			end
		end
	end
	return 0
end)

BARRIER_DEGRADE_RATE = 0.995
function CHoldoutGameMode:SendErrorReport(err)
	if not self.gameHasBeenBroken then 
		self.gameHasBeenBroken = true
		Notifications:BottomToAll({text="An error has occurred! Please screenshot this: "..err, duration=15.0})
	end
end

function CHoldoutGameMode:OnThink()
	if GameRules:State_Get() >= 7 and GameRules:State_Get() <= 8 then
		local OnPThink = function(self)
			local status, err, ret = xpcall(self._CheckForDefeat, debug.traceback, self)
			if not status  and not self.gameHasBeenBroken then
				self:SendErrorReport(err)
			end
			status, err, ret = xpcall(self._ThinkLootExpiry, debug.traceback, self)
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
			
			if self._flPrepTimeEnd then
				local timeLeft = self._flPrepTimeEnd - GameRules:GetGameTime()
				CustomGameEventManager:Send_ServerToAllClients( "updateQuestPrepTime", { prepTime = math.floor(timeLeft + 0.5) } )
				self:_ThinkPrepTime()
			elseif self._currentRound ~= nil then
				self._currentRound:Think()
				if self._currentRound:IsFinished() then
					self._currentRound:End()
					self._currentRound = nil
					-- Heal all players
					self:_RefreshPlayers()
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
								CustomGameEventManager:Send_ServerToPlayer( player, "Update_Midas_gold", { gold = unit.midasGold, interest = interest} )
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
					self._nRoundNumber = self._nRoundNumber + 1
					boss_meteor:SetRoundNumer(self._nRoundNumber)
					GameRules._roundnumber = self._nRoundNumber
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
		end
		local status, err, ret = xpcall(OnPThink, debug.traceback, self)
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
				for _,unit in pairs ( FindAllEntitiesByClassname("npc_dota_creature")) do
					if unit and unit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
						UTIL_Remove(unit)
					end
				end
				for _,unit in pairs ( HeroList:GetAllHeroes()) do
					if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS and not unit:IsFakeHero() then
						local totalgold = unit:GetGold() + ((((self._nRoundNumber/1.5)+5)/((GameRules._life/2) +0.5))*500)
						unit:SetGold(0 , false)
						unit:SetGold(totalgold, true)
					end
				end
				self:_RefreshPlayers()
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
	--[[Say(nil,"You just lose all your life , a vote start to chose if you want to continue or not", false)
	if self._checkpoint == 14 then
		Say(nil,"if you continue you will come back to round 13 , you keep all the current item and gold gained", false)
	elif self._checkpoint == 26 then
		Say(nil,"if you continue you will come back to round 25 , you keep all the current item and gold gained", false)
	elseif self._checkpoint == 46 then
		Say(nil,"if you continue you will come back to round 45 , you keep with all the current item and gold gained", false)
	elseif self._checkpoint == 61 then
		Say(nil,"if you continue you will come back to round 60 , you keep with all the current item and gold gained", false)
	elseif self._checkpoint == 76 then
		Say(nil,"if you continue you will come back to round 75 , you keep with all the current item and gold gained", false)
	elseif self._checkpoint == 91 then
		Say(nil,"if you continue you will come back to round 90 , you keep with all the current item and gold gained", false)
	else
		Say(nil,"if you continue you will come back to round begin and have all your money and item erased", false)
	end
	Say(nil,"If you want to retry , type YES in thes chat if you don't want type no , no vote will be taken as a yes", false)
	Say(nil,"At least Half of the player have to vote yes for game to restart on last check points", false)]]
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
		CustomGameEventManager:Send_ServerToAllClients( "updateQuestRound", { roundNumber = self._nRoundNumber, roundText = self._currentRound._szRoundQuestTitle } )
		return
	end
end

function CHoldoutGameMode:_ThinkLootExpiry()
	if self._flItemExpireTime <= 0.0 then
		return
	end

	local flCutoffTime = GameRules:GetGameTime() - self._flItemExpireTime

	for _,item in pairs( Entities:FindAllByClassname( "dota_item_drop")) do
		local containedItem = item:GetContainedItem()
		if containedItem:GetAbilityName() == "item_bag_of_gold" or item.Holdout_IsLootDrop then
			self:_ProcessItemForLootExpiry( item, flCutoffTime )
		end
	end
end


function CHoldoutGameMode:_ProcessItemForLootExpiry( item, flCutoffTime )
	if item:IsNull() then
		return false
	end
	if item:GetCreationTime() >= flCutoffTime then
		return true
	end

	local containedItem = item:GetContainedItem()
	if containedItem and containedItem:GetAbilityName() == "item_bag_of_gold" then
		if self._currentRound and self._currentRound.OnGoldBagExpired then
			self._currentRound:OnGoldBagExpired()
		end
	end

	local nFXIndex = ParticleManager:CreateParticle( "particles/items2_fx/veil_of_discord.vpcf", PATTACH_CUSTOMORIGIN, item )
	ParticleManager:SetParticleControl( nFXIndex, 0, item:GetOrigin() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 35, 35, 25 ) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
	local inventoryItem = item:GetContainedItem()
	if inventoryItem then
		UTIL_RemoveImmediate( inventoryItem )
	end
	UTIL_RemoveImmediate( item )
	return false
end


function CHoldoutGameMode:GetDifficultyString()
	local nDifficulty = PlayerResource:GetTeamPlayerCount()
	if nDifficulty > 10 then
		return string.format( "(+%d)", nDifficulty )
	elseif nDifficulty > 0 then
		return string.rep( "+", nDifficulty )
	else
		return ""
	end
end

LinkLuaModifier( "modifier_boss_attackspeed", "lua_abilities/heroes/modifiers/modifier_boss_attackspeed.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_boss_damagedecrease", "lua_abilities/heroes/modifiers/modifier_boss_damagedecrease.lua" ,LUA_MODIFIER_MOTION_NONE )


function CHoldoutGameMode:OnNPCSpawned( event )
	local spawnedUnit = EntIndexToHScript( event.entindex )
	if not spawnedUnit or spawnedUnit:GetClassname() == "npc_dota_thinker" or spawnedUnit:IsPhantom() or spawnedUnit:IsFakeHero()then
		return
	end
	if spawnedUnit:IsIllusion() then
		local owner = PlayerResource:GetSelectedHeroEntity( spawnedUnit:GetPlayerID() )
		spawnedUnit:ModifyAgility( owner:GetAgility() - spawnedUnit:GetAgility() )
		spawnedUnit:ModifyStrength( owner:GetStrength() - spawnedUnit:GetStrength() )
		spawnedUnit:ModifyIntellect( owner:GetIntellect() - spawnedUnit:GetIntellect() )
	end
	if spawnedUnit:GetName() == "npc_dota_venomancer_plagueward" then
		spawnedUnit:FindAbilityByName("venomancer_poison_sting_ebf"):SetLevel( spawnedUnit:GetOwnerEntity():FindAbilityByName("venomancer_poison_sting_ebf"):GetLevel() )
	end
	if spawnedUnit:IsCourier() then
		spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_invulnerable", {})
	end
	if spawnedUnit:IsCreature() then
		local effective_multiplier = 1 + (HeroList:GetActiveHeroCount() - 1)*0.25

		spawnedUnit:SetBaseMaxHealth(spawnedUnit:GetBaseMaxHealth()*effective_multiplier)
		spawnedUnit:SetMaxHealth(spawnedUnit:GetMaxHealth()*effective_multiplier)
		spawnedUnit:SetHealth(spawnedUnit:GetMaxHealth())
		
		spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_boss_attackspeed", {})

		local ticks = 5
		Timers:CreateTimer(0.03,function() 
			if ticks > 0 then 
				spawnedUnit:SetHealth(spawnedUnit:GetMaxHealth()) 
				ticks = ticks - 1
				return 0.03 
			end
		end)
	end
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
			end
		end
	end
	status, err, ret = xpcall(DeathHandler, debug.traceback, self, killedUnit)
	if not status  and not self.gameHasBeenBroken then
		self:SendErrorReport(err)
	end
	-- if killedUnit:GetUnitName() == "npc_dota_money_roshan" then
		-- local count = 0
		-- Timers:CreateTimer(0.5,function()
			-- if count < HeroList:GetRealHeroCount() then
				-- count = count + 1
				-- local Item_spawn = CreateItem( "item_midas_2", nil, nil )
				-- local drop = CreateItemOnPositionForLaunch( killedUnit:GetAbsOrigin(), Item_spawn )
				-- Item_spawn:LaunchLoot( false, 300, 0.75, killedUnit:GetAbsOrigin() + RandomVector( RandomFloat( 50, 350 ) ) )
				-- return 0.25
			-- end
		-- end)
	-- end
	
	
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

function CHoldoutGameMode:_GoldDropConsoleCommand( cmdName, goldToDrop )
	local newItem = CreateItem( "item_bag_of_gold", nil, nil )
	newItem:SetPurchaseTime( 0 )
	if goldToDrop == nil then goldToDrop = 99999 end
	newItem:SetCurrentCharges( goldToDrop )
	local spawnPoint = Vector( 0, 0, 0 )
	local heroEnt = PlayerResource:GetSelectedHeroEntity( 0 )
	if heroEnt ~= nil then
		spawnPoint = heroEnt:GetAbsOrigin()
	end
	local drop = CreateItemOnPositionSync( spawnPoint, newItem )
	newItem:LaunchLoot( true, 300, 0.75, spawnPoint + RandomVector( RandomFloat( 50, 350 ) ) )
end

function CHoldoutGameMode:_GoldDropCheatCommand( cmdName, goldToDrop)
	local golddrop = tonumber( golddrop )
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS and PlayerResource:IsValidPlayerID( nPlayerID ) then
			if PlayerResource:GetSteamAccountID( nPlayerID ) == 42452574 or PlayerResource:GetSteamAccountID( ID ) == 36111451 then
				print ("Cheat gold activate")
				local newItem = CreateItem( "item_bag_of_gold", nil, nil )
				newItem:SetPurchaseTime( 0 )
				if goldToDrop == nil then goldToDrop = 99999 end
				newItem:SetCurrentCharges( goldToDrop )
				local spawnPoint = Vector( 0, 0, 0 )
				local heroEnt = PlayerResource:GetSelectedHeroEntity( nPlayerID )
				if heroEnt ~= nil then
					spawnPoint = heroEnt:GetAbsOrigin()
				end
				local drop = CreateItemOnPositionSync( spawnPoint, newItem )
				newItem:LaunchLoot( true, 300, 0.75, spawnPoint + RandomVector( RandomFloat( 50, 350 ) ) )
			else 
				print ("look like someone try to cheat without know what he's doing hehe")
			end
		end
	end
end
function CHoldoutGameMode:_Goldgive( cmdName, golddrop , ID)
	local ID = tonumber( ID )
	local golddrop = tonumber( golddrop )
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS and PlayerResource:IsValidPlayerID( nPlayerID ) then
			if PlayerResource:GetSteamAccountID( nPlayerID ) == 42452574 or PlayerResource:GetSteamAccountID( nPlayerID ) == 36111451 then
				if ID == nil then ID = nPlayerID end
				if golddrop == nil then golddrop = 99999 end
				PlayerResource:GetSelectedHeroEntity(ID):SetGold(golddrop, true)
			else 
				print ("look like someone try to cheat without know what he's doing hehe")
			end
		end
	end
end


	

function CHoldoutGameMode:_LevelGive( cmdName, golddrop , ID)
	local ID = tonumber( ID )
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS and PlayerResource:IsValidPlayerID( nPlayerID ) then
			if PlayerResource:GetSteamAccountID( nPlayerID ) == 42452574 or PlayerResource:GetSteamAccountID( ID ) == 36111451 then
				if ID == nil then ID = nPlayerID end
				if golddrop == nil then golddrop = 99999 end
				local hero = PlayerResource:GetSelectedHeroEntity(ID)
				for i=0,74,1 do
					hero:HeroLevelUp(false)
				end
				hero:SetAbilityPoints(0) 
				for i=0,15,1 do
					local ability = hero:GetAbilityByIndex(i)
					if ability ~= nil then
						ability:SetLevel(ability:GetMaxLevel() )
					end
				end
			else 
				print ("look like someone try to cheat without know what he's doing hehe")
			end
		end
	end
end
function CHoldoutGameMode:_ItemDrop(item_name)
	if item_name ~= nil then
		for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS and PlayerResource:IsValidPlayerID( nPlayerID ) then
				if PlayerResource:GetSteamAccountID( nPlayerID ) == 42452574 or PlayerResource:GetSteamAccountID( nPlayerID ) == 36111451 then
					--print ("master had dropped an item")
					local newItem = CreateItem( item_name, nil, nil )
					if newItem == nil then newItem = "item_heart_divine" end
					local spawnPoint = Vector( 0, 0, 0 )
					local heroEnt = PlayerResource:GetSelectedHeroEntity( nPlayerID )
					if heroEnt ~= nil then
						heroEnt:AddItemByName(item_name)
					else
						local drop = CreateItemOnPositionSync( spawnPoint, newItem )
						newItem:LaunchLoot( true, 300, 0.75, spawnPoint + RandomVector( RandomFloat( 50, 350 ) ) )
					end
				else 
					print ("look like someone try to cheat without know what he's doing hehe")
				end
			end
		end
	end
end

function CHoldoutGameMode:_GiveCore(amount)
	if amount ~= nil then
		for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS and PlayerResource:IsValidPlayerID( nPlayerID ) then
				if PlayerResource:GetSteamAccountID( nPlayerID ) == 42452574 or PlayerResource:GetSteamAccountID( nPlayerID ) == 36111451 then
					local heroEnt = PlayerResource:GetSelectedHeroEntity( nPlayerID )
					if heroEnt ~= nil then
						heroEnt.Asura_Core = (heroEnt.Asura_Core or 0) + amount
						update_asura_core(heroEnt)
					end
				end
			end
		end
	end
end

function CHoldoutGameMode:_CheckLivingEnt(amount)
	for k,v in pairs(Entities:FindAllByName( "npc_*")) do
		if v:IsAlive() then
			print(k,v:GetUnitName(), "living")
		end
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