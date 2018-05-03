if StatsScreen == nil then
  print ( 'creating skill selection manager' )
  StatsScreen = {}
  StatsScreen.__index = StatsScreen
end

function StatsScreen:new( o )
  o = o or {}
  setmetatable( o, StatsScreen )
  return o
end

function StatsScreen:StartStatsScreen()
	StatsScreen = self
	CustomGameEventManager:RegisterListener('send_player_upgraded_stats', Context_Wrap( StatsScreen, 'ProcessStatsUpgrade'))
	CustomGameEventManager:RegisterListener('send_player_selected_talent', Context_Wrap( StatsScreen, 'ProcessTalents'))
	CustomGameEventManager:RegisterListener('notify_selected_talent', Context_Wrap( StatsScreen, 'NotifyTalent'))
	CustomGameEventManager:RegisterListener('send_player_respec_talents', Context_Wrap( StatsScreen, 'RespecAll'))
	self.ms = {0,25,50,75,100,150}
	self.mp = {0,3,6,9,12,18}
	self.mpr = {0,3,6,9,12,18}
	self.ha = {0,20,40,60,80,120}
	
	self.ad = {0,35,70,105,140,200}
	self.sa = {0,15,30,45,60,90}
	self.cdr = {0,5,10,15,20,30}
	self.as = {0,35,70,105,140,200}
	self.sta = {0,5,10,15,20,30}
	
	self.pr = {0,5,10,15,20,30}
	self.mr = {0,6,12,18,24,35}
	self.db = {0,20,40,60,80,120}
	self.ar = {0,100,200,300,400,600}
	self.hp = {0,2,4,6,8,12}
	self.hpr = {0,5,10,15,20,30}
	self.sr = {0,5,10,15,20,30}
	
	self.all = {2}
end

function StatsScreen:IsPlayerRegistered(hero)
	return hero.statsHaveBeenRegistered or false
end

function StatsScreen:RegisterPlayer(hero, bRespec)
	local stats = {}
	stats.ms = 0
	stats.mp = 0
	stats.mpr = 0
	stats.ha = 0
	
	stats.ad = 0
	stats.sa = 0
	stats.cdr = 0
	stats.as = 0
	stats.sta = 0
	
	stats.pr = 0
	stats.mr = 0
	stats.db = 0
	stats.ar = 0
	stats.hp = 0
	stats.hpr = 0
	stats.sr = 0
	
	stats.all = 0
	
	stats.respec = bRespec or false
	hero.hasRespecced = bRespec or false

	CustomNetTables:SetTableValue( "stats_panel", tostring(hero:entindex()), stats)
	CustomNetTables:SetTableValue( "talents", tostring(hero:entindex()), {} )
	CustomGameEventManager:Send_ServerToAllClients("dota_player_upgraded_stats", {playerID = hero:GetPlayerID()} )
	
	hero.statsHaveBeenRegistered = true
	hero.talentsSkilled = 0
end

function StatsScreen:ProcessStatsUpgrade(userid, event)
	local pID = event.pID
	local entindex = event.entindex
	local skill = tostring(event.skill)
	local hero = EntIndexToHScript( entindex )

	if entindex ~= PlayerResource:GetSelectedHeroEntity( pID ):entindex() then return end -- calling
	local netTable = CustomNetTables:GetTableValue("stats_panel", tostring(entindex))
	if (not (netTable[skill] and self[skill]) and hero:GetAbilityPoints() > 0) or (hero:GetLevel() < ((netTable[skill]) + 1)*7 and not skill == "all") then return end -- max level
	netTable[skill] = tostring(tonumber(netTable[skill]) + 1)
	CustomNetTables:SetTableValue("stats_panel", tostring(entindex), netTable)
	hero:SetAbilityPoints( math.max(0, hero:GetAbilityPoints() - 1) )
	
	hero:CalculateStatBonus()
	CustomGameEventManager:Send_ServerToAllClients("dota_player_upgraded_stats", {playerID = pID} )
end

function StatsScreen:ProcessTalents(userid, event)
	local pID = event.pID
	local entindex = event.entindex
	local talent = tostring(event.talent)
	local hero = EntIndexToHScript( entindex )
	if entindex ~= PlayerResource:GetSelectedHeroEntity( pID ):entindex() or not hero:FindAbilityByName(talent) or hero:GetLevel() < (hero.talentsSkilled + 1) * 10 then return end -- calling
	if hero:FindAbilityByName(talent):GetLevel() > 0 then return end
	hero:UpgradeAbility(hero:FindAbilityByName(talent))
	hero:CalculateStatBonus()
	CustomGameEventManager:Send_ServerToAllClients("dota_player_upgraded_stats", {playerID = pID} )
	hero.talentsSkilled = hero.talentsSkilled + 1
end

function StatsScreen:NotifyTalent(userid, event)
	local player = PlayerResource:GetPlayer(event.pID)
	player.notifyTalentDelayTimer = player.notifyTalentDelayTimer or 0
	if GameRules:GetGameTime() > player.notifyTalentDelayTimer + 1 then
		Say(player, event.text, true)
		player.notifyTalentDelayTimer = GameRules:GetGameTime()
	end
end

function StatsScreen:RespecAll(userid, event)
	local pID = event.pID
	local entindex = event.entindex
	local hero = EntIndexToHScript( entindex )
	if hero and not hero.hasRespecced then
		self:RegisterPlayer(hero, true) -- Reset stats screen
		local modifiers = hero:FindAllModifiers()
		for i = 0, 23 do
			local ability = hero:GetAbilityByIndex(i)
			if ability and not ability:IsInnateAbility() then 
				ability:SetLevel(0)
			end
		end
		for _, modifier in ipairs( modifiers ) do
			if modifier:GetAbility() and not modifier:GetAbility():IsInnateAbility() and modifier:GetCaster() == hero then -- destroy passive modifiers and any buffs
				modifier:Destroy()
			end
		end
		hero:SetAbilityPoints( hero:GetLevel() + math.floor(hero:GetLevel() / GameRules.gameDifficulty) ) -- give back ability points
		CustomGameEventManager:Send_ServerToAllClients("dota_player_upgraded_stats", {playerID = hero:GetPlayerID()} )
	end
end