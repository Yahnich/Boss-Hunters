customSchema = class({})

function customSchema:init()

    -- Check the schema_examples folder for different implementations

    -- Flag Example
    -- statCollection:setFlags({version = GetVersion()})

    -- Listen for changes in the current state
    ListenToGameEvent('game_rules_state_change', function(keys)
        local state = GameRules:State_Get()

        -- Send custom stats when the game ends
        if state == DOTA_GAMERULES_STATE_POST_GAME then

            -- Build game array
            local game = BuildGameArray()

            -- Build players array
            local players = BuildPlayersArray()

            -- Print the schema data to the console
            if statCollection.TESTING then
                PrintSchema(game,players)
            end

            -- Send custom stats
            if statCollection.HAS_SCHEMA then
                statCollection:sendCustom({game=game, players=players})
            end
        end
    end, nil)
end

-------------------------------------

-- In the statcollection/lib/utilities.lua, you'll find many useful functions to build your schema.
-- You are also encouraged to call your custom mod-specific functions

-- Returns a table with our custom game tracking.
function BuildGameArray()
    local game = {}

    table.insert(game, {
        G_T = math.floor(GameRules:GetGameTime()/60), --game time
        M_R = GameRules._roundnumber, -- max round achiece
        F_G = GameRules._finish,    --is the game had been finished (win)
        life = GameRules._live,     --how many life left
        U_L = GameRules._used_live,     -- Used Life
        T_L = GameRules._used_live+ GameRules._live     --Total Life
    })

    return game
end

-- Returns a table containing data for every player in the game
function BuildPlayersArray()
    local players = {}
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then

                local hero = PlayerResource:GetSelectedHeroEntity(playerID)

                if hero:GetTeamNumber()==DOTA_TEAM_GOODGUYS then
                    team = "Boss Slayer"
                else
                    team = "Boss Master"
                end

                table.insert(players, {
                    -- steamID32 required in here
                    steamID32 = PlayerResource:GetSteamAccountID(playerID),
                    HN = GetHeroName(playerID),                                             -- name
                    P_L = hero:GetLevel(),                                                   -- level
                    P_NW = GetNetworth(PlayerResource:GetSelectedHeroEntity(playerID)),      -- Networth
                    P_T = team,                                           -- Hero's team
                    P_K = hero:GetKills(),                                         -- Kills
                    P_D = hero:GetDeaths(),                                       -- Deaths
                    P_H = PlayerResource:GetHealing(hero:GetPlayerOwnerID()),       -- Healing
                    P_R = hero.Ressurect,                   --ammount of time he ressurect someone
                    P_GPM = math.floor(PlayerResource:GetGoldPerMin(hero:GetPlayerOwnerID())),        -- GPM
                    T_D = hero.damageDone,
                    --inventory :
                    i1 = GetItemSlot(hero,0),
                    i2 = GetItemSlot(hero,1),
                    i3 = GetItemSlot(hero,2),
                    i4 = GetItemSlot(hero,3),
                    i5 = GetItemSlot(hero,4),
                    i6 = GetItemSlot(hero,5)
                    -- Example functions for generic stats are defined in statcollection/lib/utilities.lua
                    -- Add player values here as someValue = GetSomePlayerValue(),

                })
            end
        end
    end

    return players
end

function GetItemSlot(hero,slot)
    local item = hero:GetItemInSlot(slot)
    
    if item then
        local itemName = string.gsub(item:GetAbilityName(),"item_","") or nil
    end
    
    return itemName
end


-- Prints the custom schema, required to get an schemaID
function PrintSchema( gameArray, playerArray )
    print("-------- GAME DATA --------")
    DeepPrintTable(gameArray)
    print("\n-------- PLAYER DATA --------")
    DeepPrintTable(playerArray)
    print("-------------------------------------")
end

-- Write 'test_schema' on the console to test your current functions instead of having to end the game
if Convars:GetBool('developer') then
    Convars:RegisterCommand("test_schema", function() PrintSchema(BuildGameArray(),BuildPlayersArray()) end, "Test the custom schema arrays", 0)
end

-------------------------------------

-- If your gamemode is round-based, you can use statCollection:submitRound(bLastRound) at any point of your main game logic code to send a round
-- If you intend to send rounds, make sure your settings.kv has the 'HAS_ROUNDS' set to true. Each round will send the game and player arrays defined earlier
-- The round number is incremented internally, lastRound can be marked to notify that the game ended properly
function customSchema:submitRound(isLastRound)

    local winners = BuildRoundWinnerArray()
    local game = BuildGameArray()
    local players = BuildPlayersArray()

    statCollection:sendCustom({game=game, players=players})

    isLastRound = isLastRound or false --If the function is passed with no parameter, default to false.
    return {winners = winners, lastRound = isLastRound}
end

-- A list of players marking who won this round
function BuildRoundWinnerArray()
    local winners = {}
    local current_winner_team = GameRules.Winner or 0 --You'll need to provide your own way of determining which team won the round
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then
                winners[PlayerResource:GetSteamAccountID(playerID)] = (PlayerResource:GetTeam(playerID) == current_winner_team) and 1 or 0
            end
        end
    end
    return winners
end

-------------------------------------