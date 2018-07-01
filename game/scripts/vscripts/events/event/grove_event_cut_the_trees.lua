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
			self:GivePlayerGold()
			self.treesCut = (self.treesCut or 0) + 1
			Timers:CreateTimer(3, function()
				if RollPercentage(25) then
					self:StartCombat(true)
				else
					self:RetryVote()
				end
			end)
			return true
		elseif votedNo > votedYes + (players - voted) then -- no votes exceed yes and non-votes and every other situation
			self:StartCombat(false)
			return true
		end
	end
	return false
end

local function GivePlayerGold()
	for _, hero in ipairs ( HeroList:GetRealHeroes() ) do
		hero:AddGold(500)
	end
end

local function StartCombat(self, bFight)
	if bFight then
		self.timeRemaining = 0
		self.combatStarted = true
		self.drowsToSpawn = 1 + math.ceil( math.log(self.treesCut) )
		self.treantsToSpawn = (1 + math.ceil( math.log(self.treesCut) ) ) * HeroList:GetActiveHeroCount()
		self.furionsToSpawn = (2 + math.ceil( math.log(self.treesCut) ) ) * HeroList:GetActiveHeroCount()
		self.enemiesToSpawn = self.drowsToSpawn + self.treantsToSpawn + self.furionsToSpawn
		Timers:CreateTimer(3, function()
			local spawn = CreateUnitByName("npc_dota_boss28", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundBoss = true
			self.drowsToSpawn = self.drowsToSpawn - 1
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			if self.drowsToSpawn > 0 then
				return 15
			end
		end)
		Timers:CreateTimer(5, function()
			local spawn = CreateUnitByName("npc_dota_boss18", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundBoss = true
			spawn.armor = spawn:FindAbilityByName("boss_living_armor")
			if spawn.armor then spawn.armor:SetLevel( math.max(5, self.treesCut ) ) end
			
			self.treantsToSpawn = self.treantsToSpawn - 1
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			if self.treantsToSpawn > 0 then
				return 10
			end
		end)
		Timers:CreateTimer(6, function()
			local spawn = CreateUnitByName("npc_dota_boss19", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundBoss = true
			spawn.armor = spawn:FindAbilityByName("boss_living_armor")
			if spawn.armor then spawn.armor:SetLevel( math.max(5, self.treesCut ) ) end
			
			self.furionsToSpawn = self.furionsToSpawn - 1
			
			self.enemiesToSpawn = self.enemiesToSpawn - 1	
			if self.furionsToSpawn > 0 then
				return 10
			end
		end)
	else
		self:EndEvent(true)
	end
end

local function RetryVote(self)
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_started", {event = "grove_event_cut_the_trees", choices = 2})
	self.timeRemaining = 15
	self._playerChoices = {}
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
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_started", {event = "grove_event_cut_the_trees", choices = 2})
	self._vListenerHandles = {
		CustomGameEventManager:RegisterListener('player_selected_event_choice_1', Context_Wrap( self, 'FirstChoice') ),
		CustomGameEventManager:RegisterListener('player_selected_event_choice_2', Context_Wrap( self, 'SecondChoice') ),
	}
	self._vEventHandles = {
		ListenToGameEvent( "entity_killed", require("events/base_combat"), self ),
	}
	self.treesCut = 0
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
	if self.fought then
		local eventScaling = RoundManager:GetEventsFinished()
		local playerScaling = GameRules.BasePlayers - HeroList:GetActiveHeroCount()
		local baseXP = 500 + eventScaling * (100 + 10 * playerScaling)
		local baseGold = 100 + eventScaling * (25 + 3 * playerScaling)
		for _, hero in ipairs( HeroList:GetRealHeroes() ) do
			hero:AddGold( baseGold )
			hero:AddXP( baseXP )
			local pID = hero:GetPlayerOwnerID()
			RelicManager:RollEliteRelicsForPlayer(pID)
		end
	end
end

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_boss28", context)
	PrecacheUnitByNameSync("npc_dota_boss18", context)
	PrecacheUnitByNameSync("npc_dota_boss19", context)
	PrecacheUnitByNameSync("npc_dota_mini_tree", context)
	PrecacheUnitByNameSync("npc_dota_mini_tree2", context)
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