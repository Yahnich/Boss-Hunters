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
	if bFight then
		self.timeRemaining = 0
		self.combatStarted = true
		self.undying = math.min(1, 0 + math.ceil(RoundManager:GetRaidsFinished() / 3))
		self.zombos = math.ceil( (2 + RoundManager:GetEventsFinished() ) * HeroList:GetActiveHeroCount() / 1.5 )
		self.enemiesToSpawn = self.undying + self.zombos
		Timers:CreateTimer(3, function()
			local spawn = CreateUnitByName("npc_dota_boss4", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundBoss = true
			self.undying = self.undying - 1
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			if self.undying > 0 then
				return 15
			end
		end)
		Timers:CreateTimer(5, function()
			local zombie = "npc_dota_boss3a"
			if RollPercentage(33) then
				zombie = "npc_dota_boss3b"
			end
			local spawn = CreateUnitByName(zombie, RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundBoss = true
			
			self.zombos = self.zombos - 1
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			if self.zombos > 0 then
				return 5
			end
		end)
	else
		self:EndEvent(true)
	end
end


local function FirstChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	self._playerChoices[event.pID] = true
	CheckPlayerChoices(self)
end

local function SecondChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	self._playerChoices[event.pID] = false
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

local function HandoutRewards(self)
	if self.combatStarted then
		for _, hero in ipairs( HeroList:GetRealHeroes() ) do
			local pID = hero:GetPlayerOwnerID()
			for i = 1, 2 do
				local dropTable = {}
				if RollPercentage(65) then
					table.insert( dropTable, self:RollRandomUniqueRelicForPlayer(pID) )
				else
					table.insert( dropTable, self:RollRandomCursedRelicForPlayer(pID) )
				end
				RelicManager:PushCustomRelicDropsForPlayer(pID, dropTable)
			end
		end
	end
end

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_boss4", context)
	PrecacheUnitByNameSync("npc_dota_boss3a", context)
	PrecacheUnitByNameSync("npc_dota_boss3a_b", context)
	PrecacheUnitByNameSync("npc_dota_boss3b", context)
	PrecacheUnitByNameSync("npc_dota_mini_boss1", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["EndEvent"] = EndEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["FirstChoice"] = FirstChoice,
	["SecondChoice"] = SecondChoice,
	["StartCombat"] = StartCombat,
	["RetryVote"] = RetryVote,
	["GivePlayerGold"] = GivePlayerGold,
	["HandoutRewards"] = HandoutRewards,
}

return funcs