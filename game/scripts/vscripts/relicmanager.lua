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

RELIC_RARITY_COMMON = 1
RELIC_RARITY_UNCOMMON = 2
RELIC_RARITY_RARE = 3
RELIC_RARITY_LEGENDARY = 4

BASE_COMMON_RELIC_WEIGHT = 30
BASE_UNCOMMON_RELIC_WEIGHT = 15
BASE_RARE_RELIC_WEIGHT = 4
BASE_LEGENDARY_RELIC_WEIGHT = 1

COMMON_RELIC_WEIGHT = 30
UNCOMMON_RELIC_WEIGHT = 15
RARE_RELIC_WEIGHT = 4
LEGENDARY_RELIC_WEIGHT = 1

NATURAL_CURSED_CHANCE = 25

function RelicManager:Initialize()
	RelicManager = self
	print("Relic Manager initialized")
	self.masterList = LoadKeyValues('scripts/npc/npc_relics_custom.txt')
	self.cursedRelicPool = {}
	self.otherRelicPool = {}
	
	-- adjust weights to keep in mind the raw amount of relics available
	local common = 0
	local uncommon = 0
	local rare = 0
	local legendary = 0
	local totalRelics = 0
	for relic, data in pairs( self.masterList ) do
		LinkLuaModifier( relic, "relics/"..relic, LUA_MODIFIER_MOTION_NONE )
		if data["Rarity"] ~= "RARITY_EVENT" then
			if data["Cursed"] == 1 then
				self.cursedRelicPool[relic] = data
			else
				self.otherRelicPool[relic] = data
			end
			if data["Rarity"] == "RARITY_LEGENDARY" then
				legendary = legendary + 1
			elseif data["Rarity"] == "RARITY_RARE"  then
				rare = rare + 1
			elseif data["Rarity"] == "RARITY_UNCOMMON"  then
				uncommon = uncommon + 1
			else
				common = common + 1
			end
			totalRelics = totalRelics + 1
		end
	end
	-- weight adjustment to account for differences in amount of relics per rarity tier; equalizes weights into chance percentage
	local legendaryAdjustment = totalRelics / legendary
	local rareAdjustment = totalRelics / rare
	local uncommonAdjustment = totalRelics / uncommon  
	local commonAdjustment = totalRelics / common  
	
	COMMON_RELIC_WEIGHT = math.floor( BASE_COMMON_RELIC_WEIGHT * commonAdjustment + 0.5 )
	UNCOMMON_RELIC_WEIGHT = math.floor( BASE_UNCOMMON_RELIC_WEIGHT * uncommonAdjustment + 0.5 )
	RARE_RELIC_WEIGHT = math.floor( BASE_RARE_RELIC_WEIGHT * rareAdjustment + 0.5 )
	LEGENDARY_RELIC_WEIGHT = math.floor( BASE_LEGENDARY_RELIC_WEIGHT * legendaryAdjustment + 0.5 )

	CustomGameEventManager:RegisterListener('player_selected_relic', Context_Wrap( RelicManager, 'ConfirmRelicSelection'))
	CustomGameEventManager:RegisterListener('player_skipped_relic', Context_Wrap( RelicManager, 'SkipRelicSelection'))
	CustomGameEventManager:RegisterListener('player_notify_relic', Context_Wrap( RelicManager, 'NotifyRelics'))
	CustomGameEventManager:RegisterListener('dota_player_query_relic_inventory', Context_Wrap( RelicManager, 'SendHeroRelicInventory'))
	CustomGameEventManager:RegisterListener('dota_player_query_relic_drops', Context_Wrap( RelicManager, 'SendHeroRelicDrops'))
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

function RelicManager:SendHeroRelicDrops(userid, event)
	local hero = EntIndexToHScript(event.entindex)
	local pID = event.playerID
	if hero and hero:GetPlayerOwner() == PlayerResource:GetPlayer(pID) then
		local player = PlayerResource:GetPlayer(pID)
		if player then
			CustomGameEventManager:Send_ServerToPlayer(player,"dota_player_request_relic_drops", {drops = hero.relicsToSelect, hero = hero:entindex()})
			CustomGameEventManager:Send_ServerToPlayer(player,"dota_player_updated_relic_drops", {drops = hero.relicsToSelect, hero = hero:entindex()})
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
end

