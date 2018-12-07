event_buff_surge_of_knowledge_1 = class(relicBaseClass)

function event_buff_surge_of_knowledge_1:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    }

    return funcs
end

function event_buff_surge_of_knowledge_1:GetModifierBaseAttack_BonusDamage( params )
    return 50
end

event_buff_surge_of_knowledge_2 = class(relicBaseClass)

function event_buff_surge_of_knowledge_2:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }

    return funcs
end

function event_buff_surge_of_knowledge_2:GetModifierExtraHealthBonus( params )
    return 350
end

function event_buff_surge_of_knowledge_2:GetModifierPhysicalArmorBonus( params )
    return 3
end

function event_buff_surge_of_knowledge_2:GetModifierMagicalResistanceBonus( params )
    return 10
end

event_buff_surge_of_knowledge_3 = class(relicBaseClass)

function event_buff_surge_of_knowledge_3:GetBonusGold( params )
    return 15
end