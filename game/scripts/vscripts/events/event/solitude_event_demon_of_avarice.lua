local function CheckPlayerChoices(self)
	for _, hero in ipairs( HeroList:GetActiveHeroes() ) do
		local pID = hero:GetPlayerID()
		if pID and not self._playerChoices[pID] then
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
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_ended", {})
	self.eventEnded = true
	self.combatEnded = false
	local START_VECTOR = self:GetHeroSpawnPosition()
	self.eventType = EVENT_TYPE_COMBAT
	self.timeRemaining = 30
	
	self.demon = CreateUnitByName("npc_dota_money_roshan", START_VECTOR, true, nil, nil, DOTA_TEAM_BADGUYS)
	self.demon:FindAbilityByName("generic_gold_dropper"):SetLevel(1)
	
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
end

local function EndEvent(self, bWon)
	for _, eID in pairs( self._vListenerHandles ) do
		CustomGameEventManager:UnregisterListener( eID )
	end
	self.eventEnded = true
	self.combatEnded = true
	self.timeRemaining = -1
	
	if self.demon and not self.demon:IsNull() then self.demon:ForceKill( false ) end
	
	Timers:CreateTimer(3, function() RoundManager:EndEvent(true) end)
end

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_money_roshan", context)
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