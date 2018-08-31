if RelicManager == nil then
  print ( 'creating relic manager' )
  RelicManager = {}
  RelicManager.__index = RelicManager
end

function RelicManager:new( o )
  o = o or {}
  setmetatable( o, RelicManager )
  return o
end

SKIP_RELIC_CHANCE_INCREASE = 25
BASE_RELIC_CHANCE = 33

function RelicManager:Initialize()
  RelicManager = self
  print("Relic Manager initialized")
  local relics = LoadKeyValues('scripts/npc/npc_relics_custom.txt')
  self.genericDropTable = relics.relic_type_generic
  self.cursedDropTable = relics.relic_type_cursed
  self.uniqueDropTable = relics.relic_type_unique
  
  for relic, weight in pairs( self.genericDropTable ) do
	if weight ~= 0 then
		LinkLuaModifier( relic, "relics/generic/"..relic, LUA_MODIFIER_MOTION_NONE )
	end
  end
  
  for relic, weight in pairs( self.cursedDropTable ) do
	if weight ~= 0 then
		LinkLuaModifier( relic, "relics/cursed/"..relic, LUA_MODIFIER_MOTION_NONE )
	end
  end
  
  for relic, weight in pairs( self.uniqueDropTable ) do
	if weight ~= 0 then
		LinkLuaModifier( relic, "relics/unique/"..relic, LUA_MODIFIER_MOTION_NONE )
	end
  end
  
  CustomGameEventManager:RegisterListener('player_selected_relic', Context_Wrap( RelicManager, 'ConfirmRelicSelection'))
  CustomGameEventManager:RegisterListener('player_skipped_relic', Context_Wrap( RelicManager, 'SkipRelicSelection'))
  CustomGameEventManager:RegisterListener('player_notify_relic', Context_Wrap( RelicManager, 'NotifyRelics'))
  CustomGameEventManager:RegisterListener('dota_player_query_relic_inventory', Context_Wrap( RelicManager, 'SendHeroRelicInventory'))
  
  
end

function RelicManager:SendHeroRelicInventory(userid, event)
	local hero = EntIndexToHScript(event.entindex)
	local pID = event.playerID
	if hero then
		local player = PlayerResource:GetPlayer(pID)
		if player then
			CustomGameEventManager:Send_ServerToPlayer(player,"dota_player_update_relic_inventory", {relics = hero.ownedRelics, hero = hero:entindex()})
		end
		
	end
end

function RelicManager:NotifyRelics(userid, event)
	local player = PlayerResource:GetPlayer(event.pID)
	player.notifyRelicDelayTimer = player.notifyRelicDelayTimer or 0
	if GameRules:GetGameTime() > player.notifyRelicDelayTimer + 1 then
		local CHAR_SIZE = 110
		if string.len(event.text) > 110 then
			local t={} ; i=1
			for str in string.gmatch(event.text, "([^".." ".."]+)") do
				t[i] = str
				i = i + 1
			end
			local say = ""
			for j = 1, i do
				if t[j] and string.len(say) + string.len(t[j]) < 110 then
					say = say.." "..t[j]
				else
					Say(player, say, true)
					say = t[j]
				end
			end
			if say ~= "" then Say(player, say, true) end
		else
			Say(player, event.text, true)
		end
		player.notifyRelicDelayTimer = GameRules:GetGameTime()
	end
end
	
function RelicManager:ConfirmRelicSelection(userid, event)
	local pID = event.pID
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	local relic = event.relic

	hero:AddRelic(relic)
	RelicManager:RemoveDropFromTable(pID, true, relic)
	hero.internalRelicRNG = BASE_RELIC_CHANCE
end

function RelicManager:RemoveDropFromTable(pID, bRemove, sRemoveSpecific)
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	if not bRemove then
		for id, relicName in ipairs( hero.relicsToSelect[1] ) do
			if relicName ~= sRemoveSpecific then
				if string.match(relicName, "unique") then
					hero.internalRNGPools[3][relicName] = "1"
				elseif string.match(relicName, "cursed") then
					hero.internalRNGPools[2][relicName] = "1"
				else
					hero.internalRNGPools[1][relicName] = "1"
				end
			end
		end
	end
	table.remove( hero.relicsToSelect, 1 )
	local player = PlayerResource:GetPlayer(pID)
	if player then
		CustomGameEventManager:Send_ServerToPlayer(player,"dota_player_updated_relic_drops", {playerID = pID, drops = hero.relicsToSelect})
	end
end

