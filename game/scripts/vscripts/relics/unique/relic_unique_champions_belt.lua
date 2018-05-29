relic_unique_champions_belt = class(relicBaseClass)

function relic_unique_champions_belt:OnCreated()
	self.str = self:GetParent():GetStrength() * 0.35
	self.agi = self:GetParent():GetAgility() * 0.35
	self.int = self:GetParent():GetIntellect() * -0.9
	if IsServer() then self:GetParent():CalculateStatBonus() end
	self:StartIntervalThink(0)
end

function relic_unique_champions_belt:OnIntervalThink()
	self.str = 0
	self.agi = 0
	self.int = 0
	
	self.str = self:GetParent():GetStrength() * 0.35
	self.agi = self:GetParent():GetAgility() * 0.35
	self.int = self:GetParent():GetIntellect() * -0.9
	if IsServer() then self:GetParent():CalculateStatBonus() end
end

function relic_unique_champions_belt:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function relic_unique_champions_belt:GetModifierBonusStats_Strength()
	return self.str
end

function relic_unique_champions_belt:GetModifierBonusStats_Agility()
	return self.agi
end

function relic_unique_champions_belt:GetModifierBonusStats_Intellect()
	return self.int
end