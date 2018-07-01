local function CheckPlayerChoices(self)
	for pID, choice in pairs( self._playerChoices ) do
		if not choice then
			return false
		end
	end
	if not self.eventEnded then
		self:StartCombat(true)
	end
	return true
end

local function FirstChoice(self, userid, event)
	self._playerChoices[event.pID] = true
	CheckPlayerChoices(self)
end

local function StartCombat(self)
	self.eventEnded = true
	self.combatEnded = false
	local START_VECTOR = Vector(949, 130)
	
	self.timeRemaining = 60
	
	self.totemUnit = CreateUnitByName("npc_dota_event_totem", START_VECTOR, true, nil, nil, DOTA_TEAM_GOODGUYS)
	local ability = self.totemUnit:AddAbility("generic_hp_limiter")
	ability:SetLevel(1)
	self.totemUnit:AddNewModifier(self.totemUnit, ability, "modifier_generic_hp_limiter", {})
	self.totemUnit:SetThreat(5000)
	
	local activeHeroes = HeroList:GetActiveHeroCount()
	
	Timers:CreateTimer(1, function()
		CustomGameEventManager:Send_ServerToAllClients("updateQuestPrepTime", {prepTime = self.timeRemaining})
		if not self.combatEnded then
			if self.timeRemaining >= 0 then
				self.timeRemaining = self.timeRemaining - 1
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
				local spawns = 1 + math.floor( (60 - self.timeRemaining)/15 )
				for i = 1, spawns do
					local zombie = CreateUnitByName("npc_dota_mini_boss1", START_VECTOR + ActualRandomVector(1500, 900), true, nil, nil, DOTA_TEAM_BADGUYS)
					local hp = zombie:GetBaseMaxHealth() * (activeHeroes / 2) * 1.2
					zombie:SetBaseMaxHealth( hp )
					zombie:SetMaxHealth( hp )
					zombie:SetHealth( hp )
				end
				
				return 3
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
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_started", {event = "generic_event_protect", choices = 1})
	self._vListenerHandles = {
		CustomGameEventManager:RegisterListener('player_selected_event_choice_1', Context_Wrap( self, 'FirstChoice') ),
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
				CheckPlayerChoices(self)
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
	
	
	local reward = 2
	if not self.totemUnit:IsNull() and self.totemUnit:IsAlive() then
		for _, hero in ipairs( HeroList:GetRealHeroes() ) do
			hero.bonusAbilityPoints = (hero.bonusAbilityPoints or 0) + 2
			hero:SetAbilityPoints( hero:GetAbilityPoints() + 2)
			CustomGameEventManager:Send_ServerToAllClients("dota_player_upgraded_stats", {playerID = hero:GetPlayerID()} )
		end
		reward = 1
	end
	
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_reward_given", {event = "generic_event_protect", reward = reward})
	
	Timers:CreateTimer(3, function() RoundManager:EndEvent(true) end)
end

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_mini_boss1", context)
	return true
end

local function HandoutRewards(self)
	return false
end

local funcs = {
	["StartEvent"] = StartEvent,
	["EndEvent"] = EndEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["FirstChoice"] = FirstChoice,
	["StartCombat"] = StartCombat,
	["HandoutRewards"] = HandoutRewards,
}

return funcs