function RelicManager:RemoveDropFromTable(pID, bRemove, sRemoveSpecific)
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	
	if not bRemove then
		for id, relicData in ipairs( hero.relicsToSelect[1] ) do
			local pool = "other"
			local rarity = self.masterList[relicData.name]["Rarity"]
			if self.masterList[relicData.name]["Cursed"] == "1" then
				pool = "cursed"
			end
			if relicData.name ~= sRemoveSpecific then
				hero.internalRNGPools[pool][relicData.name] = rarity
			end
		end
	end
	table.remove( hero.relicsToSelect, 1 )
	local player = PlayerResource:GetPlayer(pID)
	if player then
		CustomGameEventManager:Send_ServerToPlayer(player,"dota_player_request_relic_drops", {drops = hero.relicsToSelect, playerID = pID})
		CustomGameEventManager:Send_ServerToPlayer(player,"dota_player_updated_relic_drops", {drops = hero.relicsToSelect, playerID = pID})
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
	if hero:HasRelic("relic_mysterious_hourglass") and hero:FindModifierByName("relic_mysterious_hourglass"):GetStackCount() > 0 then
		hero:FindModifierByName("relic_mysterious_hourglass"):DecrementStackCount()
		local dropTable = {}
		for id, relicData in pairs( copy ) do
			local rarity = self.masterList[relicData.name]["Rarity"]
			local cursed = self.masterList[relicData.name]["Cursed"] == "1"
			table.insert( dropTable, self:RollRandomRelicForPlayer(pID, rarity, true, cursed) )
		end
		RelicManager:PushCustomRelicDropsForPlayer(pID, dropTable)
		return
	else
		hero:AddGold(500, true)
	end
	if hero:HasRelic("relic_icon_of_envy") then
		hero:FindModifierByName("relic_icon_of_envy"):IncrementStackCount()
	end
	if hero:HasRelic("relic_red_key") then
		hero:FindModifierByName("relic_red_key"):SetStackCount(1)
	end
end

function RelicManager:RegisterPlayer(pID)
	self:ResetRelicPool(pID, "cursed")
	self:ResetRelicPool(pID, "other")
end

function RelicManager:ResetRelicPool(pID, poolType)
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	hero.internalRNGPools = hero.internalRNGPools or {}
	hero.internalRNGPools[poolType] = {}
	for relic, data in pairs ( self[poolType.."RelicPool"] ) do
		hero.internalRNGPools[poolType][relic] = data["Rarity"]
	end
end

function RelicManager:RollBossRelicsForPlayer(pID)
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	local player = PlayerResource:GetPlayer(pID)
	if not hero then return end

	hero.ownedRelics = hero.ownedRelics or {}
	hero.relicsToSelect = hero.relicsToSelect or {}
	local dropTable = {}
	
	table.insert( dropTable, self:RollRandomRelicForPlayer(pID)	)
	table.insert( dropTable, self:RollRandomRelicForPlayer(pID)	)
	table.insert( dropTable, self:RollRandomRelicForPlayer(pID)	)
	
	RelicManager:PushCustomRelicDropsForPlayer(pID, dropTable)
end

function RelicManager:RollEliteRelicsForPlayer(pID)
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	local player = PlayerResource:GetPlayer(pID)
	if not hero then return end

	hero.ownedRelics = hero.ownedRelics or {}
	hero.relicsToSelect = hero.relicsToSelect or {}
	local dropTable = {}
	table.insert( dropTable, self:RollRandomRelicForPlayer(pID, "RARITY_RARE") )
	
	RelicManager:PushCustomRelicDropsForPlayer(pID, dropTable)
end

function RelicManager:PushCustomRelicDropsForPlayer(pID, relicTable)
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	local player = PlayerResource:GetPlayer(pID)
	if not hero then return end
	
	local greed = hero:HasRelic("relic_icon_of_greed")
	local pride = hero:HasRelic("relic_icon_of_pride")
	
	if hero:HasRelic("relic_red_key") then
		table.insert( relicTable, self:RollRandomRelicForPlayer(pID) )
	end
	hero.relicsToSelect = hero.relicsToSelect or {}
	table.insert( hero.relicsToSelect, aprilTable or relicTable )
	if ( (greed or pride) and not hero:HasRelic("relic_ritual_candle") ) then
		RelicManager:RemoveDropFromTable(pID, false)
	elseif player then
		CustomGameEventManager:Send_ServerToPlayer(player,"dota_player_updated_relic_drops", {playerID = pID, drops = hero.relicsToSelect})
	end
end

