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
	self.atLeastOneVote = voted > 0
	if not self.eventEnded then
		if votedYes > votedNo + (players - voted) then -- yes votes exceed non-votes and no votes
			self:StartCombat(true)
			return true
		elseif votedNo > votedYes + (players - voted) then -- no votes exceed yes and non-votes and every other situation
			self:EndEvent(true)
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
	self._playerChoices = nil
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_ended", {})
	self.eventType = EVENT_TYPE_COMBAT
	
	self.totemUnit = CreateUnitByName("npc_dota_event_totem", RoundManager:GetHeroSpawnPosition(), true, nil, nil, DOTA_TEAM_GOODGUYS)
	self.totemUnit:SetThreat(5000)
	self.totemUnit:SetOriginalModel("models/props_structures/dire_tower002.vmdl")
	self.totemUnit:SetModel("models/props_structures/dire_tower002.vmdl")
	
	local activeHeroes = HeroList:GetActiveHeroCount()
	self:StartEventTimer( 60 )
	AddFOWViewer(DOTA_TEAM_BADGUYS, self.totemUnit:GetAbsOrigin(), 312, self.timeRemaining, false)
	
	Timers:CreateTimer(1, function()
		if not self.totemUnit or self.totemUnit:IsNull() then return end
		if self.totemUnit:IsAlive() then self.totemUnit:SetThreat(5000) end
		if not self.combatEnded then
			if self.timeRemaining >= 0 then
				local spawns = 1 + math.floor( (60 - self.timeRemaining)/15 )
				for i = 1, spawns do
					local zombieType = "npc_dota_mini_boss1"
					if RollPercentage(8) then
						zombieType = "npc_dota_boss3a_b"
					end
					local zombie = CreateUnitByName(zombieType, RoundManager:PickRandomSpawn() + RandomVector(75), true, nil, nil, DOTA_TEAM_BADGUYS)
					local hp = zombie:GetBaseMaxHealth() * math.ceil( 1 + math.log(activeHeroes) )
					zombie:SetBaseMaxHealth( hp )
					zombie:SetMaxHealth( hp )
					zombie:SetHealth( hp )
				end
				
				return 5
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
	self:StartEventTimer()
	
	self._playerChoices = {}
	LinkLuaModifier("event_buff_tombstone", "events/modifiers/event_buff_tombstone", LUA_MODIFIER_MOTION_NONE)
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
	
	if self.foughtWave then
		local reward = 3
		if self.totemUnit and not self.totemUnit:IsNull() and self.totemUnit:IsAlive() then
			for _, hero in ipairs( HeroList:GetRealHeroes() ) do
				hero:AddBlessing("event_buff_tombstone")
				hero:ModifyLives(1)
			end
			reward = 2
			if self.totemUnit:GetHealth() == self.totemUnit:GetMaxHealth() then
				reward = 1
			end
			self.totemUnit:ForceKill(false)
		end
		CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_reward_given", {event = "sepulcher_event_tombstone", reward = reward})
	end
	Timers:CreateTimer(0.5, function() RoundManager:EndEvent(true) end)
end

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_event_totem", context)
	PrecacheModel("models/props_structures/dire_tower002.vmdl", context)
	PrecacheUnitByNameSync("npc_dota_boss3a_b", context)
	PrecacheUnitByNameSync("npc_dota_mini_boss1", context)
	return true
end

local function HandoutRewards(self)
	if self.foughtWave then
		local baseXP = self:GetStandardXPReward()
		local baseGold = self:GetStandardGoldReward()
		for _, hero in ipairs( HeroList:GetRealHeroes() ) do
			hero:AddGold( baseGold )
			hero:AddXP( baseXP )
		end
	end
end

local function LoadSpawns(self)
	if not self.spawnLoadCompleted then
		RoundManager.spawnPositions = {}
		RoundManager.boundingBox = "grove_event_tombstone"
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
	["StartCombat"] = StartCombat,
	["HandoutRewards"] = HandoutRewards,
}

return funcs