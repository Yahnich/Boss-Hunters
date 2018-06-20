event_buff_the_river_1 = class(relicBaseClass)

function event_buff_the_river_1:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }

    return funcs
end

function event_buff_the_river_1:GetModifierConstantHealthRegen( params )
    return 5
end

event_buff_the_river_2 = class(relicBaseClass)

function event_buff_the_river_2:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }

    return funcs
end

function event_buff_the_river_2:GetModifierMagicalResistanceBonus( params )
    return 10
end

event_buff_the_river_3 = class(relicBaseClass)

function event_buff_the_river_3:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    }

    return funcs
end

function event_buff_the_river_3:GetModifierMoveSpeedBonus_Constant( params )
    return 15
end
