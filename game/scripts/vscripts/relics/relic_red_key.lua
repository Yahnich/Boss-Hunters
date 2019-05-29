relic_red_key = class(relicBaseClass)

function relic_red_key:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE}
end

function relic_red_key:GetModifierExtraHealthBonusPercentage(params)
	if self:GetStackCount() == 1 and not self:GetParent():HasModifier("relic_ritual_candle") then
		return -50
	end
end

function relic_red_key:IsHidden()
	return self:GetStackCount() ~= 1 and not self:GetParent():HasModifier("relic_ritual_candle")
end