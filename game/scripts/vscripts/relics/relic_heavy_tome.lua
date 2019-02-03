relic_heavy_tome = class(relicBaseClass)

function relic_heavy_tome:OnCreated()
	self.int = self:GetParent():GetIntellect()
	if IsServer() then self:GetParent():CalculateStatBonus() end
	self:StartIntervalThink(0.33)
end

function relic_heavy_tome:OnIntervalThink()
	self.int = 0
	self.int = self:GetParent():GetIntellect()
	self.slow = math.min( -10, -100 + (self:GetParent():GetMana() / self:GetParent():GetMaxMana()) * (100) )
	if self:GetParent():HasModifier("relic_ritual_candle") then self.slow = 0 end
	if IsServer() then self:GetParent():CalculateStatBonus() end
end

function relic_heavy_tome:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function relic_heavy_tome:GetModifierBonusStats_Intellect()
	return self.int
end

function relic_heavy_tome:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end
