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
	self.queryListener = CustomGameEventManager:RegisterListener('send_player_upgraded_stats', Context_Wrap( StatsScreen, 'ProcessStatsUpgrade'))
	self.ms = {0,15,20,25,30,35,40,45,50,55,60}
	self.mp = {0,250,500,750,1000,1250,1500,1750,2000,2250,2500}
	self.mpr = {0,0.1,0.2,0.3,0.4,0.5}
	self.ha = {0,10,20,30,40,50}
	
	self.ad = {0,10,20,30,40,50,60,70,80,90,100}
	self.sa = {0,10,15,20,25,30,35,40,45,50,55}
	self.cdr = {0,10,15,20,25}
	self.as = {0,25,50,75,100,125,150,175,200,225,250}
	self.sta = {0,10,15,20,25}
	
	self.pr = {0,2,4,6,8,10,12,14,16,18,20}
	self.mr = {0,5,10,15,20,25,30,35,40,45,50}
	self.db = {0,20,25,30,35,40,45,50,55,60,65}
	self.ar = {0,50,100,150,200,250,300,350,400,450,500}
	self.hp = {0,250,500,750,1000,1250,1500,1750,2000,2250,2500}
	self.hpr = {0,0.1,0.2,0.3,0.4,0.5}
	self.sr = {0,10,15,20,25}
end

function StatsScreen:RegisterPlayer(hero)
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
	
	CustomNetTables:SetTableValue("stats_panel", tostring(hero:entindex()), stats)
end

function StatsScreen:ProcessStatsUpgrade(userid, event)
	local pID = event.pID
	local entindex = event.entindex
	local skill = tostring(event.skill)
	local hero = EntIndexToHScript( entindex )
	if entindex ~= PlayerResource:GetSelectedHeroEntity( pID ):entindex() then return end -- calling
	local netTable = CustomNetTables:GetTableValue("stats_panel", tostring(entindex))
	if not (netTable[skill] and self[skill]) and hero:GetAbilityPoints() > 0 then return end -- max level
	netTable[skill] = tostring(tonumber(netTable[skill]) + 1)
	CustomNetTables:SetTableValue("stats_panel", tostring(entindex), netTable)
	hero:SetAbilityPoints( math.max(0, hero:GetAbilityPoints() - 1) )
	hero:FindModifierByName("modifier_stats_system_handler"):UpdateStatValues()
	hero:CalculateStatBonus()
	CustomGameEventManager:Send_ServerToAllClients("dota_player_upgraded_stats", {playerID = pID} )

end