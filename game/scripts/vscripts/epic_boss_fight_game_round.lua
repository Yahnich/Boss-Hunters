--[[
	CHoldoutGameRound - A single round of Holdout
]]

if CHoldoutGameRound == nil then
	CHoldoutGameRound = class({})
end
require( "libraries/Timers" )
require("internal/util")


function CHoldoutGameRound:ReadConfiguration( kv, gameMode, roundNumber )
	self._gameMode = gameMode
	self._nRoundNumber = roundNumber
	self._szRoundQuestTitle = kv.round_quest_title or "#DOTA_Quest_Holdout_Round"
	self._szRoundTitle = kv.round_title or string.format( "Round%d", roundNumber )

	self._nMaxGold = tonumber( kv.MaxGold or 0 )
	self._nBagCount = tonumber( kv.BagCount or 0 )
	self._nBagVariance = tonumber( kv.BagVariance or 0 )
	self._nFixedXP = tonumber( kv.FixedXP or 0 )

	self._vSpawners = {}
	for k, v in pairs( kv ) do
		if type( v ) == "table" and v.NPCName then
			local spawner = CHoldoutGameSpawner()
			spawner:ReadConfiguration( k, v, self )
			self._vSpawners[ k ] = spawner
		end
	end

	for _, spawner in pairs( self._vSpawners ) do
		spawner:PostLoad( self._vSpawners )
	end
end


function CHoldoutGameRound:Precache()
	for _, spawner in pairs( self._vSpawners ) do
		spawner:Precache()
	end
end

--[[function CHoldoutGameRound:spawn_treasure()
	local Item_spawn = CreateItem( "item_present_treasure", nil, nil )
	Timers:CreateTimer(0.03,function()
		local max_player = DOTA_MAX_TEAM_PLAYERS
		WID = math.RandomInt(0,max_player)
		if PlayerResource:GetConnectionState(WID) == 2 then
			local player = PlayerResource:GetPlayer(WID)
			local hero = player:GetAssignedHero() 
			hero:AddItem(Item_spawn)
		else
			return 0.03
		end
	end)
end]]

function GetAllPlayers()
	local counter = 0
	local abandon = 0
	local currtime = GameRules:GetGameTime()
	
	local base = GameRules.BasePlayers
	
	local challengemult = base or 7

	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			if PlayerResource:HasSelectedHero( nPlayerID ) then
				local hero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
				counter = counter + 1
				if hero then
					if not hero.disconnect then hero.disconnect = 0 end
					challengemult = challengemult - 1
					if PlayerResource:GetConnectionState(nPlayerID) == 3 then
						abandon = abandon + 0.3
						if hero.disconnect + 300 < GameRules:GetGameTime() then
							abandon = abandon + 0.7
						elseif hero:HasOwnerAbandoned() then
							abandon = abandon + 0.7
							challengemult = challengemult - 1
						end
					elseif hero:HasOwnerAbandoned() then
							abandon = abandon + 1
							challengemult = challengemult - 1
					end
				end
			else
				abandon = abandon + 1
				challengemult = challengemult - 1
			end
		end
	end
	challengemult = (challengemult/base)/3
	if counter - 1 <= abandon then abandon = counter - 1 end
	abandon = abandon / 3
	counter = (counter*(counter/(counter-abandon)))*(1 + challengemult)
	print(counter, "counter")
	return counter
end

