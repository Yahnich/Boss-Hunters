relic_heavy_tome = class(relicBaseClass)

function relic_heavy_tome:OnCreated()
	self:StartIntervalThink(0.33)
	self:GetParent():HookInModifier("GetModifierIntellectBonusPercentage", self)
end

function relic_heavy_tome:OnDestroy()
	self:GetParent():HookOutModifier("GetModifierIntellectBonusPercentage", self)
end

function relic_heavy_tome:OnIntervalThink()
	self.slow = math.min( -10, -100 + (self:GetParent():GetMana() / self:GetParent():GetMaxMana()) * (100) * 2 )
	if self:GetParent():HasModifier("relic_ritual_candle") then self.slow = 0 end
end

function relic_heavy_tome:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function relic_heavy_tome:GetModifierIntellectBonusPercentage()
	return 100
end

function relic_heavy_tome:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end
