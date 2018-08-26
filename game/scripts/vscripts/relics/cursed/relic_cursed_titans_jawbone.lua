relic_cursed_titans_jawbone = class(relicBaseClass)

function relic_cursed_titans_jawbone:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function relic_cursed_titans_jawbone:GetModifierHealthBonus_Percentage()
	return 60
end

function relic_cursed_titans_jawbone:GetModifierTotalDamageOutgoing_Percentage()
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return -33 end
end