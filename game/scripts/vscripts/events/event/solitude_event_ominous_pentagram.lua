	local function CheckPlayerChoices(self)
	local votedYes = 0
	local votedVeryYes = 0
	local votedNo = 0
	local voted = 0
	local players = 0
	for i = 0, GameRules.BasePlayers do
		if PlayerResource:IsValidPlayerID(i) and PlayerResource:GetPlayer(i) then
			players = players + 1
			if self._playerChoices[i] ~= nil then
				voted = voted + 1
				if self._playerChoices[i] < 3 then
					votedYes = votedYes + 1
					if self._playerChoices[i] == 1 then votedVeryYes = votedVeryYes + 1 end
				else
					votedNo = votedNo + 1
				end
			end
		end
	end
	
	if not self.eventEnded and not self.foughtAsura then
		if votedYes > votedNo + (players - voted) then -- yes votes exceed non-votes and no votes
			self:StartCombat(true, votedVeryYes > votedYes/2 )
			return true
		elseif votedNo > votedYes + (players - voted) then -- no votes exceed yes and non-votes and every other situation
			self:StartCombat(false)
			return true
		end
	end
	return false
end

local function StartCombat(self, bFight, bHard)
	if bFight then
		self.foughtAsura = true
		self.eventType = EVENT_TYPE_COMBAT
		if bHard then
			self.eventType = EVENT_TYPE_ELITE
			
			for _, hero in ipairs( HeroList:GetRealHeroes() ) do
				hero:ModifyAgility( 15 )
				hero:ModifyIntellect( 15 )
				hero:ModifyStrength( 15 )
			end
		end
		self._vEventHandles = {
			ListenToGameEvent( "entity_killed", require("events/base_combat"), self ),
		}
		self.timeRemaining = 0
		self.enemiesToSpawn = 1
		local START_VECTOR = RoundManager:PickRandomSpawn()
		Timers:CreateTimer(5, function()
			local spawn = CreateUnitByName("npc_dota_boss36_guardian", START_VECTOR, true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundNecessary = true
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			if bHard then
				spawn:SetAverageBaseDamage(spawn:GetAverageBaseDamage() * 1.5, 30)
			end
			if self.enemiesToSpawn > 0 then
				return 15 / (RoundManager:GetRaidsFinished() + 1)
			end
		end)
	else
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
	self.timeRemaining = 15
	self.eventEnded = false
	self.foughtAsura = false
	self.waitTimer = Timers:CreateTimer(1, function()
		CustomGameEventManager:Send_ServerToAllClients("updateQuestPrepTime", {prepTime = self.timeRemaining})
		if not self.eventEnded and not self.foughtAsura then
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
	
	
	self.eventEnded = true
	self.timeRemaining = -1
	Timers:CreateTimer(3, function() RoundManager:EndEvent(bWon) end)
end

function HandoutRewards(self, bWon)
	if self.foughtAsura then
		local eventScaling = RoundManager:GetEventsFinished()
		local raidScaling = 1 + RoundManager:GetRaidsFinished() * 0.2
		local playerScaling = GameRules.BasePlayers - HeroList:GetActiveHeroCount()
		local baseXP = ( 700 + ( (50 + 10 * playerScaling) * eventScaling ) ) * raidScaling
		local baseGold = ( 250 + ( (20 + 3 * playerScaling) * eventScaling ) ) * raidScaling
		if not bWon then
			baseXP = baseXP / 4
			baseGold = baseGold / 4
		end
		if self.touchedPentagram then
			baseXP = baseXP * 3
			baseGold = baseGold * 3
		else
			baseXP = baseXP * 1.5
			baseGold = baseGold * 1.5
		end
		
		for _, hero in ipairs( HeroList:GetRealHeroes() ) do
			hero:AddGold( baseGold )
			hero:AddXP( baseXP )
			local pID = hero:GetPlayerOwnerID()
			if bWon then
				if self.touchedPentagram then
					RelicManager:RollEliteRelicsForPlayer(pID)
				end
				RelicManager:RollBossRelicsForPlayer(pID)
			end
		end
	end
end

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_boss36_guardian", context)
	return true
end

local function LoadSpawns(self)
	if not self.spawnLoadCompleted then
		RoundManager.spawnPositions = {}
		RoundManager.boundingBox = "solitude_asura_boss"
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