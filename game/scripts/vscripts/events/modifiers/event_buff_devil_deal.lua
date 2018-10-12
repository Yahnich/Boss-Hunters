event_buff_devil_deal = class(relicBaseClass)

function event_buff_devil_deal:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE}
end

function event_buff_devil_deal:GetModifierHealthBonus_Percentage()
	return -0.3
end

function event_buff_devil_deal:IsDebuff( )
    return true
end