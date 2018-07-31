event_buff_tree_of_life_blessing_1 = class(relicBaseClass)

function event_buff_tree_of_life_blessing_1:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }

    return funcs
end

function event_buff_tree_of_life_blessing_1:GetModifierHealthBonus( params )
    return 400
end

function event_buff_tree_of_life_blessing_1:GetModifierConstantHealthRegen( params )
    return 5
end

event_buff_tree_of_life_blessing_2 = class(relicBaseClass)

function event_buff_tree_of_life_blessing_2:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    }

    return funcs
end

function event_buff_tree_of_life_blessing_2:GetModifierBonusStats_Intellect( params )
    return 15
end

function event_buff_tree_of_life_blessing_2:GetModifierSpellAmplify_Percentage( params )
    return 20
end

event_buff_tree_of_life_blessing_3 = class(relicBaseClass)


function event_buff_tree_of_life_blessing_3:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

    return funcs
end

function event_buff_tree_of_life_blessing_3:GetModifierBonusStats_Strength( params )
    return 8
end

function event_buff_tree_of_life_blessing_3:GetModifierBonusStats_Agility( params )
    return 8
end

function event_buff_tree_of_life_blessing_3:GetModifierBonusStats_Intellect( params )
    return 8
end