function RelicManager:SkipRelicSelection(userid, event)
	local pID = event.pID
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	
	local copy = {}
	
	for id, relic in pairs( hero.relicsToSelect[1] ) do
		copy[id] = relic
	end
	
	RelicManager:RemoveDropFromTable(pID, true)
	hero.internalRelicRNG = math.min( (hero.internalRelicRNG or BASE_RELIC_CHANCE) + SKIP_RELIC_CHANCE_INCREASE, 100 )
	if hero:HasRelic("relic_unique_mysterious_hourglass") and hero:FindModifierByName("relic_unique_mysterious_hourglass"):GetStackCount() > 0 then
		hero:FindModifierByName("relic_unique_mysterious_hourglass"):DecrementStackCount()
		local dropTable = {}
		for id, relic in pairs( copy ) do
			if string.match(relic, "unique") then
				table.insert( dropTable, self:RollRandomUniqueRelicForPlayer(pID) )
			elseif string.match(relic, "cursed") then
				table.insert( dropTable, self:RollRandomCursedRelicForPlayer(pID) )
			else
				table.insert( dropTable, self:RollRandomGenericRelicForPlayer(pID) )
			end
		end
		table.insert( hero.relicsToSelect, dropTable )
		local player = PlayerResource:GetPlayer(pID)
		if player then
			CustomGameEventManager:Send_ServerToPlayer(player,"dota_player_updated_relic_drops", {playerID = pID, drops = hero.relicsToSelect})
		end
		return
	end
	-- hero:AddRelic( RelicManager:RollRandomGenericRelicForPlayer(pID) )
end

function RelicManager:RegisterPlayer(pID)
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	hero.internalRelicRNG = BASE_RELIC_CHANCE
	hero.internalRNGPools = {}
	table.insert(hero.internalRNGPools, table.copy(self.genericDropTable) )
	table.insert(hero.internalRNGPools, table.copy(self.cursedDropTable) )
	table.insert(hero.internalRNGPools, table.copy(self.uniqueDropTable) )
end


function RelicManager:RollBossRelicsForPlayer(pID)
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	local player = PlayerResource:GetPlayer(pID)
	if not hero then return end

	hero.ownedRelics = hero.ownedRelics or {}
	hero.relicsToSelect = hero.relicsToSelect or {}
	local dropTable = {}
	
	table.insert( dropTable, self:RollRandomUniqueRelicForPlayer(pID)	)
	table.insert( dropTable, self:RollRandomCursedRelicForPlayer(pID) )
	
	RelicManager:PushCustomRelicDropsForPlayer(pID, dropTable)
end

function RelicManager:RollEliteRelicsForPlayer(pID)
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	local player = PlayerResource:GetPlayer(pID)
	if not hero then return end

	hero.ownedRelics = hero.ownedRelics or {}
	hero.relicsToSelect = hero.relicsToSelect or {}
	local dropTable = {}
	table.insert( dropTable, self:RollRandomGenericRelicForPlayer(pID) )
	table.insert( dropTable, self:RollRandomGenericRelicForPlayer(pID) )
	table.insert( dropTable, self:RollRandomGenericRelicForPlayer(pID) )
	
	RelicManager:PushCustomRelicDropsForPlayer(pID, dropTable)
end

function RelicManager:PushCustomRelicDropsForPlayer(pID, relicTable)
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	local player = PlayerResource:GetPlayer(pID)
	if not hero then return end
	
	local greed = hero:HasRelic("relic_cursed_icon_of_greed")
	local pride = hero:HasRelic("relic_cursed_icon_of_pride")
	local contract = hero:HasRelic("relic_cursed_forbidden_contract")
	if ( contract and not hero:HasRelic("relic_unique_ritual_candle") ) then
		local corruptTable = {}
		table.insert( corruptTable, self:RollRandomCursedRelicForPlayer(pID) )
		table.insert( corruptTable, self:RollRandomCursedRelicForPlayer(pID) )
		table.insert( corruptTable, self:RollRandomCursedRelicForPlayer(pID) )
		
		table.insert( hero.relicsToSelect, corruptTable )
	else
		table.insert( hero.relicsToSelect, relicTable )
	end
	
	if ( (greed or pride) and not hero:HasRelic("relic_unique_ritual_candle") ) then
		RelicManager:RemoveDropFromTable(pID, false)
	elseif player then
		CustomGameEventManager:Send_ServerToPlayer(player,"dota_player_updated_relic_drops", {playerID = pID, drops = hero.relicsToSelect})
	end
end

