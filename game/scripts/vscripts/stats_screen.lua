if StatsScreen == nil then
	print ( 'creating skill selection manager' )
	StatsScreen = {}
	StatsScreen.__index = StatsScreen
	LinkLuaModifier( "modifier_stats_system_handler", "libraries/modifiers/modifier_stats_system_handler.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier( "modifier_cooldown_reduction_handler", "libraries/modifiers/modifier_cooldown_reduction_handler.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier( "modifier_base_attack_time_handler", "libraries/modifiers/modifier_base_attack_time_handler.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier( "modifier_accuracy_handler", "libraries/modifiers/modifier_accuracy_handler.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier( "modifier_hp_pct_handler", "libraries/modifiers/modifier_hp_pct_handler.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier( "modifier_mana_regen_throttle", "libraries/modifiers/modifier_mana_regen_throttle.lua", LUA_MODIFIER_MOTION_NONE)
	
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
	
	self.ms = {0,10,20,30,40,60,70,80,90,100,120}
	self.mp = {0,300,600,900,1200,1800,2100,2400,2700,3000,3600}
	self.mpr = {0,3,6,9,12,18,21,24,27,30,40}
	self.ha = {0,10,20,30,40,60,70,80,90,100,120}
	
	self.ad = {0,20,40,60,80,120,140,160,180,200,240}
	self.sa = {0,12,24,36,48,60,72,84,96,108,120}
	self.cdr = {0,4,8,12,16,24,28,32,36,40,48}
	self.as = {0,15,30,45,60,90,105,120,135,150,180}
	self.sta = {0,4,8,12,16,24,28,32,36,40,48}
	self.acc = {0,10,15,20,25,35,40,45,50,55,65}
	
	self.pr = {0,2,4,6,8,12,14,16,18,20,24}
	self.mr = {0,4,8,12,16,24,28,32,36,40,48}
	self.arm = {0,25,50,75,100,150,175,200,225,250,300}
	self.ar = {0,50,100,150,200,300,350,400,450,500,600}
	self.hp = {0,250,500,750,1000,1500,1750,2000,2250,2500,3000}
	self.hpr = {0,5,10,15,20,30,35,40,45,50,60}
	self.sr = {0,5,10,15,20,30,35,40,45,50,60}
	
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
	stats.acc = 0
	
	stats.pr = 0
	stats.mr = 0
	stats.ar = 0
	stats.hp = 0
	stats.hpr = 0
	stats.sr = 0
	
	stats.all = 0
	
	stats.respec = bRespec or false
	hero.hasRespecced = bRespec or false

	CustomNetTables:SetTableValue( "stats_panel", tostring(hero:entindex()), stats)
	print( "registering player" )
	stats = nil
	CustomNetTables:SetTableValue( "talents", tostring(hero:entindex()), {} )
	CustomGameEventManager:Send_ServerToAllClients("dota_player_upgraded_stats", {playerID = hero:GetPlayerID()} )
	
	hero.statsHaveBeenRegistered = true
	hero.talentsSkilled = 0
	
	hero:AddNewModifier(hero, nil, "modifier_stats_system_handler", {})
	hero:AddNewModifier(hero, nil, "modifier_cooldown_reduction_handler", {})
	hero:AddNewModifier(hero, nil, "modifier_base_attack_time_handler", {})
	hero:AddNewModifier(hero, nil, "modifier_accuracy_handler", {})
	hero:AddNewModifier(hero, nil, "modifier_mana_regen_throttle", {})
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
	hero:FindModifierByName("modifier_stats_system_handler"):IncrementStackCount()
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
			if modifier:GetAbility() then
				if not modifier:GetAbility():IsInnateAbility() and modifier:GetCaster() == hero and not modifier:GetAbility():IsItem() and modifier:GetAbility():GetName() ~= "item_relic_handler" then -- destroy passive modifiers and any buffs
					modifier:Destroy()
				end
			end
		end
		hero:CalculateStatBonus()
		hero.bonusAbilityPoints = hero.bonusAbilityPoints or 0
		hero:SetAbilityPoints( hero:GetLevel() + math.floor(hero:GetLevel() / GameRules.gameDifficulty) + hero.bonusAbilityPoints) -- give back ability points
		CustomGameEventManager:Send_ServerToAllClients("dota_player_upgraded_stats", {playerID = hero:GetPlayerID()} )
	end
end