relic_unique_gazaer_tirdh = class(relicBaseClass)

function relic_unique_gazaer_tirdh:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function relic_unique_gazaer_tirdh:GetModifierTotalDamageOutgoing_Percentage(params)
	if params.target:IsDemon() then
		return 25
	end
end