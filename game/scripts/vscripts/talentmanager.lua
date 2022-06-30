if TalentManager == nil then
	print ( 'creating skill selection manager' )
	TalentManager = {}
	TalentManager.__index = TalentManager
end

function TalentManager:new( o )
	o = o or {}
	setmetatable( o, TalentManager )
	
	return o
end



function TalentManager:StartTalentManager()
	TalentManager = self
	if IsServer() then
		CustomGameEventManager:RegisterListener('send_player_selected_talent', Context_Wrap( TalentManager, 'ProcessHeroMasteries'))
		CustomGameEventManager:RegisterListener('send_player_selected_unique', Context_Wrap( TalentManager, 'ProcessUniqueTalents'))
		CustomGameEventManager:RegisterListener('notify_selected_talent', Context_Wrap( TalentManager, 'NotifyTalent'))
		CustomGameEventManager:RegisterListener('send_player_respec_talents', Context_Wrap( TalentManager, 'RespecAll'))
		CustomGameEventManager:RegisterListener('player_request_data', Context_Wrap( TalentManager, 'RespecAll'))
		CustomGameEventManager:RegisterListener('dota_player_talent_info_request', Context_Wrap( TalentManager, 'ParseInformationRequest'))
	end
	
	if self.talentKV == nil then
		self:LoadTalentData()
	end
	print( "talent manager values initialized", IsServer() )
end

function TalentManager:LoadTalentData()
	self.talentKV = {}
	local workKV = LoadKeyValues( "scripts/npc/npc_talents.txt" )
	for roleType, perkValues in pairs( workKV ) do
		self.talentKV[roleType] = {}
		for perkName, perkValue in pairs( perkValues ) do
			self.talentKV[roleType][perkName] = string.split( perkValue, " " )
		end
	end
end

function TalentManager:ApplyTalentModifier( hero, talentType )
	local modifier = "modifier_talent_".. string.lower( talentType )
	hero:CalculateGenericBonuses( )
	hero:CalculateStatBonus( )
	
	local talents = hero.heroTalentDataContainer.heroMasteries
	local talent = hero:FindModifierByName( modifier )
	if talent then
		talent:SetStackCount( talents[talentType].talentTier * 10 + talents[talentType].talentKeys )
	end
	
	return talent
end

function TalentManager:GetTalentDataForType( talentType, talentTier )
	if self.talentKV == nil then
		self:LoadTalentData()
	end
	return self.talentKV [talentType][tostring(talentTier)]
end

function TalentManager:ParseInformationRequest(userid, request)
	local playerID = request.pID
	local hero = EntIndexToHScript( request.entindex )
	local player = PlayerResource:GetPlayer( playerID )
	hero.lastInformationRequestTime = hero.lastInformationRequestTime or {}
	if not hero.heroTalentDataContainer or ((hero.lastInformationRequestTime[playerID] or 0) + 0.25) > Time() then
		if player then
			CustomGameEventManager:Send_ServerToPlayer(player, "dota_player_talent_update_failure", {PlayerID = pID, hero_entindex = entindex} )
		end
		return 
	end
	hero.lastInformationRequestTime[playerID] = Time()
	local player = PlayerResource:GetPlayer( playerID )
	if player then
		CustomGameEventManager:Send_ServerToPlayer(player, "dota_player_talent_info_response", {playerID = pID, response = hero.heroTalentDataContainer, talentPoints = hero:GetTalentPoints(), entindex = request.entindex} )
	end
end

function TalentManager:IsPlayerRegistered(hero)
	return hero.statsHaveBeenRegistered or false
end