function CHoldoutGameRound:Begin()
	
	self._vEnemiesRemaining = {}
	self._vEventHandles = {
		ListenToGameEvent( "npc_spawned", Dynamic_Wrap( CHoldoutGameRound, "OnNPCSpawned" ), self ),
		ListenToGameEvent( "entity_killed", Dynamic_Wrap( CHoldoutGameRound, "OnEntityKilled" ), self ),
		ListenToGameEvent( "dota_holdout_revive_complete", Dynamic_Wrap( CHoldoutGameRound, 'OnHoldoutReviveComplete' ), self )
	}
	self._nAsuraCoreRemaining = 0
	local PlayerNumber = GetAllPlayers() or HeroList:GetHeroCount()
	print(PlayerNumber, "playernumber")
	local GoldMultiplier = (((PlayerNumber)+0.56)/1.8)*0.15

	local roundNumber = self._nRoundNumber
	self._nGoldRemainingInRound = self._nMaxGold * GoldMultiplier * 1.1

	self._nGoldBagsRemaining = self._nBagCount
	self._nGoldBagsExpired = 0
	self._nCoreUnitsTotal = 0
	if GameRules._NewGamePlus == true then
		self._nFixedXP = 350000 + (self._nFixedXP * (10 * roundNumber^0.4))
	end
	self._nExpRemainingInRound = self._nFixedXP
	for _, spawner in pairs( self._vSpawners ) do
		spawner:Begin()
		self._nCoreUnitsTotal = self._nCoreUnitsTotal + spawner:GetTotalUnitsToSpawn()
		if self._nRoundNumber == 29 then
			self._nCoreUnitsTotal = self._nCoreUnitsTotal + 1
		end
	end
	self._nElitesToSpawn = 0
	self._EliteAbilities = {}
	local elitemod = 0
	if GetMapName() == "epic_boss_fight_hard" then
		elitemod = 1
	elseif GetMapName() == "epic_boss_fight_impossible" then
		elitemod = 2
	end
	elitemod = elitemod * GameRules.gameDifficulty
	for i=1, self._nCoreUnitsTotal do
		if RollPercentage(7+elitemod) and self._nRoundNumber > 1 then
			self._nElitesToSpawn = self._nElitesToSpawn + 1
			local elitegold = 100 * self._nRoundNumber^0.2 * PlayerNumber / 4
			if GameRules._NewGamePlus == true then
				elitegold = 110 * self._nRoundNumber^0.3 * PlayerNumber / 4
			end
			self._nGoldRemainingInRound = self._nGoldRemainingInRound + self._nRoundNumber * elitegold
		end
	end
	if GameRules._NewGamePlus == true then
		self._nGoldRemainingInRound = self._nGoldRemainingInRound * (1.3*roundNumber^0.4)
		if self._nGoldRemainingInRound > 50000 or self._nRoundNumber == 1 then
			while self._nGoldRemainingInRound > 25000 do
				self._nGoldRemainingInRound = self._nGoldRemainingInRound - 25000
				self._nAsuraCoreRemaining = self._nAsuraCoreRemaining + 1 
			end
			self._nAsuraCoreRemaining = math.ceil(self._nAsuraCoreRemaining/PlayerNumber)
			if self._nAsuraCoreRemaining == 0 and roundNumber > 2 then
				self._nAsuraCoreRemaining = self._nAsuraCoreRemaining + 1
			end
		end
	end
	self._nElitesRemaining = self._nElitesToSpawn
	self._nCoreUnitsSpawned = self._nCoreUnitsTotal
	self._nCoreUnitsKilled = 0
	-- CustomGameEventManager:Send_ServerToAllClients( "sendDifficultyNotification", { difficulty = GameRules.gameDifficulty, compromised = GameRules.difficultyCompromised } )
end

function CHoldoutGameRound:OnHoldoutReviveComplete( event )
	local castingHero = EntIndexToHScript( event.caster )
	
	if castingHero then
		castingHero.Ressurect = castingHero.Ressurect + 1
		local ngmodifier = 0
		if GameRules._NewGamePlus == true then ngmodifier = 37 end
		local totalgold = castingHero:GetGold() + (self._nRoundNumber+ngmodifier)*5
	            castingHero:SetGold(0 , false)
	            castingHero:SetGold(totalgold, true)
	end
end

function OnPlayerDisconnected(keys)
end

function CHoldoutGameRound:End()
	for _, eID in pairs( self._vEventHandles ) do
		StopListeningToGameEvent( eID )
	end
	self._vEventHandles = {}

	for _,unit in pairs( FindUnitsInRadius( DOTA_TEAM_BADGUYS, Vector( 0, 0, 0 ), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )) do
		if not unit:IsTower() or unit:IsHero() == false then
			UTIL_Remove( unit )
		end
	end

	for _,spawner in pairs( self._vSpawners ) do
		spawner:End()
	end
	self._vEnemiesRemaining = {}

	if self._entQuest then
		UTIL_Remove( self._entQuest )
		self._entQuest = nil
		self._entKillCountSubquest = nil
	end
end


function CHoldoutGameRound:Think()
	for _, spawner in pairs( self._vSpawners ) do
		spawner:Think()
	end
end


function CHoldoutGameRound:ChooseRandomSpawnInfo()
	return self._gameMode:ChooseRandomSpawnInfo()
end


