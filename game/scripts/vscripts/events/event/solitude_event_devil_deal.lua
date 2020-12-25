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

local function FirstChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	
	RelicManager:PushCustomRelicDropsForPlayer(event.pID, {RelicManager:RollRandomRelicForPlayer(event.pID, "RARITY_COMMON", true)})
	
	self._playerChoices[event.pID] = true
	CheckPlayerChoices(self)
end

local function SecondChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	if not hero then return end
	hero:AddCurse("event_buff_devil_deal")
	RelicManager:PushCustomRelicDropsForPlayer(event.pID, {RelicManager:RollRandomRelicForPlayer(event.pID, "RARITY_UNCOMMON", false, true)})
	
	self._playerChoices[event.pID] = true
	CheckPlayerChoices(self)
end

local function ThirdChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	
	local relicList = {}
	for item, relic in pairs( hero.ownedRelics ) do
		if relic then
			table.insert(relicList, relic.name)
		end
	end
	if #relicList > 0 then
		local relicName = relicList[RandomInt(1, #relicList)]
		RelicManager:RemoveRelicOnPlayer(relicName, event.pID)
	end
	
	RelicManager:PushCustomRelicDropsForPlayer(event.pID, {RelicManager:RollRandomRelicForPlayer(event.pID, "RARITY_RARE", true)})
	
	self._playerChoices[event.pID] = true
	CheckPlayerChoices(self)
end

local function StartEvent(self)
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_started", {event = "solitude_event_devil_deal", choices = 3})
	self._vEventHandles = {
		CustomGameEventManager:RegisterListener('player_selected_event_choice_1', Context_Wrap( self, 'FirstChoice') ),
		CustomGameEventManager:RegisterListener('player_selected_event_choice_2', Context_Wrap( self, 'SecondChoice') ),
		CustomGameEventManager:RegisterListener('player_selected_event_choice_3', Context_Wrap( self, 'ThirdChoice') ),
	}
	self:StartEventTimer( )
	
	self._playerChoices = {}
	
	LinkLuaModifier("event_buff_devil_deal", "events/modifiers/event_buff_devil_deal", LUA_MODIFIER_MOTION_NONE)
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