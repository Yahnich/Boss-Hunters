event_buff_devil_deal = class(relicBaseClass)

function event_buff_devil_deal:GetModifierHealthBonus_Percentage()
	return -30
end

function event_buff_devil_deal:IsDebuff( )
    return true
end