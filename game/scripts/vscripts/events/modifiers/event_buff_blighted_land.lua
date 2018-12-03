event_buff_blighted_land_blessing_1 = class(relicBaseClass)

function event_buff_blighted_land_blessing_1:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
    }

    return funcs
end

function event_buff_blighted_land_blessing_1:GetModifierExtraHealthBonus( params )
    return 800
end

event_buff_blighted_land_blessing_2 = class(relicBaseClass)

function event_buff_blighted_land_blessing_2:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

    return funcs
end

function event_buff_blighted_land_blessing_2:GetModifierBonusStats_Intellect( )
    return 15
end

function event_buff_blighted_land_blessing_2:GetModifierBonusStats_Strength( )
    return 15
end

function event_buff_blighted_land_blessing_2:GetModifierBonusStats_Agility( )
    return 15
end

event_buff_blighted_land_curse = class(relicBaseClass)

function event_buff_blighted_land_curse:GetModifierHealAmplify_Percentage( params )
    return -25
end

function event_buff_blighted_land_curse:IsDebuff( )
    return true
end