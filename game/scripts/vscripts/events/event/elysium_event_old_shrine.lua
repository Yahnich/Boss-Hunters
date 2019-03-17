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
	if not hero then return end
	hero:AddGold(-800)
	if RollPercentage(33) then
		RelicManager:PushCustomRelicDropsForPlayer(pID, {RelicManager:RollRandomRelicForPlayer(pID)})
		if hero:GetPlayerOwner() then
			Timers:CreateTimer(0.5, function() CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "boss_hunters_event_reward_given", {event = self:GetEventName(), reward = 1}) end)
		end
	end
	
	
	self._playerChoices[event.pID] = true
	CheckPlayerChoices(self)
end

local function SecondChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )

	local relicList = {}
	local relicKey
	local rarity = "RARITY_COMMON"
	while relicList[1] == nil and rarity ~= "RARITY_LEGENDARY" do
		for item, relic in pairs( hero.ownedRelics ) do
			if relic.rarity == rarity then
				table.insert(relicList, relic)
			end
		end
		if relicList[1] == nil then
			if rarity == "RARITY_COMMON" then
				rarity == "RARITY_UNCOMMON"
			elseif rarity == "RARITY_UNCOMMON" then
				rarity == "RARITY_RARE"
			elseif rarity == "RARITY_RARE" then
				rarity == "RARITY_LEGENDARY"
			end
		end
	end
	if relicList[1] then
		local relic = relicList[RandomInt(1, #relicList)]
		RelicManager:RemoveRelicOnPlayer(relic, event.pID)
		RelicManager:PushCustomRelicDropsForPlayer(pID, {RelicManager:RollRandomRelicForPlayer(pID)})
	end
	self._playerChoices[event.pID] = true
	CheckPlayerChoices(self)
end

local function ThirdChoice(self, userid, event)
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