function TalentManager:RegisterPlayer(hero, bRespec)
	local masteryTable = GameRules.UnitKV[hero:GetUnitName()]["Masteries"]
	masteryTable["INF_STATS"] = {["1"] = "1"}
	
	local talents = {}
	talents.heroMasteries = {}
	
	-- MASTERIES -------------------
	for masteryType, masteryData in pairs( masteryTable ) do
		talents.heroMasteries[masteryType] = {}
		talents.heroMasteries[masteryType].talentProgression = {}
		talents.heroMasteries[masteryType].talentKeys = 0
		for masteryTier, masteryMax in pairs( masteryData ) do
			talents.heroMasteries[masteryType].talentTier = tonumber(masteryTier)
			talents.heroMasteries[masteryType].maxTier = tonumber(masteryMax)
			for j = 1, masteryMax do
				table.insert( talents.heroMasteries[masteryType].talentProgression, self.talentKV[masteryType][masteryTier][j] )
			end
			if masteryType ~= "INF_STATS" then
				local modifierTier = tonumber(masteryTier)
				local modifierName = "modifier_talent_".. string.lower( masteryType )
				hero:AddNewModifier( hero, nil, modifierName, {} ):SetStackCount( modifierTier * 10 )
			end
		end
	end
	
	-- UNIQUE TALENTS -------------------
	talents.uniqueTalents = {}
	for i = 0, hero:GetAbilityCount() - 1 do
        local ability = hero:GetAbilityByIndex( i )
        if ability then
			local abName = ability:GetName()
			if abName ~= nil and abName ~= '' then
				talents.uniqueTalents[abName] = TalentManager:GetAbilityLinkedTalents(abName, hero)
			end
        end
    end
	
	hero.heroTalentDataContainer = talents
	hero.respecInfoTalents = hero.respecInfoTalents or {}
	local player = hero:GetPlayerOwner()
	if player then
		Timers:CreateTimer(1, function()
			CustomGameEventManager:Send_ServerToPlayer(player, "dota_player_talent_info_response", {playerID = pID, response = talents, talentPoints = hero:GetTalentPoints()} )
			CustomGameEventManager:Send_ServerToPlayer(player, "dota_player_registered_notification", {entindex = hero:entindex()} )
		end)
	end
	hero.statsHaveBeenRegistered = true
	hero.talentsSkilled = 0
	
	hero:SetAttributePoints( 0 )
	print(hero:GetName(), "registered for stats")
	hero:AddNewModifier(hero, nil, "modifier_stats_system_handler", {})
	hero:AddNewModifier(hero, nil, "modifier_lives_handler", {})
end

function TalentManager:GetAbilityLinkedTalents( abilityName, hero )
	local talents = {}
	local talentLevelRequirement = 10
	if GameRules.AbilityKV[abilityName] and GameRules.AbilityKV[abilityName]["LinkedTalents"] then
		talents = GameRules.AbilityKV[abilityName]["LinkedTalents"]
		for talent, active in pairs( talents ) do
			local talentEnt = hero:FindAbilityByName(talent)
			if talentEnt then
				talents[talent] = talentLevelRequirement
			end
		end
	end
	return talents
end

function TalentManager:ProcessUniqueTalents(userid, event)
	local pID = event.pID
	local entindex = tonumber(event.entindex)
	local talentName = tostring(event.talent)
	local abilityName = tostring(event.abilityName)
	local hero = EntIndexToHScript( entindex )
	if entindex ~= PlayerResource:GetSelectedHeroEntity( pID ):entindex() then return end -- calling
	local mainAbility = hero:FindAbilityByName(abilityName)
	if not mainAbility then return end
	if not mainAbility:IsTrained() then return end
	local talents = hero.heroTalentDataContainer.uniqueTalents
	local talentEntity = hero:FindAbilityByName(talentName)
	if talentEntity and not talentEntity:IsTrained() and hero:GetTalentPoints() > 0 then
		-- level talent linked to all abilities
		for ability, talentTable in pairs( talents ) do
			if talentTable[talentName] then
				for talentID, levelRequirement in pairs(talentTable) do
					if talentID == talentName then
						talentTable[talentID] = -1
					elseif talentTable[talentID] ~= -1 then
						talentTable[talentID] = math.min(levelRequirement + 30, 80)
					end
				end
			end
		end
		-- end
		hero:ModifyTalentPoints(-1)
		talentEntity:SetLevel(1)
		local talentData = CustomNetTables:GetTableValue("talents", tostring(hero:entindex())) or {}
		if GameRules.AbilityKV[talentName] then
			if GameRules.AbilityKV[talentName]["LinkedModifierName"] then
				local modifierName = GameRules.AbilityKV[talentName]["LinkedModifierName"] 
				for _, unit in ipairs( FindAllUnits() ) do
					if unit:HasModifier(modifierName) then
						local mList = unit:FindAllModifiersByName(modifierName)
						for _, modifier in ipairs( mList ) do
							if modifier:HasAuraOrigin() then
								modifier:Destroy()
							else
								local remainingDur = modifier:GetRemainingTime()
								modifier:ForceRefresh()
								if remainingDur > 0 then modifier:SetDuration(remainingDur, true) end
							end
						end
					end
				end
			end
			if GameRules.AbilityKV[talentName]["LinkedAbilityName"] then
				local talentName = GameRules.AbilityKV[talentName]["LinkedAbilityName"] or ""
				local ability = hero:FindAbilityByName(talentName)
				if ability and ability.OnTalentLearned then
					ability:OnTalentLearned(talentName)
				end
			end
		end
		talentData[talentName] = true
		CustomNetTables:SetTableValue( "talents", tostring(hero:entindex()), talentData )
		hero.talentsSkilled = hero.talentsSkilled + 1
		
		GameRules.bossHuntersEntity:OnAbilityLearned( {PlayerID = pID, abilityname = abilityName} )
		CustomGameEventManager:Send_ServerToAllClients("dota_player_talent_update", {PlayerID = pID, hero_entindex = entindex} )
	else
		CustomGameEventManager:Send_ServerToPlayer(player, "dota_player_talent_update_failure", {PlayerID = pID, hero_entindex = entindex} )
	end
