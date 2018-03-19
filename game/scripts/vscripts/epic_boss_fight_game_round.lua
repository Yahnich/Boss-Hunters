--[[
	CHoldoutGameRound - A single round of Holdout
]]

if CHoldoutGameRound == nil then
	CHoldoutGameRound = class({})
end
require( "libraries/Timers" )

function CHoldoutGameRound:ReadConfiguration( kv, gameMode, roundNumber )
	self._gameMode = gameMode
	self._nRoundNumber = roundNumber

	self._nBagCount = tonumber( kv.BagCount or 0 )
	self._nBagVariance = tonumber( kv.BagVariance or 0 )
	self._nFixedXP = tonumber( kv.FixedXP or 0 )
	self._nFixedGold = tonumber( kv.FixedGold or 0 )

	self._vSpawners = {}
	for k, v in pairs( kv ) do
		if type( v ) == "table" then
			local tabLen = tonumber(GetTableLength(v))
			local index = tostring(RandomInt(1, tabLen))
			if v[index] then
				self._szRoundQuestTitle = v[index].round_quest_title or kv.round_quest_title or "#DOTA_Quest_Holdout_Round"
				self._szRoundTitle = v[index].round_title or string.format( "Round%d", roundNumber )
				for l,m in pairs(v[index]) do
					if type( m ) == "table" and m.NPCName then
						local spawner = CHoldoutGameSpawner()
						spawner:ReadConfiguration( l, m, self )
						self._vSpawners[ l ] = spawner
					end
				end
			end
		end
	end
	
	self:Precache()

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
	local PlayerNumber = HeroList:GetActiveHeroCount()
	local GoldMultiplier = 1 + (0.2 * (GameRules.BasePlayers - PlayerNumber))

	local roundNumber = self._nRoundNumber
	
	self._nGoldRemainingInRound = self._nFixedGold * GoldMultiplier
	self._nExpRemainingInRound = self._nFixedXP
	
	for _, spawner in pairs( self._vSpawners ) do
		spawner:Begin()
		self._nCoreUnitsTotal = (self._nCoreUnitsTotal or 0) + spawner:GetTotalUnitsToSpawn()
		if self._nRoundNumber == 24 then
			self._nCoreUnitsTotal = self._nCoreUnitsTotal + 1
		end
	end
	
	-- ELITE HANDLING
	self._nElitesToSpawn = 0
	self._EliteAbilities = {}
	local elitePct = 15

	for i=1, self._nCoreUnitsTotal do
		if RollPercentage( elitePct ) and self._nRoundNumber > 1 then
			self._nElitesToSpawn = self._nElitesToSpawn + 1
			self._nGoldRemainingInRound = self._nGoldRemainingInRound + self._nRoundNumber * 3
		end
	end
	
	self._nElitesRemaining = self._nElitesToSpawn
	self._nCoreUnitsSpawned = self._nCoreUnitsTotal
	self._nCoreUnitsKilled = 0
	-- CustomGameEventManager:Send_ServerToAllClients( "sendDifficultyNotification", { difficulty = GameRules.gameDifficulty, compromised = GameRules.difficultyCompromised } )
end

