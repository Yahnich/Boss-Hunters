if AbilityManager == nil then
	print ( 'creating skill selection manager' )
	AbilityManager = {}
	AbilityManager.__index = AbilityManager
end

function AbilityManager:new( o )
	o = o or {}
	setmetatable( o, AbilityManager )
	
	return o
end

function AbilityManager:StartAbilityManager()
	AbilityManager = self
	if IsServer() then
		CustomGameEventManager:RegisterListener('send_player_selected_ability', Context_Wrap( AbilityManager, 'ProcessHeroAbilities'))
		CustomGameEventManager:RegisterListener('send_player_selected_perk', Context_Wrap( AbilityManager, 'ProcessHeroPerkSelection'))
		CustomGameEventManager:RegisterListener('dota_player_ability_info_request', Context_Wrap( AbilityManager, 'SendAbilityData'))
	end
	print( "talent manager values initialized", IsServer() )
end

ABILITY_MANAGER_TYPE = {BASIC = ABILITY_TYPE_BASIC, ULTIMATE = ABILITY_TYPE_ULTIMATE}

function AbilityManager:RegisterPlayer(hero)
	local abilityPool = GameRules.UnitKV[hero:GetUnitName()]["AbilityPool"]
	hero.abilityPool = {}
	hero.abilityPool[ABILITY_TYPE_BASIC] = {}
	hero.abilityPool[ABILITY_TYPE_ULTIMATE] = {}
	for abilityName, abilityData in pairs( abilityPool ) do
		if type(abilityData) == "string" then
			AbilityManager:AddAbilityToPool( hero, abilityName, ABILITY_MANAGER_TYPE[abilityData] )
		elseif type(abilityData) == "table" then
			AbilityManager:AddAbilityToPool( hero, abilityName, ABILITY_MANAGER_TYPE[abilityData.type] )
		else
			print(abilityName .. "invalid data found:", abilityData )
		end
	end
	AbilityManager:AddAbilityToPool( hero, "generic_empty", ABILITY_TYPE_BASIC )
	AbilityManager:AddAbilityToPool( hero, "generic_empty", ABILITY_TYPE_ULTIMATE )
end

function AbilityManager:AddAbilityToPool( hero, abilityName, abilityType )
	if not hero.abilityPool[abilityType] then 
		print("failed to register type", abilityType, "for", abilityName )
		return
	end
	table.insert( hero.abilityPool[abilityType], abilityName )
end

function AbilityManager:RemoveAbilityFromPool( hero, abilityNameToRemove, abilityType )
	if not hero.abilityPool[abilityType] then 
		print("failed to remove type", abilityType, "for", abilityNameToRemove )
		return
	end
	for id, abilityName in pairs( hero.abilityPool[abilityType] ) do
		if abilityName == abilityNameToRemove then
			table.remove( hero.abilityPool[abilityType], id )
			return true
		end
	end
	print("failed to remove type", abilityType, "for", abilityNameToRemove )
	return false
end

function AbilityManager:GetCurrentAbilityPool( hero, abilityType )
	if not hero.abilityPool[abilityType] then 
		print("failed to request type", abilityType, "for", abilityName )
		return
	end
	return hero.abilityPool[abilityType]
end

function AbilityManager:ProcessHeroAbilities( userid, event )
	local hero = EntIndexToHScript( event.entindex )
	local player = PlayerResource:GetPlayer( event.pID )
	
	CustomGameEventManager:Send_ServerToPlayer(player, "dota_player_remove_ability_selection", {})
	if event.abilityName == "generic_empty" then
		return
	end
	local abilityPlaceHolder = hero:FindAbilityByName( event.abilityToReplace )
	if abilityPlaceHolder then
		AbilityManager:RemoveAbilityFromPool( hero, event.abilityName, abilityPlaceHolder:GetAbilityType() )
		local chosenAbility = hero:AddAbility( event.abilityName )
		hero:UpgradeAbility( chosenAbility )
		hero:SwapAbilities( event.abilityName, event.abilityToReplace, true, false )
		hero:RemoveAbilityByHandle( abilityPlaceHolder )
		
		AbilityManager:ProcessAbilityPerks( chosenAbility, hero )
	else
		print("placeholder not found", event.abilityToReplace )
	end
end

function AbilityManager:SendAbilityData( userid, event )
end

