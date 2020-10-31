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
	local START_VECTOR = Vector(949, 130)
	
	self.timeRemaining = 60
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_ended", {})
	self.eventType = EVENT_TYPE_COMBAT
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
				local roll = RandomInt(1, 13)
				local demonType = "npc_dota_minion5"
				if roll == 10 then
					demonType = "npc_dota_boss33_a"
				elseif roll == 11 then
					demonType = "npc_dota_boss33_b"
				elseif roll == 12 then
					demonType = "npc_dota_boss_sloth_demon"
				end
				for _, hero in ipairs( HeroList:GetActiveHeroes() ) do
					hero:MakeVisibleToTeam( DOTA_TEAM_BADGUYS, 2.5 )
				end
				local demon = CreateUnitByName(demonType, RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
				if demon then
					demon:SetAverageBaseDamage( math.min(7, roll) * 20, 35 )
					if demonType ~= "npc_dota_minion5" then
						demon:SetCoreHealth(325)
					else
						demon:SetCoreHealth(175)
					end
					demon:SetModelScale(1)
				end
				return math.max( 4, (self.timeRemaining or 60) / 15 ) / HeroList:GetActiveHeroCount()
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
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_started", {event = self:GetEventName(), choices = 1})
	self._vListenerHandles = {
		CustomGameEventManager:RegisterListener('player_selected_event_choice_1', Context_Wrap( self, 'FirstChoice') ),
	}
	self._vEventHandles = {
		ListenToGameEvent( "entity_killed", OnEntityKilled, self ),
	}
	self.timeRemaining = 10
	self.eventEnded = false
	self.combatStarted = false
	self.combatEnded = false
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
	LinkLuaModifier("event_buff_demonic_horde", "events/modifiers/event_buff_demonic_horde", LUA_MODIFIER_MOTION_NONE)
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
		CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_reward_given", {event = self:GetEventName(), reward = 1})
		for _, hero in ipairs( HeroList:GetRealHeroes() ) do
			hero:AddBlessing("event_buff_demonic_horde")
		end
	end
	Timers:CreateTimer(3, function() RoundManager:EndEvent(bWon) end)
end

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_boss_sloth_demon", context)
	PrecacheUnitByNameSync("npc_dota_boss33_a", context)
	PrecacheUnitByNameSync("npc_dota_boss33_b", context)
	PrecacheUnitByNameSync("npc_dota_minion5", context)
	return true
end


local funcs = {
	["StartEvent"] = StartEvent,
	["EndEvent"] = EndEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["FirstChoice"] = FirstChoice,
	["StartCombat"] = StartCombat,
	["OnEntityKilled"] = OnEntityKilled,
}

return funcs