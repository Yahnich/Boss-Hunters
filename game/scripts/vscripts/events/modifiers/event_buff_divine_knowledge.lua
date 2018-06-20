event_buff_divine_knowledge_1 = class(relicBaseClass)

function event_buff_divine_knowledge_1:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
    }

    return funcs
end

function event_buff_divine_knowledge_1:GetModifierBaseDamageOutgoing_Percentage( params )
    return 25
end

event_buff_divine_knowledge_2 = class(relicBaseClass)

function event_buff_divine_knowledge_2:GetCooldownReduction( params )
    return 25
end

event_buff_divine_knowledge_3 = class(relicBaseClass)

function event_buff_divine_knowledge_3:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_EVASION_CONSTANT,
    }

    return funcs
end

function event_buff_divine_knowledge_3:GetModifierEvasion_Constant( params )
    return 25
end