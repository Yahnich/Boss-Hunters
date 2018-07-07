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
	self.combatStarted = true
	self.eventType = EVENT_TYPE_COMBAT
	local START_VECTOR = Vector(949, 130)
	
	self.timeRemaining = 60
	
	local activeHeroes = HeroList:GetActiveHeroCount()
	Timers:CreateTimer(function()
		CustomGameEventManager:Send_ServerToAllClients("updateQuestPrepTime", {prepTime = self.timeRemaining})
		self.timeRemaining = self.timeRemaining - 1
		if not self.combatEnded then
			if self.timeRemaining >= 0 then
				return 1
			else
				self:EndEvent(true)
			end
		end
	end)
	Timers:CreateTimer(1, function()
		CustomGameEventManager:Send_ServerToAllClients("updateQuestPrepTime", {prepTime = self.timeRemaining})
		if not self.combatEnded then
			if self.timeRemaining >= 0 then
				for _, hero in ipairs( HeroList:GetActiveHeroes() ) do
					local roll = RandomInt(1, 12)
					local zombieType = "npc_dota_mini_boss1"
					if roll <= 6 then
						zombieType = "npc_dota_mini_boss1"
					elseif roll <= 10 then
						zombieType = "npc_dota_boss3a_b"
					elseif roll == 12 then
						zombieType = "npc_dota_boss3b"
					end
					local zombie = CreateUnitByName(zombieType, hero:GetAbsOrigin() + ActualRandomVector(1200, 600), true, nil, nil, DOTA_TEAM_BADGUYS)
					zombie:SetBaseMaxHealth(75 * GameRules:GetGameDifficulty())
					zombie:SetMaxHealth(75 * GameRules:GetGameDifficulty())
					zombie:SetHealth(75 * GameRules:GetGameDifficulty())
				end
					
				return math.max( 2, (self.timeRemaining or 60) / 15 )
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

	self.timeRemaining = 10
	self.eventEnded = false
	self.combatStarted = false
	self._playerChoices = {}
	Timers:CreateTimer(1, function()
		CustomGameEventManager:Send_ServerToAllClients("updateQuestPrepTime", {prepTime = self.timeRemaining})
		if not self.combatStarted then
			if self.timeRemaining >= 0 then
				self.timeRemaining = self.timeRemaining - 1
				return 1
			else
				self:StartCombat(true)
			end
		end
	end)
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

local funcs = {
	["StartEvent"] = StartEvent,
	["EndEvent"] = EndEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["FirstChoice"] = FirstChoice,
	["StartCombat"] = StartCombat,
	["HandoutRewards"] = HandoutRewards,
	["OnEntityKilled"] = OnEntityKilled,
}

return funcs