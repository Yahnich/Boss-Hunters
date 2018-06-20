local function CheckPlayerChoices(self)
	for pID, choice in pairs( self._playerChoices ) do
		if not choice then
			return false
		end
	end
	self:StartCombat(true)
	return true
end

local function FirstChoice(self, userid, event)
	self._playerChoices[event.pID] = true
	CheckPlayerChoices(self)
end

local function StartCombat(self)
	self.eventEnded = true
	self.combatEnded = false
	local START_VECTOR = Vector(949, 130)
	
	self.timeRemaining = 30
	
	self.demon = CreateUnitByName("npc_dota_money_roshan", START_VECTOR, true, nil, nil, DOTA_TEAM_GOODGUYS)
	
	local activeHeroes = HeroList:GetActiveHeroCount()
	
	Timers:CreateTimer(1, function()
		CustomGameEventManager:Send_ServerToAllClients("updateQuestPrepTime", {prepTime = self.timeRemaining})
		self.timeRemaining = self.timeRemaining - 1
		if self.timeRemaining >= 0 then
			return 1
		else
			self:EndEvent(true)
		end
	end)
end

local function StartEvent(self)
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_started", {event = "solitude_event_demon_of_avarice", choices = 1})
	self._vListenerHandles = {
		CustomGameEventManager:RegisterListener('player_selected_event_choice_1', Context_Wrap( self, 'FirstChoice') ),
	}
	
	self.timeRemaining = 10
	self.eventEnded = false
	Timers:CreateTimer(1, function()
		CustomGameEventManager:Send_ServerToAllClients("updateQuestPrepTime", {prepTime = self.timeRemaining})
		if not self.eventEnded then
			if self.timeRemaining >= 0 then
				self.timeRemaining = self.timeRemaining - 1
				return 1
			else
				self:StartCombat(true)
			end
		end
	end)
	
	self._playerChoices = {}
	for i = 0, GameRules.BasePlayers do
		if PlayerResource:IsValidPlayerID(i) and PlayerResource:GetPlayer(i) then
			self._playerChoices[i] = false
		end
	end
end

local function EndEvent(self, bWon)
	for _, eID in pairs( self._vListenerHandles ) do
		CustomGameEventManager:UnregisterListener( eID )
	end
	self.eventEnded = true
	self.combatEnded = true
	self.timeRemaining = -1
	
	self.demon:ForceKill( false )
	
	Timers:CreateTimer(3, function() RoundManager:EndEvent(true) end)
end

local function PrecacheUnits(self)
	return true
end

local function HandoutRewards(self)
	return false
end

local funcs = {
	["StartEvent"] = StartEvent,
	["EndEvent"] = EndEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["FirstChoice"] = FirstChoice,
	["StartCombat"] = StartCombat,
}

return funcs