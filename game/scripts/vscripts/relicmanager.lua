if RelicManager == nil then
  print ( 'creating projectile manager' )
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
	LinkLuaModifier( relic, "relics/generic/"..relic, LUA_MODIFIER_MOTION_NONE )
  end
  
  for relic, weight in pairs( self.cursedDropTable ) do
	LinkLuaModifier( relic, "relics/cursed/"..relic, LUA_MODIFIER_MOTION_NONE )
  end
  
  for relic, weight in pairs( self.uniqueDropTable ) do
	LinkLuaModifier( relic, "relics/unique/"..relic, LUA_MODIFIER_MOTION_NONE )
  end
  
  CustomGameEventManager:RegisterListener('player_selected_relic', Context_Wrap( RelicManager, 'ConfirmRelicSelection'))
  CustomGameEventManager:RegisterListener('player_skipped_relic', Context_Wrap( RelicManager, 'SkipRelicSelection'))
  CustomGameEventManager:RegisterListener('player_notify_relic', Context_Wrap( RelicManager, 'NotifyRelics'))
  
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

	local relicTable = CustomNetTables:GetTableValue( "game_info", "relic_drops") or {}
	local playerRelics = relicTable[tostring(pID)] or {}
	
	local toNumPlayerRelics = {}
	for dropID, dropTable in pairs(playerRelics) do
		toNumPlayerRelics[tonumber(dropID)] = dropTable
	end
	
	
	
	table.remove( toNumPlayerRelics, 1 )
	relicTable[tostring(pID)] = toNumPlayerRelics
	CustomNetTables:SetTableValue("game_info", "relic_drops", relicTable)
	
	hero.internalRelicRNG = BASE_RELIC_CHANCE
end

function RelicManager:SkipRelicSelection(userid, event)
	local pID = event.pID
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	local relicTable = CustomNetTables:GetTableValue( "game_info", "relic_drops") or {}
	local playerRelics = relicTable[tostring(pID)] or {}

	local toNumPlayerRelics = {}
	for dropID, dropTable in pairs(playerRelics) do
		toNumPlayerRelics[tonumber(dropID)] = dropTable
	end
	
	hero.internalRNGPools[1][toNumPlayerRelics[1]["1"]] = nil
	hero.internalRNGPools[2][toNumPlayerRelics[1]["2"]] = nil
	hero.internalRNGPools[3][toNumPlayerRelics[1]["3"]] = nil
	
	table.remove( toNumPlayerRelics, 1 )
	relicTable[tostring(pID)] = toNumPlayerRelics
	CustomNetTables:SetTableValue("game_info", "relic_drops", relicTable)
	
	if hero:HasRelic("relic_unique_mysterious_hourglass") and hero:FindModifierByName("relic_unique_mysterious_hourglass"):GetStackCount() > 0 then
		hero:FindModifierByName("relic_unique_mysterious_hourglass"):DecrementStackCount()
		self:RollRelicsForPlayer(pID)
	end
	
	hero.internalRelicRNG = math.min( (hero.internalRelicRNG or BASE_RELIC_CHANCE) + SKIP_RELIC_CHANCE_INCREASE, 100 )
end

function RelicManager:RegisterPlayer(pID)
	local relicTable = CustomNetTables:GetTableValue( "game_info", "relic_drops") or {}
	relicTable[tostring(pID)] = {}
	CustomNetTables:SetTableValue("game_info", "relic_drops", relicTable)
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	hero.internalRelicRNG = BASE_RELIC_CHANCE
	hero.internalRNGPools = {}
	table.insert(hero.internalRNGPools, self.genericDropTable)
	table.insert(hero.internalRNGPools, self.cursedDropTable)
	table.insert(hero.internalRNGPools, self.uniqueDropTable)
	RelicManager:RollRelicsForPlayer(pID)
end

