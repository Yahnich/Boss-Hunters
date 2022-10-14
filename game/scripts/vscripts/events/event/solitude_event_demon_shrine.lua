	local function CheckPlayerChoices(self)
	local votedDestroy = 0
	local votedPray = 0
	local votedLeave = 0
	local voted = 0
	local players = 0
	for i = 0, GameRules.BasePlayers do
		if PlayerResource:IsValidPlayerID(i) and PlayerResource:GetPlayer(i) then
			players = players + 1
			if self._playerChoices[i] ~= nil then
				voted = voted + 1
				if self._playerChoices[i] == 1 then
					votedPray = votedPray + 1
				elseif self._playerChoices[i] == 2 then
					votedDestroy = votedDestroy + 1
				else
					votedLeave = votedLeave + 1
				end
			end
		end
	end
	self.atLeastOneVote = voted > 0
	local nonVotes = (players - voted)
	if not self.eventEnded and not self.foughtElites then
		if votedPray > votedLeave + votedDestroy + nonVotes then
			self:StartCombat(false)
		elseif votedDestroy > votedLeave + votedPray + nonVotes then
			self:StartCombat(true)
		elseif votedLeave > votedDestroy + votedPray + nonVotes then
			self:EndEvent(true)
		elseif votedPray >= votedDestroy + nonVotes and voted > nonVotes then -- pray has priority
			self:StartCombat(false)
		elseif votedDestroy >= votedPray + nonVotes and voted > nonVotes then -- fight
			self:StartCombat(true)
		elseif votedLeave > nonVotes then -- most people voted, force leave
			self:EndEvent(true)
		end
	end
	return false
end

local function StartCombat(self, bFight)
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_ended", {})
	CustomGameEventManager:Send_ServerToAllClients( "boss_hunters_update_timer", { game_time = GameRules:GetDOTATime( false, true ) } )
	if bFight then
		self.foughtElites = true
		self.eventType = EVENT_TYPE_ELITE

		self._vEventHandles = {
			ListenToGameEvent( "entity_killed", require("events/base_combat"), self ),
		}
		self:EndEventTimer( )
		self.enemiesToSpawn = math.min( 7, 3 + RoundManager:GetAscensions() )
		Timers:CreateTimer(5, function()
			local enemyType = "npc_dota_boss_warlock_demon"
			if RollPercentage(35) then
				enemyType = "npc_dota_boss_warlock_true_form"
			end
			local spawn = CreateUnitByName(enemyType, RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundNecessary = true
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			if self.enemiesToSpawn > 0 then
				return 20 / (RoundManager:GetRaidsFinished() + 1)
			end
		end)
	else
		for _, hero in ipairs( HeroList:GetRealHeroes() ) do
			if self._playerChoices[hero:GetPlayerOwnerID()] == 1 then
				hero:AddCurse("event_buff_demon_shrine")
			end
		end
		CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_reward_given", {event = self:GetEventName(), reward = 1})
		self:EndEvent(true)
	end
end

local function FirstChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	self._playerChoices[event.pID] = 1
	CheckPlayerChoices(self)
end

local function SecondChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	self._playerChoices[event.pID] = 2
	CheckPlayerChoices(self)
end

local function ThirdChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	self._playerChoices[event.pID] = 3
	CheckPlayerChoices(self)
end

local function StartEvent(self)	
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_started", {event = self:GetEventName(), choices = 3})
	self._vListenerHandles = {
		CustomGameEventManager:RegisterListener('player_selected_event_choice_1', Context_Wrap( self, 'FirstChoice') ),
		CustomGameEventManager:RegisterListener('player_selected_event_choice_2', Context_Wrap( self, 'SecondChoice') ),
		CustomGameEventManager:RegisterListener('player_selected_event_choice_3', Context_Wrap( self, 'ThirdChoice') ),
	}
	self._vEventHandles = {}
	self.eventEnded = false
	self.waitTimer = self:StartEventTimer( 45 ) 
	
	LinkLuaModifier("event_buff_demon_shrine", "events/modifiers/event_buff_demon_shrine", LUA_MODIFIER_MOTION_NONE)
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

function HandoutRewards(self, bWon)
	if self.foughtElites then
		local baseXP = self:GetStandardXPReward()
		local baseGold = self:GetStandardGoldReward()
		if not bWon then
			baseXP = baseXP / 4
			baseGold = baseGold / 4
		end
		
		for _, hero in ipairs( HeroList:GetRealHeroes() ) do
			hero:AddGold( baseGold )
			hero:AddXP( baseXP )
			local pID = hero:GetPlayerOwnerID()
			if bWon then
				RelicManager:RollEliteRelicsForPlayer(pID)
				local relicTable = {}
				table.insert(relicTable, RelicManager:RollRandomRelicForPlayer(pID, "RARITY_COMMON", false, true) )
				table.insert(relicTable, RelicManager:RollRandomRelicForPlayer(pID, "RARITY_COMMON", false, true) )
				table.insert(relicTable, RelicManager:RollRandomRelicForPlayer(pID, "RARITY_COMMON", false, true) )
				RelicManager:PushCustomRelicDropsForPlayer(pID, relicTable)
			end
		end
	end
end

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_boss_warlock_demon", context)
	PrecacheUnitByNameSync("npc_dota_boss_warlock_true_form", context)
	return true
end

local function LoadSpawns(self)
	if not self.spawnLoadCompleted then
		RoundManager.spawnPositions = {}
		RoundManager.boundingBox = "solitude_event_shrine"
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
	["ThirdChoice"] = ThirdChoice,
	["StartCombat"] = StartCombat,
	["HandoutRewards"] = HandoutRewards,
}

return funcs