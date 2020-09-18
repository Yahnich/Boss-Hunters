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
	
	if not self.talentKV then
		self.talentKV = {}
		local workKV = LoadKeyValues( "scripts/npc/npc_talents.txt" )
		for roleType, perkValues in pairs( workKV ) do
			self.talentKV[roleType] = {}
			for perkName, perkValue in pairs( perkValues ) do
				self.talentKV[roleType][perkName] = string.split( perkValue, " " )
			end
		end
	end
	print( "talent manager values initialized", IsServer() )
end

function TalentManager:ApplyTalentModifier( hero, talentCategory, talentType )
	local modifier = "modifier_".. string.lower( talentCategory ) .. "_" .. string.lower( talentType )
	hero:AddNewModifier( hero, nil, modifier, {} )
end

function TalentManager:GetTalentDataForType( talentCategory, talentType )
	print("get data", IsServer() )
	if self.talentKV == nil then
		self.talentKV = {}
		local workKV = LoadKeyValues( "scripts/npc/npc_talents.txt" )
		for roleType, perkValues in pairs( workKV ) do
			self.talentKV[roleType] = {}
			for perkName, perkValue in pairs( perkValues ) do
				self.talentKV[roleType][perkName] = string.split( perkValue, " " )
			end
		end
	end
	return self.talentKV[talentCategory][talentType]
end

function TalentManager:ParseInformationRequest(userid, request)
	local playerID = request.pID
	local hero = EntIndexToHScript( request.entindex )
	local player = PlayerResource:GetPlayer( playerID )
	hero.lastInformationRequestTime = hero.lastInformationRequestTime or {}
	if not hero.masteryPerks or ((hero.lastInformationRequestTime[playerID] or 0) + 0.1) > GameRules:GetGameTime() then
		if player then
			CustomGameEventManager:Send_ServerToPlayer(player, "dota_player_talent_update_failure", {PlayerID = pID, hero_entindex = entindex} )
		end
		return 
	end
	hero.lastInformationRequestTime[playerID] = GameRules:GetGameTime()
	local player = PlayerResource:GetPlayer( playerID )
	if player then
		CustomGameEventManager:Send_ServerToPlayer(player, "dota_player_talent_info_response", {playerID = pID, response = hero.masteryPerks, talentPoints = hero:GetTalentPoints(), entindex = request.entindex} )
	end
end

function TalentManager:ConvertPerkTableToOrderedArray( talentTable ) -- blast you lua
	local returnTable = {}
	returnTable[1] = "Attacker"
	returnTable[2] = "Nuker"
	returnTable[3] = "Defender"
	returnTable[4] = "Support"
	returnTable[5] = "Healer"
	returnTable[6] = "Generic"
	for id, name in ipairs( returnTable ) do
		if talentTable.talentProgression[name] then
			returnTable[id] = {[name] = table.copy( talentTable.talentProgression[name] )}
		end
	end
	for i = #returnTable, 1, -1 do
		if type( returnTable[i] ) == "string" then
			table.remove( returnTable, i )
		else
		end
	end
	return returnTable
end

function TalentManager:IsPlayerRegistered(hero)
	return hero.statsHaveBeenRegistered or false
end