function RelicManager:RollRelicsForPlayer(pID)
	local hero = PlayerResource:GetSelectedHeroEntity(pID)

	if not hero then return end

	hero.ownedRelics = hero.ownedRelics or {}
	local relicTable = CustomNetTables:GetTableValue( "game_info", "relic_drops") or {}
	local playerRelics = relicTable[tostring(pID)] or {}

	local toNumPlayerRelics = {}
	for dropID, dropTable in pairs(playerRelics) do
		toNumPlayerRelics[tonumber(dropID)] = dropTable
	end
	
	local dropTable = {}
	table.insert( dropTable, self:RollRandomGenericRelicForPlayer(pID) )
	table.insert( dropTable, self:RollRandomCursedRelicForPlayer(pID) )
	table.insert( dropTable, self:RollRandomUniqueRelicForPlayer(pID) )
	
	table.insert( toNumPlayerRelics, dropTable )

	relicTable[tostring(pID)] = toNumPlayerRelics

	CustomNetTables:SetTableValue("game_info", "relic_drops", relicTable)
end

function RelicManager:RollRandomGenericRelicForPlayer(pID)
	local dropTable = {}
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	hero.ownedRelics = hero.ownedRelics or {}
	for relic, weight in pairs( hero.internalRNGPools[1] ) do
		for i = 1, weight do
			table.insert(dropTable, relic)
		end
	end
	if dropTable[1] == nil then
		hero.internalRNGPools[1] = self.genericDropTable
		return self:RollRandomGenericRelicForPlayer(pID)
	end
	return dropTable[RandomInt(1, #dropTable)]
end

function RelicManager:RollRandomCursedRelicForPlayer(pID)
	local dropTable = {}
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	hero.ownedRelics = hero.ownedRelics or {}
	for relic, weight in pairs( hero.internalRNGPools[2] ) do
		for i = 1, weight do
			table.insert(dropTable, relic)
		end
	end
	if dropTable[1] == nil then
		hero.internalRNGPools[2] = self.cursedDropTable
		return self:RollRandomGenericRelicForPlayer(pID)
	end
	return dropTable[RandomInt(1, #dropTable)]
end

function RelicManager:RollRandomUniqueRelicForPlayer(pID)
	local dropTable = {}
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	hero.ownedRelics = hero.ownedRelics or {}
	for relic, weight in pairs( hero.internalRNGPools[3] ) do
		for i = 1, weight do
			table.insert(dropTable, relic)
		end
	end
	if dropTable[1] == nil then
		hero.internalRNGPools[3] = self.uniqueDropTable
		return self:RollRandomGenericRelicForPlayer(pID)
	end
	return dropTable[RandomInt(1, #dropTable)]
end

function CDOTA_BaseNPC_Hero:HasRelic(relic)
	self.ownedRelics = self.ownedRelics or {}
	return (self.ownedRelics[relic] ~= nil)
end

function RelicManager:ClearRelics(pID)
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	relicCount = 0
	for relic, item in pairs( hero.ownedRelics ) do
		if relic ~= "relic_cursed_cursed_dice" then -- cursed dice cannot be removed
			relicCount = relicCount + 1
			hero:RemoveModifierByName( relic )
			UTIL_Remove( EntIndexToHScript(item) )
		end
	end
	hero.internalRNGPools[1] = self.genericDropTable
	hero.internalRNGPools[2] = self.cursedDropTable
	hero.internalRNGPools[3] = self.uniqueDropTable
	hero.ownedRelics = {}
	CustomNetTables:SetTableValue("relics", "relic_inventory_player_"..hero:entindex(), {})
	return relicCount
end

function RelicManager:RemoveRelicOnPlayer(relic, pID)
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	hero:RemoveModifierByName( relic )
	UTIL_Remove( EntIndexToHScript(hero.ownedRelics[relic]) )
	
	if string.match(relic, "unique") then
		hero.internalRNGPools[3][relic] = "1"
	elseif string.match(relic, "cursed") then
		hero.internalRNGPools[2][relic] = "1"
	else
		hero.internalRNGPools[1][relic] = "1"
	end
	
	hero.ownedRelics[relic] = nil
	CustomNetTables:SetTableValue("relics", "relic_inventory_player_"..hero:entindex(), hero.ownedRelics)
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
	self.ownedRelics[relic] = relicEntity:entindex()
	self:AddNewModifier( self, relicEntity, relic, {} )
	
	CustomNetTables:SetTableValue("relics", "relic_inventory_player_"..self:entindex(), self.ownedRelics)
end

