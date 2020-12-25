local function CheckPlayerChoices(self)
	for _, hero in ipairs( HeroList:GetActiveHeroes() ) do
		local pID = hero:GetPlayerID()
		if pID and not self._playerChoices[pID] then
			return false
		end
	end
	self:EndEvent(true)
	return true
end


local function GiveRelicChoices(self, hero)
	local votesWithOfuda = 0
	local votesWithout = 0
	local pID = hero:GetPlayerID()
	local cursedTable = {}
	local uniqueTable = {}
	for i = 1, 3 do
		table.insert(cursedTable, RelicManager:RollRandomRelicForPlayer(pID, "RARITY_UNCOMMON", false, true) )
	end
	for i = 1, 3 do
		table.insert(uniqueTable, RelicManager:RollRandomRelicForPlayer(pID, "RARITY_UNCOMMON", false, false) )
	end
	
	RelicManager:PushCustomRelicDropsForPlayer(pID, cursedTable)
	RelicManager:PushCustomRelicDropsForPlayer(pID, uniqueTable)
end

local function FirstChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	self._playerChoices[event.pID] = true
	
	hero:AddCurse("event_buff_graverobber_curse")	
	self:GiveRelicChoices(hero)
	CheckPlayerChoices(self)
end

local function SecondChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	self._playerChoices[event.pID] = false
	CheckPlayerChoices(self)
end

local function StartEvent(self)	
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_started", {event = "sepulcher_event_graverobber", choices = 2})
	self._vListenerHandles = {
		CustomGameEventManager:RegisterListener('player_selected_event_choice_1', Context_Wrap( self, 'FirstChoice') ),
		CustomGameEventManager:RegisterListener('player_selected_event_choice_2', Context_Wrap( self, 'SecondChoice') ),
	}
	self:StartEventTimer( )
	LinkLuaModifier("event_buff_graverobber_curse", "events/modifiers/event_buff_graverobber", LUA_MODIFIER_MOTION_NONE)
	self._playerChoices = {}
end

local function EndEvent(self, bWon)
	for _, eID in pairs( self._vListenerHandles ) do
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
	["GiveRelicChoices"] = GiveRelicChoices,
}

return funcs