end

function TalentManager:ProcessHeroMasteries(userid, event)
	local pID = event.pID
	local entindex = event.entindex
	local talent = tostring(event.talent)
	local hero = EntIndexToHScript( entindex )
	if entindex ~= PlayerResource:GetSelectedHeroEntity( pID ):entindex() then return end -- calling
	-- if hero:FindAbilityByName(talent):GetLevel() > 0 then return end
	-- hero:UpgradeAbility(hero:FindAbilityByName(talent))
	-- hero:CalculateStatBonus()
	local talents = hero.heroTalentDataContainer.heroMasteries
	local price = 1
	-- for talentCategory, talentTypes in pairs( talents.talentKeys ) do
		-- for talentType, talentTier in pairs( talentTypes ) do
			-- price = price + tonumber(talentTier)
		-- end
	-- end
	print( talent, talents[talent], "attempting to level talent" )
	local maxTier = talents[talent].maxTier <= talents[talent].talentKeys and talent ~= "INF_STATS"
	local insufficientSkillPoints = hero:GetAbilityPoints() < price
	if not (maxTier or insufficientSkillPoints) then
		talents[talent].talentKeys = talents[talent].talentKeys + 1
		if talent == "INF_STATS" then
			local stats = tonumber(talents[talent].talentProgression[1])
			hero:ModifyStrength( stats )
			hero:ModifyAgility( stats )
			hero:ModifyIntellect( stats )
			hero.respecInfoTalents["INF_STATS"] = (hero.respecInfoTalents["INF_STATS"] or 0) + stats
		else
			hero.respecInfoTalents[talent] = hero.respecInfoTalents[talent] or {}
			table.insert( hero.respecInfoTalents[talent], self:ApplyTalentModifier( hero, talent ) )
			
			hero:CalculateGenericBonuses( )
			hero:CalculateStatBonus( )
		end
		hero:SetAbilityPoints( hero:GetAbilityPoints() - price )
		CustomGameEventManager:Send_ServerToAllClients("dota_player_talent_update", {PlayerID = pID, hero_entindex = entindex} )
	else
		local player = PlayerResource:GetPlayer(pID)
		if player then
			CustomGameEventManager:Send_ServerToPlayer(player, "dota_player_talent_update_failure", {PlayerID = pID, hero_entindex = entindex} )
		end
	end
	if maxTier then
		EventManager:ShowErrorMessage(pID, "#TALENT_ERROR_MAX")
	elseif insufficientSkillPoints then
		EventManager:ShowErrorMessage(pID, "#TALENT_ERROR_COST", price )
	end
end

function TalentManager:NotifyTalent(userid, event)
	local player = PlayerResource:GetPlayer(event.pID)
	player.notifyTalentDelayTimer = player.notifyTalentDelayTimer or 0
	if GameRules:GetGameTime() > player.notifyTalentDelayTimer + 1 then
		Say(player, event.text, true)
		player.notifyTalentDelayTimer = GameRules:GetGameTime()
	end
end

function TalentManager:RespecAll(userid, event)
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
		Timers:CreateTimer(function()
			for _, modifier in ipairs( modifiers ) do
				if modifier and not modifier:IsNull() and modifier:GetAbility() then
					if not modifier:GetAbility():IsInnateAbility() and hero:FindAbilityByName( modifier:GetAbility():GetAbilityName() ) then -- destroy passive modifiers and any buffs
						modifier:Destroy()
					end
				end
			end
		end)
		for talentCategory, data in pairs( hero.respecInfoTalents ) do
			if talentCategory == "ALL_STATS" then
				hero:ModifyStrength( -data )
				hero:ModifyAgility( -data )
				hero:ModifyIntellect( -data )
			else
				for _, modifier in ipairs( data ) do
					modifier:Destroy()	
				end
			end
		end
		hero:CalculateGenericBonuses( )
		hero:CalculateStatBonus( )
		
		hero.uniqueTalentPoints = math.floor( hero:GetLevel() / 10 )
		hero.bonusSkillPoints = hero.bonusSkillPoints or hero:GetLevel()
		hero:SetAbilityPoints( hero.bonusSkillPoints + 1 )
		CustomGameEventManager:Send_ServerToAllClients("dota_player_talent_info_response", {playerID = hero:GetPlayerID()} )
		CustomGameEventManager:Send_ServerToAllClients("dota_player_upgraded_stats", {playerID = hero:GetPlayerID()} )
	end
end