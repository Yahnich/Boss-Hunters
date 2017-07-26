RelicEntity = RelicEntity or class({})

RelicTypes = {
["RELIC_TYPE_TANK"] = 1,
["RELIC_TYPE_CASTER"] = 2,
["RELIC_TYPE_DPS"] = 3,
["RELIC_TYPE_OTHER"] = 0,
["RELIC_TYPE_RANDOM"] = -1,
}

local InternalTranslator = {
	[1] = "RELIC_TYPE_TANK",
	[2] = "RELIC_TYPE_CASTER",
	[3] = "RELIC_TYPE_DPS",
	[0] = "RELIC_TYPE_OTHER",
}

function RelicEntity:constructor(data)
	self.owner = data.owner
	self.owner:SetRelic(self)
	self.type = data.relicType
	self.rarity = data.rarity or 1
	self.stats = {}
	self:RollStats()
	self.owner:AddNewModifier(self.owner, nil, self.type, data)
	print("relic creation done")
end

function RelicEntity:RollStats()
	local baseStats = self.rarity * 5
end

function RelicEntity:Destroy()
	UTIL_Remove(self)
end

function RelicEntity:GetType()
	return self.type
end

