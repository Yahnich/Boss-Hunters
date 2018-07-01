event_buff_ominous_tome_blessing = class(relicBaseClass)

function event_buff_ominous_tome_blessing:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }

    return funcs
end

function event_buff_ominous_tome_blessing:GetModifierPreAttack_BonusDamage( params )
    return 80
end

event_buff_ominous_tome_curse = class(relicBaseClass)

function event_buff_ominous_tome_curse:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_BONUS
    }

    return funcs
end

function event_buff_ominous_tome_curse:GetModifierHealthBonus( params )
    return -600
end

function event_buff_ominous_tome_curse:IsDebuff( )
    return true
end