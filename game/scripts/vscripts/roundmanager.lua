if RoundManager == nil then
	print ( 'creating round manager' )
	RoundManager = {}
	RoundManager.__index = RoundManager
end

function RoundManager:new( o )
	o = o or {}
	setmetatable( o, RoundManager )
	return o
end

require("events/base_event")

function RoundManager:Initialize()
	RoundManager = self
	self.bossPool = LoadKeyValues('scripts/kv/boss_pool.txt')
	self.eventPool = LoadKeyValues('scripts/kv/event_pool.txt')
	self.combatPool = LoadKeyValues('scripts/kv/combat_pool.txt')
	
	self.zones = {}
	local zonesToSpawn = ZONE_COUNT
	for i = 1, ZONE_COUNT do
		local zoneID = RandomInt(1, #POSSIBLE_ZONES)
		local zoneName = POSSIBLE_ZONES[zoneID]
		table.remove(POSSIBLE_ZONES, zoneID)
		RoundManager:ConstructRaids(zoneName)
		if zonesToSpawn <= 0 then
			break
		end
	end
	local testEvent = BaseEvent("event", "test_event")
end

EVENTS_PER_RAID = 5
RAIDS_PER_ZONE = 4
ZONE_COUNT = 3

POSSIBLE_ZONES = {"Elysium", "Sepulcher", "Grove", "Solitude"}

COMBAT_CHANCE = 70
ELITE_CHANCE = 20
EVENT_CHANCE = 100 - COMBAT_CHANCE


function RoundManager:ConstructRaids(zoneName)
	self.zones[zoneName] = {}
	
	local bossPool = {}
	local eventPool = {}
	local combatPool = {}
	
	for event, weight in ipairs( MergeTables(self.bossPool[zoneName], self.bossPool["Generic"]) ) do
		for i = 1, weight do
			table.insert(bossPool, event)
		end
	end
	
	for event, weight in ipairs( MergeTables(self.eventPool[zoneName], self.eventPool["Generic"]) ) do
		for i = 1, weight do
			table.insert(eventPool, event)
		end
	end
	
	for event, weight in ipairs( MergeTables(self.combatPool[zoneName], self.combatPool["Generic"]) ) do
		for i = 1, weight do
			table.insert(combatPool, event)
		end
	end
	
	for j = 1, RAIDS_PER_ZONE do
		local raid = {}
		local raidContent
		for i = 1, EVENTS_PER_RAID do
			local eventID = "id_"..i
			if RollPercentage(COMBAT_CHANCE) then -- Rolled Combat
				local combatType = "combat"
				if RollPercentage(ELITE_CHANCE) then
					combatType = "elite"
				end
				eventID = combatType.."_"..eventID
				raidContent = BaseEvent(zoneName, combatType, combatPool[RandomInt(1, #combatPool)] )
			else -- Event
				eventID = "event_"..eventID
				raidContent = BaseEvent(zoneName, "event", eventPool[RandomInt(1, #eventPool)] ) 
			end
			raid[eventID] = raidContent
		end
		raid["boss_id_"..(EVENTS_PER_RAID + 1)] = BaseEvent(zoneName, "boss", bossPool[RandomInt(1, #bossPool)] )
		
		table.insert( self.zones[zoneName], raid )
	end
end

function RoundManager:RemoveEventFromPool(eventToRemove, pool)	
	for zone, zoneEvents in pairs( self[pool.."Pool"] ) do
		for event, weight in pairs( zoneEvents ) do
			if event == eventToRemove then
				zoneEvents[èvent] = nil
			end
		end
	end
end

function RoundManager:StartGame()
end

function RoundManager:StartPrepTime()
end

function RoundManager:EndPrepTime()
end

function RoundManager:StartEvent()
end

function RoundManager:EndEvent()
end

function RoundManager:GetEvent()
	return self.currentRound
end

