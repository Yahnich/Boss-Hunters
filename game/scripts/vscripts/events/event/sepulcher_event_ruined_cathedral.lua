local function CheckPlayerChoices(self)
	local votedYes = 0
	local votedNo = 0
	local voted = 0
	local players = 0
	for i = 0, GameRules.BasePlayers do
		if PlayerResource:IsValidPlayerID(i) and PlayerResource:GetPlayer(i) then
			players = players + 1
			if self._playerChoices[i] ~= nil then
				voted = voted + 1
				if self._playerChoices[i] then
					votedYes = votedYes + 1
				else
					votedNo = votedNo + 1
				end
			end
		end
	end
	if not self.eventEnded and not self.combatStarted then
		if votedYes > votedNo + (players - voted) then -- yes votes exceed non-votes and no votes
			self:StartCombat(true)
			return true
		elseif votedNo > votedYes + (players - voted) then -- no votes exceed yes and non-votes and every other situation
			self:StartCombat(false)
			return true
		end
	end
	return false
end

local function StartCombat(self, bFight)
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_ended", {})
	if bFight then
		self.combatStarted = true
		self.eventType = EVENT_TYPE_ELITE
		self.timeRemaining = 0
		self.combatStarted = true
		self.prophets = 1
		self.undying = 1 + RoundManager:GetCurrentRaidTier()
		self.minions = math.floor( math.log(2 + RoundManager:GetEventsFinished() ) * HeroList:GetActiveHeroCount() / 1.5 )
		self.enemiesToSpawn = self.prophets + self.undying + self.minions
		Timers:CreateTimer(3, function()
			local spawn = CreateUnitByName("npc_dota_boss22", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundNecessary = true
			self.prophets = self.prophets - 1
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			if self.prophets > 0 then
				return 15
			end
		end)
		Timers:CreateTimer(5, function()
			local spawn = CreateUnitByName("npc_dota_boss4", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundNecessary = true
			spawn:SetCoreHealth(2500)
			self.undying = self.undying - 1
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			if self.undying > 0 then
				return 10
			end
		end)
		Timers:CreateTimer(2, function()
			local spawn = CreateUnitByName("npc_dota_boss3b", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundNecessary = false
			
			self.minions = self.minions - 1
			
			self.enemiesToSpawn = self.enemiesToSpawn - 1	
			if self.minions > 0 then
				return 2
			end
		end)
	else
		for _, hero in ipairs( HeroList:GetRealHeroes() ) do
			hero:AddBlessing("event_buff_ruined_cathedral")
		end
		self:EndEvent(true)
	end
end


local function FirstChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	self._playerChoices[event.pID] = false
	CheckPlayerChoices(self)
end

local function SecondChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	self._playerChoices[event.pID] = true
	CheckPlayerChoices(self)
end

local function StartEvent(self)	
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_started", {event = self:GetEventName(), choices = 2})
	self._vListenerHandles = {
		CustomGameEventManager:RegisterListener('player_selected_event_choice_1', Context_Wrap( self, 'FirstChoice') ),
		CustomGameEventManager:RegisterListener('player_selected_event_choice_2', Context_Wrap( self, 'SecondChoice') ),
	}
	self._vEventHandles = {
		ListenToGameEvent( "entity_killed", require("events/base_combat"), self ),
	}
	self.timeRemaining = 15
	self.eventEnded = false
	self.combatStarted = false
	self.waitTimer = Timers:CreateTimer(1, function()
		CustomGameEventManager:Send_ServerToAllClients("updateQuestPrepTime", {prepTime = self.timeRemaining})
		if not self.eventEnded and not self.combatStarted then
			if self.timeRemaining >= 0 then
				self.timeRemaining = self.timeRemaining - 1
				return 1
			else
				if not CheckPlayerChoices(self) then
					self:EndEvent(true)
				end
			end
		end
	end)
	
	self._playerChoices = {}
	LinkLuaModifier("event_buff_ruined_cathedral", "events/modifiers/event_buff_ruined_cathedral", LUA_MODIFIER_MOTION_NONE)
end

local function EndEvent(self, bWon)
	for _, eID in pairs( self._vEventHandles ) do
		StopListeningToGameEvent( eID )
	end
	for _, eID in pairs( self._vListenerHandles ) do
		CustomGameEventManager:UnregisterListener( eID )
	end
	
	self.eventEnded = true
	self.timeRemaining = -1
	Timers:CreateTimer(3, function() RoundManager:EndEvent(bWon) end)
end

local function HandoutRewards(self, bWon)
	if self.combatStarted and bWon then
		for _, hero in ipairs( HeroList:GetRealHeroes() ) do
			local pID = hero:GetPlayerOwnerID()
			RelicManager:PushCustomRelicDropsForPlayer(pID, {RelicManager:RollRandomRelicForPlayer(pID, "RARITY_RARE", false)})
			RelicManager:PushCustomRelicDropsForPlayer(pID, {RelicManager:RollRandomRelicForPlayer(pID, "RARITY_COMMON", false, true)})
		end
	end
end

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_boss22", context)
	PrecacheUnitByNameSync("npc_dota_boss22b", context)
	PrecacheUnitByNameSync("npc_dota_boss4", context)
	PrecacheUnitByNameSync("npc_dota_boss3b", context)
	PrecacheUnitByNameSync("npc_dota_mini_boss1", context)
	return true
end

local function LoadSpawns(self)
	if not self.spawnLoadCompleted then
		RoundManager.spawnPositions = {}
		RoundManager.boundingBox = "sepulcher_event_ruined_cathedral"
		for _,spawnPos in ipairs( Entities:FindAllByName( RoundManager.boundingBox.."_spawner" ) ) do
			table.insert( RoundManager.spawnPositions, spawnPos:GetAbsOrigin() )
		end
		self.heroSpawnPosition = self.heroSpawnPosition or nil
		for _,spawnPos in ipairs( Entities:FindAllByName( RoundManager.boundingBox.."_heroes") ) do
			self.heroSpawnPosition = spawnPos:GetAbsOrigin()
			break
		end
		
		self.spawnLoadCompleted = true
	end
end

local funcs = {
	["StartEvent"] = StartEvent,
	["EndEvent"] = EndEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["LoadSpawns"] = LoadSpawns,
	["FirstChoice"] = FirstChoice,
	["SecondChoice"] = SecondChoice,
	["StartCombat"] = StartCombat,
	["RetryVote"] = RetryVote,
	["GivePlayerGold"] = GivePlayerGold,
	["HandoutRewards"] = HandoutRewards,
}

return funcs