function CHoldoutGameRound:IsFinished()
	for _, spawner in pairs( self._vSpawners ) do
		if not spawner:IsFinishedSpawning() then
			return false
		end
	end
	local nEnemiesRemaining = #self._vEnemiesRemaining
	if nEnemiesRemaining == 0 or self._vEnemiesRemaining == {} then
		return true
	end

	if not self._lastEnemiesRemaining == nEnemiesRemaining then
		self._lastEnemiesRemaining = nEnemiesRemaining
		print ( string.format( "%d enemies remaining in the round...", #self._vEnemiesRemaining ) )
	end
	return false
end


-- Rather than use the xp granting from the units keyvalues file,
-- we let the round determine the xp per unit to grant as a flat value.
-- This is done to make tuning of rounds easier.

function CHoldoutGameRound:OnNPCSpawned( event )
	local spawnedUnit = EntIndexToHScript( event.entindex )
	if not spawnedUnit or spawnedUnit:IsPhantom() or spawnedUnit:GetClassname() == "npc_dota_thinker" or 
	spawnedUnit:GetUnitName() == "" or 
	spawnedUnit:IsIllusion() or 
	spawnedUnit:GetUnitName() == "npc_dummy_unit" or 
	spawnedUnit:GetUnitName() == "npc_dummy_blank" then
		return
	end
	local nCoreUnitsRemaining = self._nCoreUnitsTotal - self._nCoreUnitsKilled
	Timers:CreateTimer(0.1,function()
				if spawnedUnit.Holdout_IsCore or spawnedUnit:GetUnitName() == "npc_dota_boss36_guardian" then
					self._nCoreUnitsSpawned = self._nCoreUnitsSpawned - 1
				end
				if ((self._nElitesRemaining > 0 and (spawnedUnit.Holdout_IsCore or spawnedUnit:GetUnitName() == "npc_dota_boss36_guardian")) or spawnedUnit.elite == true) then
					local elitemod = 1 + (GameRules.gameDifficulty - 1)* 0.15
					local elitelist = {} -- change table with names to array type
					local notcore = {  ["elite_disarming"] = true,
									   ["elite_piercing"] = true,
									   ["elite_sweeping"] = true,
									   ["elite_berserker"] = true,
									   ["elite_entangling"] = true,
									   ["elite_assassin"] = true,
									   ["elite_plagued"] = true,
									   ["elite_farseer"] = true,
									   ["elite_accurate"] = true,
									   ["elite_blinking"] = true,
									   ["elite_frenzied"] = true,
									   ["elite_parrying"] = true,
									   ["elite_blocking"] = true}
					for k,v in pairs(GameRules._Elites) do
						if not notcore[k] and spawnedUnit:GetUnitName() == "npc_dota_boss36" then
							table.insert(elitelist, k)
						elseif not (self._EliteAbilities["elite_disarming"] and k == "elite_silencing") and spawnedUnit:GetUnitName() ~= "npc_dota_boss36" then
							table.insert(elitelist, k)
						elseif not (self._EliteAbilities["elite_silencing"] and k == "elite_disarming") and spawnedUnit:GetUnitName() ~= "npc_dota_boss36" then
							table.insert(elitelist, k)
						end
					end
					local eliteabstogive = 1
					if GameRules._NewGamePlus == true or GameRules.gameDifficulty == 4 then
						eliteabstogive = 2
					end
					local eliteAbName = elitelist[math.random(#elitelist)]
					if spawnedUnit.elite and spawnedUnit.eliteAb then -- if elite spawned through other ways
						if spawnedUnit:GetMaxHealth() < self._nRoundNumber * 2000 then
							spawnedUnit:SetMaxHealth(spawnedUnit:GetMaxHealth()+self._nRoundNumber * 2000)
						end
						spawnedUnit:SetMaxHealth(spawnedUnit:GetMaxHealth()*(2 - 0.90 * self._nRoundNumber/38)*elitemod )
						spawnedUnit:SetHealth(spawnedUnit:GetMaxHealth())
						spawnedUnit:SetModelScale(spawnedUnit:GetModelScale()*1.5)
						while eliteabstogive > 0 do
							eliteAbName = spawnedUnit.eliteAb[eliteabstogive]
							local eliteAb = spawnedUnit:AddAbility(eliteAbName)
							eliteAb:SetLevel(eliteAb:GetMaxLevel())
							eliteAbType = eliteAbType.." "..GameRules._Elites[eliteAbName]
							table.removekey(elitelist,eliteAbName)
							if eliteAbName == "elite_disarming" or eliteAbName == "elite_silencing" then
								table.removekey(elitelist,"elite_disarming")
								table.removekey(elitelist,"elite_silencing")
							else
								table.removekey(elitelist,eliteAbName)
							end
							eliteAbName = elitelist[math.random(#elitelist)]
							eliteabstogive = eliteabstogive - 1
						end
						local messageinfo = {
						message = "An elite boss has spawned with the "..eliteAbType.." ability!",
						duration = 5
						}
						FireGameEvent("show_center_message",messageinfo)
					elseif self._nCoreUnitsSpawned > self._nElitesRemaining then
						if math.random(100) < 25 then
							if spawnedUnit:GetMaxHealth() < self._nRoundNumber * 2500 and spawnedUnit:GetName() ~= "npc_dota_money" and spawnedUnit:GetUnitName() ~= "npc_dota_boss36" then
								spawnedUnit:SetMaxHealth(spawnedUnit:GetMaxHealth()+self._nRoundNumber * 2500)
							end
							spawnedUnit:SetMaxHealth(spawnedUnit:GetMaxHealth()*(2 - 0.90 * self._nRoundNumber/38)*elitemod )
							spawnedUnit:SetHealth(spawnedUnit:GetMaxHealth())
							spawnedUnit:SetModelScale(spawnedUnit:GetModelScale()*1.5)
							spawnedUnit.elite = true
							local eliteAbType = ""
							while eliteabstogive > 0 do
								local eliteAb = spawnedUnit:AddAbility(eliteAbName)
								eliteAb:SetLevel(eliteAb:GetMaxLevel())
								eliteAbType = eliteAbType.." "..GameRules._Elites[eliteAbName]
								if eliteAbName == "elite_disarming" or eliteAbName == "elite_silencing" then
									table.removekey(elitelist,"elite_disarming")
									table.removekey(elitelist,"elite_silencing")
								else
									table.removekey(elitelist,eliteAbName)
								end
								self._EliteAbilities[eliteAbName] = true
								eliteAbName = elitelist[math.random(#elitelist)]
								eliteabstogive = eliteabstogive - 1
							end
							self._nElitesRemaining = self._nElitesRemaining - 1					
							local messageinfo = {
							message = "An elite boss has spawned with the "..eliteAbType.." ability!",
							duration = 5
							}
							FireGameEvent("show_center_message",messageinfo)
						end
					else
						if spawnedUnit:GetMaxHealth() < self._nRoundNumber * 2500 and spawnedUnit:GetName() ~= "npc_dota_money" and spawnedUnit:GetUnitName() ~= "npc_dota_boss36" then
							spawnedUnit:SetMaxHealth(spawnedUnit:GetMaxHealth()+self._nRoundNumber * 2500)
						end
						spawnedUnit:SetMaxHealth(spawnedUnit:GetMaxHealth()*(2 - 0.90 * self._nRoundNumber/38) )
						spawnedUnit:SetHealth(spawnedUnit:GetMaxHealth())
						spawnedUnit:SetModelScale(spawnedUnit:GetModelScale()*1.5)
						spawnedUnit.elite = true
						local eliteAbType = ""
						while eliteabstogive > 0 do
							local eliteAb = spawnedUnit:AddAbility(eliteAbName)
							eliteAb:SetLevel(eliteAb:GetMaxLevel())
							eliteAbType = eliteAbType.." "..GameRules._Elites[eliteAbName]
							self._EliteAbilities[eliteAbName] = true
							if eliteAbName == "elite_disarming" or eliteAbName == "elite_silencing" then
								table.removekey(elitelist,"elite_disarming")
								table.removekey(elitelist,"elite_silencing")
							else
								table.removekey(elitelist,eliteAbName)
							end
							eliteAbName = elitelist[math.random(#elitelist)]
							eliteabstogive = eliteabstogive - 1
						end
						self._nElitesRemaining = self._nElitesRemaining - 1
						local messageinfo = {
						message = "An elite boss has spawned with "..eliteAbType.." ability!",
						duration = 5
						}
						FireGameEvent("show_center_message",messageinfo)
					end
				end
	        end)

	if spawnedUnit:GetTeamNumber() == DOTA_TEAM_BADGUYS and spawnedUnit:IsCreature() then
		table.insert( self._vEnemiesRemaining, spawnedUnit )
		if self._nAsuraCoreRemaining>0 then
			if nCoreUnitsRemaining > 1 then
				spawnedUnit.Asura_To_Give = 1
				self._nAsuraCoreRemaining = self._nAsuraCoreRemaining - 1
			elseif nCoreUnitsRemaining <= 1 then
				spawnedUnit.Asura_To_Give = self._nAsuraCoreRemaining
				self._nAsuraCoreRemaining = 0
			end
		end
		local ability = spawnedUnit:FindAbilityByName("true_sight_boss")
		if ability == nil then
			if GetMapName() == "epic_boss_fight_impossible" or GameRules.gameDifficulty > 2 then spawnedUnit:AddAbility('true_sight_boss') end
		end
		spawnedUnit:SetDeathXP( 0 )
		spawnedUnit.unitName = spawnedUnit:GetUnitName()

	end
end


function CHoldoutGameRound:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	if not killedUnit then
		return
	end
	
	if killedUnit:GetUnitName() == "npc_dota_boss38" then
		for _,unit in pairs( FindUnitsInRadius( DOTA_TEAM_BADGUYS, Vector( 0, 0, 0 ), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )) do
			if not unit:IsTower() or unit:IsHero() == false then
				UTIL_Remove( unit )
			end
		end
		self._vEnemiesRemaining = {}
	end
	
	for i, unit in pairs( self._vEnemiesRemaining ) do
		if killedUnit == unit then
			table.remove( self._vEnemiesRemaining, i )
			break
		end
	end	
	for k,v in pairs(self._vEnemiesRemaining) do
		if not v:IsNull() then
			if v:GetUnitName() == "npc_dummy_blank" then
				table.remove( self._vEnemiesRemaining, k )
			end
		else
			table.remove( self._vEnemiesRemaining, k )
		end
	end
	if killedUnit.Holdout_IsCore then
		self._nCoreUnitsKilled = self._nCoreUnitsKilled + 1
		self:_CheckForGoldBagDrop( killedUnit )
		local nCoreUnitsRemaining = self._nCoreUnitsTotal - self._nCoreUnitsKilled
		if nCoreUnitsRemaining == 0 then
			--self:spawn_treasure()
		end
	end
end



function CHoldoutGameRound:_CheckForGoldBagDrop( killedUnit )
	if self._nGoldRemainingInRound <= 0 then
		return
	end

	local nGoldToDrop = 0
	local nCoreUnitsRemaining = self._nCoreUnitsTotal - self._nCoreUnitsKilled
	local PlayerNumber = HeroList:GetHeroCount()
	local exptogain = 0
	if nCoreUnitsRemaining > 0 then
		exptogain = ( (self._nFixedXP) / (self._nCoreUnitsTotal) )
	elseif nCoreUnitsRemaining <= 1 then
		exptogain = self._nExpRemainingInRound
	end
	for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
		if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
			unit:AddExperience (exptogain,false,false)
		end
	end
	if killedUnit:GetUnitName() == "npc_dota_money" and self._nExpRemainingInRound == 0 then
		for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
			while unit:GetLevel() < 7 do
				unit:AddExperience (100,false,false)
			end
		end
	end
	if nCoreUnitsRemaining <= 1 then
		nGoldToDrop = self._nGoldRemainingInRound
	else
		local flCurrentDropChance = self._nGoldBagsRemaining / (1 + nCoreUnitsRemaining)
		if RandomFloat( 0, 1 ) <= flCurrentDropChance then
			if self._nGoldBagsRemaining <= 1 then
				nGoldToDrop = self._nGoldRemainingInRound
			else
				nGoldToDrop = math.floor( self._nGoldRemainingInRound / self._nGoldBagsRemaining )
				nCurrentGoldDrop = math.max(1, RandomInt( nGoldToDrop - self._nBagVariance, nGoldToDrop + self._nBagVariance  ) )
			end
		end
	end
	
	nGoldToDrop = math.min( nGoldToDrop, self._nGoldRemainingInRound )
	if nGoldToDrop <= 0 then
		return
	end
	self._nGoldRemainingInRound = math.max( 0, self._nGoldRemainingInRound - nGoldToDrop )
	self._nGoldBagsRemaining = math.max( 0, self._nGoldBagsRemaining - 1 )
	self._nExpRemainingInRound = math.max( 0,self._nExpRemainingInRound - exptogain)

	for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
		if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS and not unit:IsIllusion() and not (unit:HasModifier("modifier_monkey_king_fur_army_soldier") or unit:HasModifier("modifier_monkey_king_fur_army_soldier_hidden")) then
			local totalgold = unit:GetGold() + nGoldToDrop / HeroList:GetRealHeroCount()
			unit:SetGold(0 , false)
			unit:SetGold(totalgold, true)
		end
	end
end


function CHoldoutGameRound:StatusReport( )
	print( string.format( "Enemies remaining: %d", #self._vEnemiesRemaining ) )
	for _,e in pairs( self._vEnemiesRemaining ) do
		if e:IsNull() then
			print( string.format( "<Unit %s Deleted from C++>", e.unitName ) )
		else
			print( e:GetUnitName() )
		end
	end
	print( string.format( "Spawners: %d", #self._vSpawners ) )
	for _,s in pairs( self._vSpawners ) do
		s:StatusReport()
	end
end