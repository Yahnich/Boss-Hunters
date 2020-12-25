	local function CheckPlayerChoices(self)
	local votedRead = 0
	local votedDestroy = 0
	local votedLeave = 0
	local votes = 0
	local players = 0
	for i = 0, GameRules.BasePlayers do
		if PlayerResource:IsValidPlayerID(i) and PlayerResource:GetPlayer(i) then
			players = players + 1
			if self._playerChoices[i] ~= nil then
				votes = votes + 1
				if self._playerChoices[i] == 1 then
					votedRead = votedRead + 1
				elseif self._playerChoices[i] == 2 then
					votedDestroy = votedDestroy + 1
				else
					votedLeave = votedLeave + 1
				end
			end
		end
	end
	local nonVotes = (players - votes)
	if not self.foughtElites then
		if votedRead > votedLeave + votedDestroy + nonVotes then
			self:StartCombat(false)
		elseif votedDestroy > votedLeave + votedRead + nonVotes then
			self:StartCombat(true)
		elseif votedLeave > votedDestroy + votedRead + nonVotes then
			self:EndEvent(true)
		elseif votedRead >= votedDestroy + nonVotes and votes > nonVotes then -- pray has priority
			self:StartCombat(false)
		elseif votedDestroy >= votedRead + nonVotes and votes > nonVotes then -- fight
			self:StartCombat(true)
		elseif votedLeave > nonVotes then -- most people voted, force leave
			self:EndEvent(true)
		end
	end
	return false
end

local function StartCombat(self, bFight)
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_ended", {})
	if bFight then
		self.foughtElites = true
		self.eventType = EVENT_TYPE_ELITE
		self.eventRewardType = EVENT_REWARD_RELIC

		self._vEventHandles = {
			ListenToGameEvent( "entity_killed", require("events/base_combat"), self ),
		}
		self.timeRemaining = 0
		self.bossesToSpawn = 1
		self.mobsToSpawn = math.ceil(RoundManager:GetRaidsFinished() / 2)
		self.enemiesToSpawn = self.bossesToSpawn + self.mobsToSpawn
		Timers:CreateTimer(5, function()
			local spawn = CreateUnitByName("npc_dota_boss34", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundNecessary = true
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			self.bossesToSpawn = self.bossesToSpawn - 1
			if self.bossesToSpawn > 0 then
				return 60 / (RoundManager:GetRaidsFinished() + 1)
			end
		end)
		Timers:CreateTimer(12, function()
			local spawn = CreateUnitByName("npc_dota_boss22", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn:SetCoreHealth( spawn:GetBaseMaxHealth() / 2 )
			spawn:FindAbilityByName("boss15_peel_the_veil"):SetActivated(false)
			spawn.unitIsRoundNecessary = true
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			self.mobsToSpawn = self.mobsToSpawn - 1
			if self.mobsToSpawn > 0 then
				return 40 / (RoundManager:GetRaidsFinished() + 1)
			end
		end)
	else
		for _, hero in ipairs( HeroList:GetRealHeroes() ) do
			hero:AddBlessing("event_buff_ominous_tome_blessing")
			hero:ModifyBonusMaxLives(1)
			hero:ModifyLives(1)
			hero:AddCurse("event_buff_ominous_tome_curse")
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
	self.foughtElites = false
	local timerFunc = (function()
		CustomGameEventManager:Send_ServerToAllClients("updateQuestPrepTime", {prepTime = self.timeRemaining})
		if not self.eventEnded and not self.foughtElites then
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
	self.waitTimer = self:StartEventTimer( 30, timerFunc )
	LinkLuaModifier("event_buff_ominous_tome_blessing", "events/modifiers/event_buff_ominous_tome", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("event_buff_ominous_tome_curse", "events/modifiers/event_buff_ominous_tome", LUA_MODIFIER_MOTION_NONE)
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
	PrecacheUnitByNameSync("npc_dota_boss31", context)
	PrecacheUnitByNameSync("npc_dota_boss32", context)
	return true
end

local function LoadSpawns(self)
	if not self.spawnLoadCompleted then
		RoundManager.spawnPositions = {}
		RoundManager.boundingBox = "grove_boss_green_dragon"
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