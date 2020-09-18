event_buff_safe_haven_1 = class(relicBaseClass)

function event_buff_safe_haven_1:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
    }

    return funcs
end

function event_buff_safe_haven_1:GetModifierExtraHealthBonus( params )
    return 500
end

event_buff_safe_haven_2 = class(relicBaseClass)

function event_buff_safe_haven_2:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE
    }

    return funcs
end

function event_buff_safe_haven_2:GetModifierAttackSpeedBonus_Constant( params )
    return 30
end

function event_buff_safe_haven_2:GetModifierBaseAttack_BonusDamage( params )
    return 30
end

event_buff_safe_haven_3 = class(relicBaseClass)

function event_buff_safe_haven_3:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
    }

    return funcs
end

function event_buff_safe_haven_3:GetModifierManaBonus( params )
    return 350
end

function event_buff_safe_haven_3:GetModifierSpellAmplify_Percentage( params )
    return 15
end