function RelicManager:RollRandomRelicForPlayer(pID, cMinRarity, bFixedRarity, bCursed, notThisRelic)
	print( pID,  "relic" )
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	hero.ownedRelics = hero.ownedRelics or {}
	
	local cRarity = cMinRarity or "RARITY_COMMON"
	local dropTable = {}
	local endRarity = cRarity
	
	-- Forced Cured relic
	local contractOn = hero:HasRelic("relic_forbidden_contract") and not hero:HasRelic("relic_ritual_candle")
	local cursedRelic = bCursed or contractOn or ( bCursed == nil and RollPercentage( NATURAL_CURSED_CHANCE ) )
	local pooltoDraw = "other"
	if cursedRelic then
		pooltoDraw = "cursed"
	end
	local loopPrevention = false
	:: fillDropTable ::
	for relic, rarity in pairs( hero.internalRNGPools[pooltoDraw] ) do
		if not bFixedRarity then
			local weight = COMMON_RELIC_WEIGHT
			if rarity == "RARITY_LEGENDARY" then
				weight = LEGENDARY_RELIC_WEIGHT
			elseif rarity == "RARITY_RARE" then
				weight = RARE_RELIC_WEIGHT
			elseif rarity == "RARITY_UNCOMMON" then
				weight = UNCOMMON_RELIC_WEIGHT
				if cRarity == "RARITY_RARE" then
					weight = 0
				end
			elseif cRarity ~= "RARITY_COMMON" then
				weight = 0
			end
			local relicData = {}
			relicData.name = relic
			relicData.rarity = rarity
			relicData.cursed = cursedRelic
			if weight > 0 then
				for i = 1, weight do
					table.insert( dropTable, relicData )
				end
			end
		elseif rarity == cRarity then
			local relicData = {}
			relicData.name = relic
			relicData.rarity = rarity
			relicData.cursed = cursedRelic
			table.insert( dropTable, relicData )
		end
	end
	
	if dropTable[1] == nil and not loopPrevention then
		self:ResetRelicPool(pID, pooltoDraw)
		loopPrevention = true
		print("resetting")
		goto fillDropTable
	end
	
	if notThisRelic then
		for i = #dropTable, 1, -1 do
			if dropTable[i] == notThisRelic then
				table.remove(dropTable, i)
			end
		end
	end
	
	if dropTable[1] ~= nil then
		-- remove for aprils fools
		-- local mimicChest = {}
		-- mimicChest.name = "relic_mimic_chest"
		-- mimicChest.rarity = "RARITY_LEGENDARY"
		-- mimicChest.cursed = true
		local droppedRelic = dropTable[RandomInt(1, #dropTable)]
		hero.internalRNGPools[pooltoDraw][droppedRelic.name] = nil
		return droppedRelic
	else
		return {["name"] = "unique_relic_not_found", ["RARITY_EVENT"] = "Special", ["cursed"] = false}
	end
end

function CDOTA_BaseNPC_Hero:HasRelic(relic)
	self.ownedRelics = self.ownedRelics or {}
	return self:HasModifier(relic)
end

function RelicManager:ClearRelics(pID, bHardClear)
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	relicCount = 0
	for item, relicData in pairs( hero.ownedRelics ) do
		if (relicData.name == "relic_cursed_dice" and bHardClear) or relicData.name ~= "relic_cursed_dice" then -- cursed dice cannot be removed
			relicCount = relicCount + 1
			if relicData.modifier and not relicData.modifier:IsNull() then 
				relicData.modifier:Destroy()
			else
				hero:FindModifierByNameAndAbility(relicData.name, item)
			end
			UTIL_Remove( EntIndexToHScript(item) )
			hero.ownedRelics[item] = nil
		end
	end
	self:ResetRelicPool(pID, "cursed")
	self:ResetRelicPool(pID, "other")
	CustomGameEventManager:Send_ServerToAllClients( "dota_player_update_relic_inventory", { hero = hero:entindex(), relics = hero.ownedRelics } )
	return relicCount
end

function RelicManager:RemoveRelicOnPlayer(relic, pID, bAll)
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	
	local pool = "other"
	local rarity = self.masterList[relic]["Rarity"]
	if self.masterList[relic]["Cursed"] == "1" then
		pool = "cursed"
	end
	for entindex, relicData in pairs(hero.ownedRelics) do
		if relicData.name == relic then
			local item = EntIndexToHScript(entindex)
			relicData.modifier:Destroy()
			UTIL_Remove( item )
			hero.internalRNGPools[pool][relicData.name] = rarity
			hero.ownedRelics[entindex] = nil
			if not bAll then break end
		end
	end
	CustomGameEventManager:Send_ServerToAllClients( "dota_player_update_relic_inventory", { hero = hero:entindex(), relics = hero.ownedRelics } )
end

function CDOTA_BaseNPC_Hero:AddRelic(relic)
	self.ownedRelics = self.ownedRelics or {}
	
	if self:HasRelic("relic_red_key") then
		self:FindModifierByName("relic_red_key"):SetStackCount(0)
	end
	
	local relicEntity = CreateItem("item_relic_handler", nil, nil)
	local relicData = {}
	relicData.modifier = self:AddNewModifier( self, relicEntity, relic, {} )
	relicData.name = relic
	relicData.rarity = RelicManager.masterList[relic]["Rarity"]
	relicData.cursed = RelicManager.masterList[relic]["Cursed"]
	self.ownedRelics[relicEntity:entindex()] = relicData
	
	if relicData.cursed == 1 then
		self.internalRNGPools["cursed"][relic] = nil
	else
		self.internalRNGPools["other"][relic] = nil
	end
	
	CustomGameEventManager:Send_ServerToAllClients( "dota_player_update_relic_inventory", { hero = self:entindex(), relics = self.ownedRelics } )
end
