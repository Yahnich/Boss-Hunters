relic_chainsword = class(relicBaseClass)

function relic_chainsword:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function relic_chainsword:GetModifierTotalDamageOutgoing_Percentage(params)
	if params.target:IsUndead() then
		return 25
	end
end