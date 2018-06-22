local function CheckPlayerChoices(self)
	local votedYes = 0
	local votedNo = 0
	local voted = 0
	local players = 0
	for i = 0, GameRules.BasePlayers do
		if PlayerResource:IsValidPlayerID(i) and PlayerResource:GetPlayer(i) then
			players = players + 1
			if self._playerChoices[i] ~= nil then
				voted = voted + 1
				if self._playerChoices[i] then
					votedYes = votedYes + 1
				else
					votedNo = votedNo + 1
				end
			end
		end
	end
	
	if not self.eventEnded then
		if votedYes > votedNo + (players - voted) then -- yes votes exceed non-votes and no votes
			self:StartCombat(true)
			return true
		elseif votedNo > votedYes + (players - voted) then -- no votes exceed yes and non-votes and every other situation
			self:StartCombat(false)
			return true
		end
	end
	return false
end

local function FirstChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	self._playerChoices[event.pID] = true
	CheckPlayerChoices(self)
end

local function SecondChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	self._playerChoices[event.pID] = false
	CheckPlayerChoices(self)
end

local function StartCombat(self)
	self.eventEnded = true
	self.combatEnded = false
	self.foughtWave = true
	local START_VECTOR = Vector(949, 130)
	
	self.timeRemaining = 60
	
	self.totemUnit = CreateUnitByName("npc_dota_event_totem", START_VECTOR, true, nil, nil, DOTA_TEAM_GOODGUYS)
	local ability = self.totemUnit:AddAbility("generic_hp_limiter")
	ability:SetLevel(1)
	self.totemUnit:AddNewModifier(self.totemUnit, ability, "modifier_generic_hp_limiter", {})
	self.totemUnit:SetThreat(5000)
	self.totemUnit:SetOriginalModel("models/props_structures/dire_tower002.vmdl")
	self.totemUnit:SetModel("models/props_structures/dire_tower002.vmdl")
	
	local activeHeroes = HeroList:GetActiveHeroCount()
	
	Timers:CreateTimer(1, function()
		CustomGameEventManager:Send_ServerToAllClients("updateQuestPrepTime", {prepTime = self.timeRemaining})
		if not self.combatEnded then
			if self.timeRemaining >= 0 then
				self.timeRemaining = self.timeRemaining - 1
				local spawns = 1 + math.floor( (60 - self.timeRemaining)/15 )
				for i = 1, spawns do
					local zombieType = "npc_dota_mini_boss1"
					if RollPercentage(20) then
						zombieType = "npc_dota_boss3a_b"
					end
					local zombie = CreateUnitByName(zombieType, START_VECTOR + ActualRandomVector(1500, 900), true, nil, nil, DOTA_TEAM_BADGUYS)
					local hp = zombie:GetBaseMaxHealth() * math.ceil( 1 + math.log(activeHeroes) )
					zombie:SetBaseMaxHealth( hp )
					zombie:SetMaxHealth( hp )
					zombie:SetHealth( hp )
				end
				
				return 5
			else
				self:EndEvent(true)
			end
		end
	end)
end

local function OnEntityKilled(self, event)
	local killedTarget = EntIndexToHScript(event.entindex_killed)
	local ROUND_END_DELAY = 3
	if killedTarget == self.totemUnit then
		self:EndEvent(true)
	elseif killedTarget:IsRealHero() then
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
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_started", {event = "sepulcher_event_tombstone", choices = 2})
	self._vListenerHandles = {
		CustomGameEventManager:RegisterListener('player_selected_event_choice_1', Context_Wrap( self, 'FirstChoice') ),
		CustomGameEventManager:RegisterListener('player_selected_event_choice_2', Context_Wrap( self, 'SecondChoice') ),
	}
	self._vEventHandles = {
		ListenToGameEvent( "entity_killed", OnEntityKilled, self ),
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
				self:EndEvent(true)
			end
		end
	end)
	
	self._playerChoices = {}
	for i = 0, GameRules.BasePlayers do
		if PlayerResource:IsValidPlayerID(i) and PlayerResource:GetPlayer(i) then
			self._playerChoices[i] = false
		end
	end
	LinkLuaModifier("event_buff_protect", "events/modifiers/event_buff_protect", LUA_MODIFIER_MOTION_NONE)
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
	
	
	local reward = 3
	if self.totemUnit and not self.totemUnit:IsNull() and self.totemUnit:IsAlive() then
		for _, hero in ipairs( HeroList:GetRealHeroes() ) do
			hero:AddNewModifier(hero, nil, "event_buff_tombstone", {})
		end
		reward = 2
		if self.totemUnit:GetHealth() == self.totemUnit:GetMaxHealth() then
			GameRules._lives = GameRules._lives + 1
			GameRules._maxLives = GameRules._maxLives + 1
			CustomGameEventManager:Send_ServerToAllClients( "updateQuestLife", { lives = GameRules._lives, maxLives = GameRules._maxLives } )
			reward = 1
		end
	end
	if self.totemUnit then
		CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_reward_given", {event = "sepulcher_event_tombstone", reward = reward})
	end
	
	Timers:CreateTimer(3, function() RoundManager:EndEvent(true) end)
end

local function PrecacheUnits(self)
	return true
end

local function HandoutRewards(self)
	if self.foughtWave then
		local eventScaling = RoundManager:GetEventsFinished()
		local playerScaling = GameRules.BasePlayers - HeroList:GetActiveHeroCount()
		local baseXP = 500 + eventScaling * (100 + 10 * playerScaling)
		local baseGold = 100 + eventScaling * (25 + 3 * playerScaling)
		for _, hero in ipairs( HeroList:GetRealHeroes() ) do
			hero:AddGold( baseGold )
			hero:AddExperience( baseXP, DOTA_ModifyXP_Unspecified, false, false )
		end
	end
end

local funcs = {
	["StartEvent"] = StartEvent,
	["EndEvent"] = EndEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["FirstChoice"] = FirstChoice,
	["SecondChoice"] = SecondChoice,
	["StartCombat"] = StartCombat,
	["HandoutRewards"] = HandoutRewards,
}

return funcs