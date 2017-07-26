RelicPool = RelicPool or class({})

RelicPools = {
["RELIC_POOL_TANK"] = 1,
["RELIC_POOL_CASTER"] = 2,
["RELIC_POOL_DPS"] = 3,
["RELIC_POOL_OTHER"] = 0,
}

local InternalTranslator = {
	[1] = "RELIC_POOL_TANK",
	[2] = "RELIC_POOL_CASTER",
	[3] = "RELIC_POOL_DPS",
	[0] = "RELIC_POOL_OTHER",
}

function RelicPool:constructor(data)
	self:PopulatePools()
	print("pool initialized")
end

function RelicPool:GetDPSPool()
	return self.dpsPool
end

function RelicPool:DropDPSRelic()
	return self.dpsPool[RandomInt(1, #self.dpsPool)]
end

function RelicPool:GetTankPool()
	return self.tankPool
end

function RelicPool:DropTankRelic(hero)
	local dropType = self.tankPool[RandomInt(1, #self.tankPool)]
	return RelicEntity({relicType = dropType, owner = hero})
end

function RelicPool:GetCasterPool()
	return self.casterPool
end

function RelicPool:DropCasterRelic()
	return self.casterPool[RandomInt(1, #self.casterPool)]
end

function RelicPool:GetOtherPool()
	return self.otherPool
end

function RelicPool:DropOtherRelic()
	return self.otherPool[RandomInt(1, #self.otherPool)]
end

function RelicPool:DropRelicFromPool(relicPool, hero)
	local dropKey = InternalTranslator[relicPool]
	local dropRelic
	if dropKey == -1 then dropKey = RandomInt(0, 3) end
	if dropKey == "RELIC_POOL_TANK" then
		local dropType = self.tankPool[RandomInt(1, #self.tankPool)]
		return RelicEntity({relicType = dropType, owner = hero})
	elseif dropKey == "RELIC_POOL_CASTER" then
		return self.casterPool[RandomInt(1, #self.casterPool)]
	elseif dropKey == "RELIC_POOL_DPS" then
		return self.dpsPool[RandomInt(1, #self.dpsPool)]
	elseif dropKey == "RELIC_POOL_OTHER" then
		return self.otherPool[RandomInt(1, #self.otherPool)]
	end
end

function RelicPool:PopulatePools()
	local internalTable = LoadKeyValues('scripts/kv/relicpool.kv')
	self.allPools = {}
	self.casterPool = {}
	self.dpsPool = {}
	self.tankPool = {}
	self.otherPool = {}
	for relicPoolName, relicPoolRelics in pairs(internalTable) do
		for relic, weight in pairs(relicPoolRelics) do
			for i = 1, tonumber(weight) do
				if relicPoolName == "RELIC_POOL_TANK" then
					table.insert(self.tankPool, relic)
				elseif relicPoolName == "RELIC_POOL_CASTER" then
					table.insert(self.casterPool, relic)
				elseif relicPoolName == "RELIC_POOL_DPS" then
					table.insert(self.dpsPool, relic)
				elseif relicPoolName == "RELIC_POOL_OTHER" then
					table.insert(self.otherPool, relic)
				end
				table.insert(self.allPools, relic)
			end
		end
	end
end


-- LinkLuaModifier("","relics/tankPool/",0)

