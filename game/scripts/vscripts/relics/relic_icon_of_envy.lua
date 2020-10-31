relic_icon_of_envy = class(relicBaseClass)

function relic_icon_of_envy:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function relic_icon_of_envy:GetModifierBonusStats_Strength()
	local baseLoss = -20
	if self:GetParent():HasModifier("relic_ritual_candle") then baseLoss = 0 end
	return baseLoss + 10 * self:GetStackCount()
end

function relic_icon_of_envy:GetModifierBonusStats_Agility()
	local baseLoss = -20
	if self:GetParent():HasModifier("relic_ritual_candle") then baseLoss = 0 end
	return baseLoss + 10 * self:GetStackCount()
end

function relic_icon_of_envy:GetModifierBonusStats_Intellect()
	local baseLoss = -20
	if self:GetParent():HasModifier("relic_ritual_candle") then baseLoss = 0 end
	return baseLoss + 10 * self:GetStackCount()
end

function relic_icon_of_envy:IsDebuff()
	return self:GetStackCount() <= 4
end