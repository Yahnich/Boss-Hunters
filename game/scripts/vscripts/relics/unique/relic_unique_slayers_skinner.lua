relic_unique_slayers_skinner = class(relicBaseClass)

function relic_unique_slayers_skinner:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function relic_unique_slayers_skinner:GetModifierTotalDamageOutgoing_Percentage(params)
	if params.target:IsWild() or params.target:IsUndead() or params.target:IsCelestial() or params.target:IsDemon() then
		return 10
	end
end