function RelicManager:RollRandomGenericRelicForPlayer(pID, notThisRelic)
	local dropTable = {}
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	hero.ownedRelics = hero.ownedRelics or {}
	for relic, weight in pairs( hero.internalRNGPools[1] ) do
		if relic ~= notThisRelic then
			for i = 1, weight do
				table.insert(dropTable, relic)
			end
		end
	end
	
	if dropTable[1] == nil then
		
		hero.internalRNGPools[1] = table.copy(self.genericDropTable)
		for relic, weight in pairs( hero.internalRNGPools[1] ) do
			if relic ~= notThisRelic then
				print(relic, weight, "reset")
				for i = 1, weight do
					table.insert(dropTable, relic)
				end
			end
		end
	end
	
	if dropTable[1] ~= nil then
		local relic = dropTable[RandomInt(1, #dropTable)]
		hero.internalRNGPools[1][relic] = nil
		return relic
	else
		return "generic_relic_not_found"
	end
end

function RelicManager:RollRandomCursedRelicForPlayer(pID, notThisRelic)
	local dropTable = {}
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	hero.ownedRelics = hero.ownedRelics or {}
	for relic, weight in pairs( hero.internalRNGPools[2] ) do
		if relic ~= notThisRelic then
			for i = 1, weight do
				table.insert(dropTable, relic)
			end
		end
	end
	if dropTable[1] == nil then
		hero.internalRNGPools[2] = table.copy(self.cursedDropTable)
		for relic, weight in pairs( hero.internalRNGPools[2] ) do
			if relic ~= notThisRelic then
				for i = 1, weight do
					table.insert(dropTable, relic)
				end
			end
		end
	end
	if dropTable[1] ~= nil then
		local relic = dropTable[RandomInt(1, #dropTable)]
		hero.internalRNGPools[2][relic] = nil
		return relic
	else
		return "cursed_relic_not_found"
	end
end

function RelicManager:RollRandomUniqueRelicForPlayer(pID, notThisRelic)
	local dropTable = {}
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	hero.ownedRelics = hero.ownedRelics or {}
	for relic, weight in pairs( hero.internalRNGPools[3] ) do
		if relic ~= notThisRelic then
			for i = 1, weight do
				table.insert(dropTable, relic)
			end
		end
	end
	if dropTable[1] == nil then
		hero.internalRNGPools[3] = table.copy(self.uniqueDropTable)
		for relic, weight in pairs( hero.internalRNGPools[3] ) do
			if relic ~= notThisRelic then
				for i = 1, weight do
					table.insert(dropTable, relic)
				end
			end
		end
	end
	if dropTable[1] ~= nil then
		local relic = dropTable[RandomInt(1, #dropTable)]
		hero.internalRNGPools[3][relic] = nil
		return relic
	else
		return "unique_relic_not_found"
	end
end

function CDOTA_BaseNPC_Hero:HasRelic(relic)
	self.ownedRelics = self.ownedRelics or {}
	return self:HasModifier(relic)
end

function RelicManager:ClearRelics(pID, bHardClear)
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	relicCount = 0
	for item, relic in pairs( hero.ownedRelics ) do
		if (relic == "relic_cursed_cursed_dice" and bHardClear) or relic ~= "relic_cursed_cursed_dice" then -- cursed dice cannot be removed
			relicCount = relicCount + 1
			hero:RemoveModifierByName( relic )
			UTIL_Remove( EntIndexToHScript(item) )
			hero.ownedRelics[item] = nil
		end
	end
	hero.internalRNGPools[1] = table.copy(self.genericDropTable)
	hero.internalRNGPools[2] = table.copy(self.cursedDropTable)
	hero.internalRNGPools[3] = table.copy(self.uniqueDropTable)
	return relicCount
end

function RelicManager:RemoveRelicOnPlayer(relic, pID, bAll)
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	
	
	for entindex, relicName in pairs(hero.ownedRelics) do
		if relicName == relic then
			local item = EntIndexToHScript(entindex)
			for _, modifier in ipairs( hero:FindAllModifiers() ) do
				if modifier:GetAbility() == item then modifier:Destroy() end
			end
			UTIL_Remove( item )
			if string.match(relicName, "unique") then
				hero.internalRNGPools[3][relicName] = "1"
			elseif string.match(relicName, "cursed") then
				hero.internalRNGPools[2][relicName] = "1"
			else
				hero.internalRNGPools[1][relicName] = "1"
			end
			
			hero.ownedRelics[entindex] = nil
			if not bAll then break end
		end
	end
end

function CDOTA_BaseNPC_Hero:AddRelic(relic)
	self.ownedRelics = self.ownedRelics or {}
	
	if string.match(relic, "unique") then
		self.internalRNGPools[3][relic] = nil
	elseif string.match(relic, "cursed") then
		self.internalRNGPools[2][relic] = nil
	else
		self.internalRNGPools[1][relic] = nil
	end
	
	local relicEntity = CreateItem("item_relic_handler", nil, nil)
	self.ownedRelics[relicEntity:entindex()] = relic
	self:AddNewModifier( self, relicEntity, relic, {} )
	
	CustomGameEventManager:Send_ServerToAllClients( "dota_player_update_relic_inventory", { hero = self:entindex(), relics = self.ownedRelics } )
end

