event_buff_crossroads = class(relicBaseClass)

function event_buff_crossroads:GetModifierHealthBonus_Percentage()
	return -20
end

function event_buff_crossroads:IsDebuff( )
    return true
end