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
	
	local abilityPlaceHolder = hero:FindAbilityByName( event.abilityToReplace )
	if abilityPlaceHolder then
		AbilityManager:RemoveAbilityFromPool( hero, event.abilityName, abilityPlaceHolder:GetAbilityType() )
		local chosenAbility = hero:AddAbility( event.abilityName )
		hero:UpgradeAbility( chosenAbility )
		hero:SwapAbilities( event.abilityName, event.abilityToReplace, true, false )
		hero:RemoveAbilityByHandle( abilityPlaceHolder )
	else
		print("placeholder not found", event.abilityToReplace )
	end
	CustomGameEventManager:Send_ServerToPlayer(player, "dota_player_remove_ability_selection", {})
end

function AbilityManager:SendAbilityData( userid, event )
end