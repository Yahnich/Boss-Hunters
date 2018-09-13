event_buff_crossroads = class(relicBaseClass)

function event_buff_crossroads:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE}
end

function event_buff_crossroads:GetModifierHealthBonus_Percentage()
	return -0.2
end

function event_buff_crossroads:IsDebuff( )
    return true
end