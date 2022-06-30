relic_paupers_finger = class(relicBaseClass)

function relic_paupers_finger:GetBonusExp()
	return 100
end

function relic_paupers_finger:GetBonusGold()
	if not self then return end
	if not self:GetParent():HasModifier("relic_ritual_candle") then return -35 end
end