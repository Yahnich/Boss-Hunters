relic_cursed_red_key = class(relicBaseClass)

function relic_cursed_red_key:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE}
end

function relic_cursed_red_key:GetModifierExtraHealthPercentage(params)
	if self:GetStackCount() == 1 and not self:GetParent():HasModifier("relic_unique_ritual_candle") then
		return -0.5
	end
end

function relic_cursed_red_key:IsHidden()
	return self:GetStackCount() ~= 1 and not self:GetParent():HasModifier("relic_unique_ritual_candle")
end