function AbilityManager:ProcessHeroPerkSelection( userid, event )
	local hero = EntIndexToHScript( event.entindex )
	local player = PlayerResource:GetPlayer( event.pID )
	local ability = EntIndexToHScript( event.ability )
	
	if toboolean(event.perkType) then -- major
		ability._abilityValueMajorPerk = ability._abilityValueMajorPerk or {}
		ability._abilityValueMajorPerk[event.perkName] = true
	else
		ability._abilityValueMinorPerkLevel = ability._abilityValueMinorPerkLevel or {}
		ability._abilityValueMinorPerkLevel[event.perkName] = (ability._abilityValueMinorPerkLevel[event.perkName] or 0) + 1
	end
	
	hero:UpgradeAbility( ability )
	ability:RefreshIntrinsicModifier()
	
	hero:RefreshStats()
	
	hero._currentlyLoadedPerks = nil
	hero._currentlyLoadedPerksAbility = nil
	CustomGameEventManager:Send_ServerToPlayer(player, "dota_player_remove_perk_selection", {})
end

function AbilityManager:ProcessAbilityPerks( ability, hero )
	local abilityData = GetAbilityKeyValuesByName( ability:GetAbilityName() )
	ability._perks = {}
	-- set up minor perks
	local abilityValues = abilityData.AbilityValues
	ability._minorPerks = {}
	for abilityKey, abilityValue in pairs( abilityValues ) do
		if type( abilityValue ) == "table" then
			if abilityValue.special_bonus_minor_perk then
				local perkValue = abilityValue.special_bonus_minor_perk
				ability._minorPerks[abilityKey] = {}
				ability._minorPerks[abilityKey].perkValue = string.match( perkValue, "(%d*%.?%d+)" )
				local setType = string.sub( perkValue, 1, 1)
				if string.match( setType, "%d+" ) then setType = "+" end -- default is addition
				ability._minorPerks[abilityKey].perkSettingType = setType
				local setFunc = string.sub( perkValue, -1)
				if string.match( setFunc, "%d+" ) then setFunc = " " end -- default is no function
				ability._minorPerks[abilityKey].perkSettingFunction	= setFunc
				
			end
		end
	end
	-- set up major perks
	local abilityPerks = abilityData.AbilityPerks
	ability._majorPerks = {}
	for perkName, perkData in pairs( abilityPerks ) do
		ability._majorPerks[perkName] = {}
		for specialKey, specialValue in pairs( perkData ) do
			local targetAbility = ability
			local actualSpecialValue = specialValue
			local levelValue = 0
			if type(specialValue) == "table" then
				actualSpecialValue = specialValue.value
				levelValue = tonumber(specialValue.hero_levelup)
				if specialValue.targets_ability then
					targetAbility = hero:FindAbilityByName( specialValue.targets_ability ) or targetAbility
				end
			end
			targetAbility._majorPerks[perkName][specialKey] = {}
			targetAbility._majorPerks[perkName][specialKey].perkValue = string.match( actualSpecialValue, "(%d*%.?%d+)" )
			targetAbility._majorPerks[perkName][specialKey].perkLevelupValue = levelValue
			local setType = string.sub( actualSpecialValue, 1, 1)
			if string.match( setType, "%d+" ) then setType = "+" end -- default is addition
			targetAbility._majorPerks[perkName][specialKey].perkSettingType = setType
			local setFunc = string.sub( actualSpecialValue, -1)
			if string.match( setFunc, "%d+" ) then setFunc = " " end -- default is no function
			targetAbility._majorPerks[perkName][specialKey].perkSettingFunction = setFunc
		end
	end
end

function CDOTABaseAbility:GetMinorPerkData( perkName )
	return self._minorPerks[perkName]
end

function CDOTABaseAbility:GetMajorPerkData( perkName )
	return self._majorPerks[perkName]
end

function AbilityManager:GetCurrentMajorPerksForAbility( ability )
	local perks = {}
	for perkName, perkData in pairs( ability._majorPerks ) do
		if not ability._abilityValueMajorPerk or not ability._abilityValueMajorPerk[perkName] then
			local perk = table.copy( perkData )
			perk.perkName = perkName
			table.insert( perks, perk )
		end
	end
	return perks
end

function AbilityManager:GetCurrentMinorPerksForAbility( ability )
	local perks = {}
	local potentialPerks = {}
	for perkName, perkData in pairs( ability._minorPerks ) do
		local perk = {}
		perk.perkName = perkName
		perk.perkValue = perkData.perkSettingType .. tostring( perkData.perkValue ) .. perkData.perkSettingFunction
		table.insert( potentialPerks, perk )
	end
	local perksToSelect = math.max( 1, math.floor( #potentialPerks * 0.67 ) )
	while perksToSelect > 0 do
		local selectedID = RandomInt(1, #potentialPerks)
		local perk = potentialPerks[selectedID]
		
		table.remove( potentialPerks, selectedID )
		table.insert( perks, perk )
		
		perksToSelect = perksToSelect - 1
	end
	return perks
end

function AbilityManager:GetLoadedPerksForHero( hero )
	return hero._currentlyLoadedPerks
end