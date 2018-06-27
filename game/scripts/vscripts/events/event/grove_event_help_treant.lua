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
	
	if not self.eventEnded then
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
		self._vEventHandles = {
			ListenToGameEvent( "entity_killed", require("events/base_combat"), self ),
		}
		self.timeRemaining = 0
		self.bossesToSpawn = 1 + math.floor( math.log( RoundManager:GetRaidsFinished() + 1 ) )
		self.mobsToSpawn = 4 + math.floor( math.log( RoundManager:GetEventsFinished() + 1 ) )
		self.helpedTreant = true
		BOSS_SPAWNS = {"npc_dota_boss21", "npc_dota_boss23_m"}
		MOB_SPAWNS = {"npc_dota_boss26_mini", "npc_dota_boss6", "npc_dota_creature_broodmother", "npc_dota_boss10"}
		
		local bossToSpawn = BOSS_SPAWNS[RandomInt(1, #BOSS_SPAWNS)]
		local mobToSpawn = MOB_SPAWNS[RandomInt(1, #MOB_SPAWNS)]
		
		self.enemiesToSpawn = self.bossesToSpawn + self.mobsToSpawn
		Timers:CreateTimer(20, function()
			local spawn = CreateUnitByName(bossToSpawn, RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundBoss = true
			self.bossesToSpawn = self.bossesToSpawn - 1
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			if self.bossesToSpawn > 0 then
				return 15 / (RoundManager:GetRaidsFinished() + 1)
			end
		end)
		Timers:CreateTimer(5, function()
			local spawn = CreateUnitByName(mobToSpawn, RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundBoss = true
			self.mobsToSpawn = self.mobsToSpawn - 1
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			if self.mobsToSpawn > 0 then
				return 5 / (RoundManager:GetRaidsFinished() + 1)
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
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_started", {event = "grove_event_help_treant", choices = 2})
	self._vListenerHandles = {
		CustomGameEventManager:RegisterListener('player_selected_event_choice_1', Context_Wrap( self, 'FirstChoice') ),
		CustomGameEventManager:RegisterListener('player_selected_event_choice_2', Context_Wrap( self, 'SecondChoice') ),
	}
	self._vEventHandles = {}
	self.timeRemaining = 15
	self.eventEnded = false
	self.waitTimer = Timers:CreateTimer(1, function()
		CustomGameEventManager:Send_ServerToAllClients("updateQuestPrepTime", {prepTime = self.timeRemaining})
		if not self.eventEnded and not self.helpedTreant then
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
	LinkLuaModifier("event_buff_help_treant", "events/modifiers/event_buff_help_treant", LUA_MODIFIER_MOTION_NONE)
	self._playerChoices = {}
end

local function EndEvent(self, bWon)
	for _, eID in pairs( self._vEventHandles ) do
		StopListeningToGameEvent( eID )
	end
	for _, eID in pairs( self._vListenerHandles ) do
		CustomGameEventManager:UnregisterListener( eID )
	end
	
	if self.helpedTreant then
		for _, hero in ipairs( HeroList:GetRealHeroes() ) do
			hero:AddNewModifier(hero, nil, "event_buff_help_treant", {})
		end
		CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_reward_given", {event = "grove_event_help_treant", reward = 1})
	end
	
	self.eventEnded = true
	self.timeRemaining = -1
	Timers:CreateTimer(3, function() RoundManager:EndEvent(true) end)
end

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_boss23_m", context)
	PrecacheUnitByNameSync("npc_dota_boss21", context)
	PrecacheUnitByNameSync("npc_dota_boss26_mini", context)
	PrecacheUnitByNameSync("npc_dota_boss6", context)
	PrecacheUnitByNameSync("npc_dota_creature_broodmother", context)
	PrecacheUnitByNameSync("npc_dota_boss10", context)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["EndEvent"] = EndEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["FirstChoice"] = FirstChoice,
	["SecondChoice"] = SecondChoice,
	["StartCombat"] = StartCombat,
}

return funcs