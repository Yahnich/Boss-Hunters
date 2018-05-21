relic_cursed_red_key = class(relicBaseClass)

function relic_cursed_red_key:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function relic_cursed_red_key:GetModifierTotalDamageOutgoing_Percentage(params)
	if self:GetStackCount() == 1 then
		return -25
	end
end

function relic_cursed_red_key:IsHidden()
	return self:GetStackCount() ~= 1
end