event_buff_demonic_horde = class(relicBaseClass)

function event_buff_demonic_horde:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    }

    return funcs
end

function event_buff_demonic_horde:GetModifierManaBonus( params )
    return 500
end

function event_buff_demonic_horde:GetModifierMoveSpeedBonus_Constant( params )
    return 30
end