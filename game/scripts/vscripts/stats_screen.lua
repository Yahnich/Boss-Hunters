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
	
	self.ms = 10
	self.mp = 200
	self.mpr = 2
	self.ha = {0,1,2,3,4,5}
	
	self.ad = 20
	self.sa = 10
	-- self.cdr = {0,1,2,3,4,5}
	self.as = 10
	self.sta = {0,1,2,3,4,5}
	self.acc = {0,1,2,3,4,5}
	
	self.pr = 1
	self.mr = {0,1,2,3,4,5}
	self.arm = 25
	self.ar = 50
	self.hp = 150
	self.hpr = 1.5
	self.sr = {0,1,2,3,4,5}
	
	self.all = 2
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
	-- stats.cdr = 0
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

	stats = nil
	CustomNetTables:SetTableValue( "talents", tostring(hero:entindex()), {} )
	CustomGameEventManager:Send_ServerToAllClients("dota_player_upgraded_stats", {playerID = hero:GetPlayerID()} )
	
	hero.statsHaveBeenRegistered = true
	hero.talentsSkilled = 0
	
	hero:SetAttributePoints( 0 )
	
	hero:AddNewModifier(hero, nil, "modifier_stats_system_handler", {})
end

function StatsScreen:ProcessStatsUpgrade(userid, event)
	local pID = event.pID
	local entindex = event.entindex
	local skill = tostring(event.skill)
	local hero = EntIndexToHScript( entindex )

	if entindex ~= PlayerResource:GetSelectedHeroEntity( pID ):entindex() then return end -- calling
	local netTable = CustomNetTables:GetTableValue("stats_panel", tostring(entindex))
	
	if hero:GetAttributePoints() <= 0 or ( type(self[skill]) == "table" and not self[skill][ tonumber( netTable[skill] + 1 ) ] ) then return end
	
	netTable[skill] = tostring(tonumber(netTable[skill]) + 1)
	CustomNetTables:SetTableValue("stats_panel", tostring(entindex), netTable)
	hero:ModifyAttributePoints( -1 )
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
	if hero and ( not hero.hasRespecced or event.forced ) then
		self:RegisterPlayer(hero, event.forced == nil) -- Reset stats screen
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
		hero.totalGainedTalentPoints = hero.totalGainedTalentPoints or 0
		hero.bonusSkillPoints = hero.bonusSkillPoints or hero:GetLevel()
		hero:SetAbilityPoints( hero.bonusSkillPoints + 1 )
		hero:SetAttributePoints( hero.totalGainedTalentPoints)
		CustomGameEventManager:Send_ServerToAllClients("dota_player_upgraded_stats", {playerID = hero:GetPlayerID()} )
	end
end