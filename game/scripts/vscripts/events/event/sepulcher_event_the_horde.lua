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
	self.eventEnded = true
	self.combatStarted = true
	self.eventType = EVENT_TYPE_COMBAT
	local START_VECTOR = Vector(949, 130)
	
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_ended", {})
	local activeHeroes = HeroList:GetActiveHeroCount()
	self:StartEventTimer( 60 )
	Timers:CreateTimer(1, function()
		if not self.combatEnded then
			if self.timeRemaining >= 0 then
				for _, hero in ipairs( HeroList:GetActiveHeroes() ) do
					hero:MakeVisibleToTeam( DOTA_TEAM_BADGUYS, 5 )
				end
				local roll = RandomInt(1, 12)
				local hp = 150
				if GameRules:GetGameDifficulty() >= 4 then
					hp = 250
				end
				local zombieType = "npc_dota_mini_boss1"
				if roll <= 6 then
					zombieType = "npc_dota_mini_boss1"
				elseif roll <= 10 then
					zombieType = "npc_dota_boss3a_b"
					hp = 200
					if GameRules:GetGameDifficulty() >= 4 then
						hp = 325
					end
				elseif roll == 12 then
					zombieType = "npc_dota_boss3b"
					hp = 175
					if GameRules:GetGameDifficulty() >= 4 then
						hp = 275
					end
				end
				local zombie = CreateUnitByName(zombieType, RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
				zombie:SetCoreHealth(hp)
				zombie:SetBaseMoveSpeed( zombie:GetBaseMoveSpeed() * (1 + (GameRules:GetGameDifficulty()/10)*2 ) )
				zombie:SetAverageBaseDamage( (roll + 20) * 10, 25 )
				return math.max( 1.5, (self.timeRemaining or 60) / 15 ) / HeroList:GetActiveHeroCount()
			end
		end
	end)
end

local function OnEntityKilled(self, event)
	local killedTarget = EntIndexToHScript(event.entindex_killed)
	local ROUND_END_DELAY = 3
	if killedTarget:IsRealHero() then
		if not killedTarget:NotDead() then
			killedTarget:CreateTombstone()
		end
		Timers:CreateTimer( ROUND_END_DELAY, function()
			if RoundManager:EvaluateLoss() then
				self:EndEvent(false)
			end
		end)
	end
end

local function StartEvent(self)
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_started", {event = "sepulcher_event_the_horde", choices = 1})
	self._vListenerHandles = {
		CustomGameEventManager:RegisterListener('player_selected_event_choice_1', Context_Wrap( self, 'FirstChoice') ),
	}
	self._vEventHandles = {
		ListenToGameEvent( "entity_killed", OnEntityKilled, self ),
	}
	self.eventEnded = false
	self.combatStarted = false
	self.combatEnded = false
	self._playerChoices = {}
	local timerFunc = (function()
		if not self.combatStarted then
			if self.timeRemaining >= 0 then
				self.timeRemaining = self.timeRemaining - 1
				return 1
			else
				self:StartCombat(true)
			end
		end
	end)
	self:StartEventTimer( 10, timerFunc )
end

local function EndEvent(self, bWon)
	for _, eID in pairs( self._vListenerHandles ) do
		CustomGameEventManager:UnregisterListener( eID )
	end
	for _, eID in pairs( self._vEventHandles ) do
		StopListeningToGameEvent( eID )
	end
	self.eventEnded = true
	self.combatEnded = true
	self.timeRemaining = -1
	
	if bWon then
		CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_reward_given", {event = "sepulcher_event_the_horde", reward = 1})
		for _, hero in ipairs( HeroList:GetRealHeroes() ) do
			hero:ModifyAgility( 10 )
			hero:ModifyIntellect( 10 )
			hero:ModifyStrength( 10 )
		end
	end
	Timers:CreateTimer(3, function() RoundManager:EndEvent(bWon) end)
end

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_mini_boss1", context)
	PrecacheUnitByNameSync("npc_dota_boss3a_b", context)
	PrecacheUnitByNameSync("npc_dota_boss3b", context)
	PrecacheUnitByNameSync("npc_dota_boss3a", context)
	return true
end

local function LoadSpawns(self)
	if not self.spawnLoadCompleted then
		RoundManager.spawnPositions = {}
		RoundManager.boundingBox = "sepulcher_event_cursed_cemetary"
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
	["StartCombat"] = StartCombat,
	["HandoutRewards"] = HandoutRewards,
	["OnEntityKilled"] = OnEntityKilled,
}

return funcs