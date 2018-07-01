relic_cursed_paupers_finger = class(relicBaseClass)

function relic_cursed_paupers_finger:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXP_RATE_BOOST}
end

function relic_cursed_paupers_finger:GetBonusExp()
	return 50
end

function relic_cursed_paupers_finger:GetBonusGold()
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return -50 end
end