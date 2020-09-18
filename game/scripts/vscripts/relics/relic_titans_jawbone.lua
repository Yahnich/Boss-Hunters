relic_titans_jawbone = class(relicBaseClass)

function relic_titans_jawbone:OnCreated()
	self:GetParent():HookInModifier("GetModifierExtraHealthBonusPercentage", self)
end

function relic_titans_jawbone:OnDestroy()
	self:GetParent():HookOutModifier("GetModifierExtraHealthBonusPercentage", self)
end

function relic_titans_jawbone:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function relic_titans_jawbone:GetModifierExtraHealthBonusPercentage()
	return 50
end

function relic_titans_jawbone:GetModifierTotalDamageOutgoing_Percentage()
	if not self:GetParent():HasModifier("relic_ritual_candle") then return -33 end
end