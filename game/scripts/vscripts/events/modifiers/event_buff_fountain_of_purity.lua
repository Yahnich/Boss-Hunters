event_buff_fountain_of_purity = class(relicBaseClass)

function event_buff_fountain_of_purity:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

    return funcs
end

function event_buff_fountain_of_purity:GetModifierBonusStats_Strength( params )
    return 5
end

function event_buff_fountain_of_purity:GetModifierBonusStats_Agility( params )
    return 5
end

function event_buff_fountain_of_purity:GetModifierBonusStats_Intellect( params )
    return 5
end