function TalentManager:RegisterPlayer(hero, bRespec)
	local kvRoles = string.split( GameRules.UnitKV[hero:GetUnitName()]["Role"], ",")
	local kvRoleLevels = string.split( GameRules.UnitKV[hero:GetUnitName()]["Rolelevels"], ",")
	
	local heroRoles = {}
	
	for i = 1, #kvRoles do
		heroRoles[kvRoles[i]] = kvRoleLevels[i]
	end
	
	talents = {}
	talents.talentProgression = {}
	talents.talentKeys = {}
	for role, level in pairs( heroRoles ) do
		if role == "Carry" then
			talents.talentProgression["Attacker"] = {}
			talents.talentKeys["Attacker"] = {}
			for talentType, talentValues in pairs( self.talentKV.Attacker ) do
				talents.talentProgression["Attacker"][talentType] = {}
				talents.talentKeys["Attacker"][talentType] = 0
				for j = 1, level do
					talents.talentProgression["Attacker"][talentType][j] = talentValues[j]
				end
			end
		elseif role == "Nuker" then
			talents.talentProgression["Nuker"] = {}
			talents.talentKeys["Nuker"] = {}
			for talentType, talentValues in pairs( self.talentKV.Nuker ) do
				talents.talentProgression["Nuker"][talentType] = {}
				talents.talentKeys["Nuker"][talentType] = 0
				for j = 1, level do
					talents.talentProgression["Nuker"][talentType][j] = talentValues[j]
				end
			end
		elseif role == "Durable" then
			talents.talentProgression["Defender"] = {}
			talents.talentKeys["Defender"] = {}
			for talentType, talentValues in pairs( self.talentKV.Defender ) do
				talents.talentProgression["Defender"][talentType] = {}
				talents.talentKeys["Defender"][talentType] = 0
				for j = 1, level do
					talents.talentProgression["Defender"][talentType][j] = talentValues[j]
				end
			end
		elseif role == "Disabler" then
			talents.talentProgression["Support"] = {}
			talents.talentKeys["Support"] = {}
			for talentType, talentValues in pairs( self.talentKV.Support ) do
				talents.talentProgression["Support"][talentType] = {}
				talents.talentKeys["Support"][talentType] = 0
				for j = 1, level do
					talents.talentProgression["Support"][talentType][j] = talentValues[j]
				end
			end
		elseif role == "Support" then
			talents.talentProgression["Healer"] = {}
			talents.talentKeys["Healer"] = {}
			for talentType, talentValues in pairs( self.talentKV.Healer ) do
				talents.talentProgression["Healer"][talentType] = {}
				talents.talentKeys["Healer"][talentType] = 0
				for j = 1, level do
					talents.talentProgression["Healer"][talentType][j] = talentValues[j]
				end
			end
		end
	end
	talents.talentProgression["Generic"] = table.copy( self.talentKV.Generic )
	talents.talentKeys["Generic"] = {}
	for talentType, talentValues in pairs( self.talentKV.Generic ) do
		talents.talentKeys["Generic"][talentType] = 0
	end
	
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
	hero.masteryPerks = talents
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
	local talents = hero.masteryPerks.uniqueTalents
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
			if GameRules.AbilityKV[abilityName]["LinkedModifierName"] then
				local modifierName = GameRules.AbilityKV[talentName]["LinkedModifierName"] 
				for _, unit in ipairs( FindAllUnits() ) do
					if unit:HasModifier(modifierName) then
						local mList = unit:FindAllModifiersByName(modifierName)
						for _, modifier in ipairs( mList ) do
							local remainingDur = modifier:GetRemainingTime()
							modifier:ForceRefresh()
							if remainingDur > 0 then modifier:SetDuration(remainingDur, true) end
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
		
		CustomGameEventManager:Send_ServerToAllClients("dota_player_talent_update", {PlayerID = pID, hero_entindex = entindex} )
	else
		CustomGameEventManager:Send_ServerToPlayer(player, "dota_player_talent_update_failure", {PlayerID = pID, hero_entindex = entindex} )
	end
end

function TalentManager:ProcessHeroMasteries(userid, event)
	local pID = event.pID
	local entindex = event.entindex
	local talent = tostring(event.talent)
	local talentCategory = tostring(event.talentCategory)
	local hero = EntIndexToHScript( entindex )
	if entindex ~= PlayerResource:GetSelectedHeroEntity( pID ):entindex() then return end -- calling
	-- if hero:FindAbilityByName(talent):GetLevel() > 0 then return end
	-- hero:UpgradeAbility(hero:FindAbilityByName(talent))
	-- hero:CalculateStatBonus()
	local talents = hero.masteryPerks
	local maxTalentTier = 0
	for _, talent in pairs( talents.talentProgression[talentCategory][talent] ) do
		maxTalentTier = maxTalentTier + 1
	end
	local price = 1
	for talentCategory, talentTypes in pairs( talents.talentKeys ) do
		for talentType, talentTier in pairs( talentTypes ) do
			price = price + tonumber(talentTier)
		end
	end
	local maxTier = maxTalentTier <= talents.talentKeys[talentCategory][talent]
	local insufficientSkillPoints = hero:GetAbilityPoints() < price
	if not (maxTier or insufficientSkillPoints) then
		talents.talentKeys[talentCategory][talent] = talents.talentKeys[talentCategory][talent] + 1
		self:ApplyTalentModifier( hero, talentCategory, talent )
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
		hero:CalculateStatBonus()
		hero.totalGainedTalentPoints = hero.totalGainedTalentPoints or 0
		hero.bonusSkillPoints = hero.bonusSkillPoints or hero:GetLevel()
		hero:SetAbilityPoints( hero.bonusSkillPoints + 1 )
		hero:SetAttributePoints( hero.totalGainedTalentPoints)
		CustomGameEventManager:Send_ServerToAllClients("dota_player_talent_info_response", {playerID = hero:GetPlayerID()} )
	end
end