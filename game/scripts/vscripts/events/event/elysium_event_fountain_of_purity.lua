local function CheckPlayerChoices(self)
	for pID = 0, 24 do
		if self._playerChoices[pID] then	
			return true
		end
	end
	self:EndEvent(true)
	return true
end

local function FirstChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	hero:PurgeCurses( )
	self._playerChoices[event.pID] = true
	CheckPlayerChoices(self)
end

local function SecondChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	hero:AddRelic( "relic_unique_ofuda" )
	self._playerChoices[event.pID] = true
	CheckPlayerChoices(self)
end

local function ThirdChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	hero:AddBlessing("event_buff_fountain_of_purity")
	self._playerChoices[event.pID] = true
	CheckPlayerChoices(self)
end

local function StartEvent(self)
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_started", {event = self:GetEventName(), choices = 3})
	self._vEventHandles = {
		CustomGameEventManager:RegisterListener('player_selected_event_choice_1', Context_Wrap( self, 'FirstChoice') ),
		CustomGameEventManager:RegisterListener('player_selected_event_choice_2', Context_Wrap( self, 'SecondChoice') ),
		CustomGameEventManager:RegisterListener('player_selected_event_choice_3', Context_Wrap( self, 'ThirdChoice') ),
	}
	self.timeRemaining = 30
	self.eventEnded = false
	Timers:CreateTimer(1, function()
		CustomGameEventManager:Send_ServerToAllClients("updateQuestPrepTime", {prepTime = self.timeRemaining})
		if self.timeRemaining >= 0 then
			self.timeRemaining = self.timeRemaining - 1
			return 1
		elseif not self.eventEnded then
			self:EndEvent(true)
		end
	end)
	
	self._playerChoices = {}

	LinkLuaModifier("event_buff_fountain_of_purity", "events/modifiers/event_buff_fountain_of_purity", LUA_MODIFIER_MOTION_NONE)
end

local function EndEvent(self, bWon)
	for _, eID in pairs( self._vEventHandles ) do
		CustomGameEventManager:UnregisterListener( eID )
	end
	self.eventEnded = true
	self.timeRemaining = -1
	Timers:CreateTimer(3, function() RoundManager:EndEvent(true) end)
end

local function PrecacheUnits(self)
	return true
end

local funcs = {
	["StartEvent"] = StartEvent,
	["EndEvent"] = EndEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["FirstChoice"] = FirstChoice,
	["SecondChoice"] = SecondChoice,
	["ThirdChoice"] = ThirdChoice,
}

return funcs