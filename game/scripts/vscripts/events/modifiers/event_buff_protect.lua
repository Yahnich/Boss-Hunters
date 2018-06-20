event_buff_protect = class(relicBaseClass)

function event_buff_protect:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS
    }

    return funcs
end

function event_buff_protect:GetModifierHealthBonus( params )
    return 200
end

function event_buff_protect:GetModifierManaBonus( params )
    return 200
end