function CHoldoutGameRound:OnHoldoutReviveComplete( event )
	local castingHero = EntIndexToHScript( event.caster )
	local target = EntIndexToHScript( event.target )
	
	if castingHero then
		castingHero.Resurrections = (castingHero.Resurrections or 0) + 1
		local ngmodifier = 0
		print( target )
		target:AddNewModifier(target, nil, "modifier_tombstone_respawn_immunity", {duration = 3})
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

	local delay = 30
	Timers:CreateTimer(0.03, function()
		for _,unit in pairs( FindUnitsInRadius( DOTA_TEAM_BADGUYS, Vector( 0, 0, 0 ), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false )) do
			if not (unit:IsTower() or unit:IsHero()) and not unit:HasModifier("modifier_hidden_generic") and not unit:HasAbility("hide_hero") then
				unit:ForceKill( false )
				Timers:CreateTimer(0.1, function() UTIL_Remove(unit) end)
			end
		end
		if delay > 0 then 
			delay = delay - 1
			return 0.03
		end
	end)
	if self._nRoundNumber == 1 then
		for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
			if not unit:IsFakeHero() then
				while unit:GetLevel() < 7 do
					unit:AddExperience (100,false,false)
				end
			end
		end
	end
	for _,spawner in pairs( self._vSpawners ) do
		spawner:End()
	end
	self._vEnemiesRemaining = {}
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
	local nCoreUnitsRemaining = (self._nCoreUnitsTotal or 0) - (self._nCoreUnitsKilled or 0)
	Timers:CreateTimer(0.1,function()
				self:HandleElites(spawnedUnit)
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
			spawnedUnit:AddAbility('true_sight_boss')
		end
		spawnedUnit:SetDeathXP( 0 )
		spawnedUnit.unitName = spawnedUnit:GetUnitName()
		GridNav:DestroyTreesAroundPoint(spawnedUnit:GetAbsOrigin(), spawnedUnit:GetHullRadius() + spawnedUnit:GetCollisionPadding() + 350, true)
		FindClearSpaceForUnit(spawnedUnit, spawnedUnit:GetAbsOrigin(), true)
	end
end


function CHoldoutGameRound:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	if not killedUnit then
		return
	end
	
	if killedUnit:GetUnitName() == "npc_dota_boss38" then
		for _,unit in pairs( FindUnitsInRadius( DOTA_TEAM_BADGUYS, Vector( 0, 0, 0 ), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )) do
			if not unit:IsTower() or unit:IsHero() == false and not unit:GetName() == "npc_dota_creature" then -- remove dummy units
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
	local nCoreUnitsRemaining = self._nCoreUnitsTotal - self._nCoreUnitsKilled
	local PlayerNumber = HeroList:GetActiveHeroCount()
	local exptogain = 0
	local goldtogain = 0
	if nCoreUnitsRemaining > 0 then
		exptogain = self._nExpRemainingInRound / nCoreUnitsRemaining
		goldtogain = self._nGoldRemainingInRound / nCoreUnitsRemaining
	elseif nCoreUnitsRemaining <= 1 then
		exptogain = self._nExpRemainingInRound
		goldtogain = self._nGoldRemainingInRound
	end
	
	for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
		if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS and not unit:IsFakeHero() then
			if exptogain > 0 then
				unit:AddExperience (exptogain,false,false)
			end
			if goldtogain > 0 then
				local totalgold = unit:GetGold() + goldtogain
				unit:SetGold(0 , false)
				unit:SetGold(totalgold, true)
			end
		end
	end
	
	self._nGoldRemainingInRound = math.max( 0, self._nGoldRemainingInRound - goldtogain )
	self._nExpRemainingInRound = math.max( 0,self._nExpRemainingInRound - exptogain)
end

function CHoldoutGameRound:HandleElites(spawnedUnit)
	if spawnedUnit:IsCore() then
		self._nCoreUnitsSpawned = self._nCoreUnitsSpawned - 1
		if self._nElitesRemaining > 0 or spawnedUnit:IsElite() then
			local elitemod = 1 + (GameRules.gameDifficulty - 1)* 0.12 -- Power scaling
			spawnedUnit.elite = true
			local elitelist = {} -- change table with names to array type
			-- Block non-attacking units from having these
			local notcore = {   ["elite_disarming"] = true,
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
								["elite_nimble"] = true,
								["elite_blocking"] = true}
			-- Block certain combos
			local blocked = {	["elite_disarming"] = "elite_silencing",
								["elite_silencing"] = "elite_disarming",
								["elite_sweeping"] = "elite_piercing",
								["elite_piercing"] = "elite_sweeping"}
			for k,v in pairs(GameRules._Elites) do
				if not (notcore[k] and spawnedUnit:IsSpawner()) then
					table.insert(elitelist, k)
				elseif not (blocked[k] and self._EliteAbilities[blocked[k]]) and spawnedUnit:IsSpawner() then
					table.insert(elitelist, k)
				elseif k == "elite_farseer" and self._nRoundNumber > 4 then
					table.insert(elitelist, k)
				end
			end
			
			local eliteabstogive = 1
			if GameRules._NewGamePlus == true or GameRules.gameDifficulty >= 4 then
				eliteabstogive = 2
			end
			
			local eliteAbName = elitelist[RandomInt(1,#elitelist)]
			if spawnedUnit:IsElite() and spawnedUnit.eliteAb then -- if elite spawned through other ways
				if spawnedUnit:GetMaxHealth() < self._nRoundNumber * 200 then
					spawnedUnit:SetBaseMaxHealth(spawnedUnit:GetMaxHealth()+self._nRoundNumber * 200)
					spawnedUnit:SetMaxHealth(spawnedUnit:GetMaxHealth()+self._nRoundNumber * 200)
				end
				spawnedUnit:SetMaxHealth(spawnedUnit:GetMaxHealth()*elitemod )
			elseif self._nCoreUnitsSpawned > self._nElitesRemaining then -- If leftover enemies, randomize
				if RollPercentage(33) then
					if spawnedUnit:GetMaxHealth() < self._nRoundNumber * 250 and spawnedUnit:GetName() ~= "npc_dota_money" and spawnedUnit:GetUnitName() ~= "npc_dota_boss36" then
						spawnedUnit:SetBaseMaxHealth(spawnedUnit:GetMaxHealth()+self._nRoundNumber * 250)
						spawnedUnit:SetMaxHealth(spawnedUnit:GetMaxHealth()+self._nRoundNumber * 250)
					end
					spawnedUnit:SetBaseMaxHealth(spawnedUnit:GetMaxHealth()*(2 - 0.90 * self._nRoundNumber/GameRules:GetMaxRound())*elitemod )
					spawnedUnit:SetMaxHealth(spawnedUnit:GetMaxHealth()*elitemod  )
					spawnedUnit.elite = true
				end
			else
				if spawnedUnit:GetMaxHealth() < self._nRoundNumber * 250 and spawnedUnit:GetName() ~= "npc_dota_money" and spawnedUnit:GetUnitName() ~= "npc_dota_boss36" then
					spawnedUnit:SetBaseMaxHealth(spawnedUnit:GetMaxHealth()+self._nRoundNumber * 250)
					spawnedUnit:SetMaxHealth(spawnedUnit:GetMaxHealth()+self._nRoundNumber * 250)
				end
				spawnedUnit:SetBaseMaxHealth(spawnedUnit:GetMaxHealth()*elitemod )
				spawnedUnit:SetMaxHealth(spawnedUnit:GetMaxHealth()*elitemod )
				spawnedUnit.elite = true
			end
			if spawnedUnit:IsElite() then -- is elite, has passed initial checks
			
				local nParticle = ParticleManager:CreateParticle( "particles/econ/courier/courier_onibi/courier_onibi_yellow_ambient_smoke_lvl21.vpcf", PATTACH_ABSORIGIN_FOLLOW, spawnedUnit )
				ParticleManager:ReleaseParticleIndex( nParticle )
				
				spawnedUnit:SetHealth(spawnedUnit:GetMaxHealth())
				spawnedUnit:SetModelScale(spawnedUnit:GetModelScale()*1.5)
				
				local eliteAbType = ""
				while eliteabstogive > 0 do
					local eliteAb = spawnedUnit:AddAbilityPrecache(eliteAbName)
					eliteAb:SetLevel(eliteAb:GetMaxLevel())
					eliteAbType = eliteAbType.." "..GameRules._Elites[eliteAbName]
					self._EliteAbilities[eliteAbName] = true
					if blocked[eliteAbName] then
						table.removekey(elitelist,blocked[eliteAbName])
					end
					table.removekey(elitelist,eliteAbName)
					eliteAbName = elitelist[RandomInt(1,#elitelist)]
					eliteabstogive = eliteabstogive - 1
				end
				self._nElitesRemaining = self._nElitesRemaining - 1
				local messageinfo = {
					message = "An elite boss has spawned with "..eliteAbType.." ability!",
					duration = 5}
				FireGameEvent("show_center_message",messageinfo)
			end
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