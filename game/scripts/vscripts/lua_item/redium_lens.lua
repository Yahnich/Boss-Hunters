if item_redium_lens == nil then
    item_redium_lens = class({})
end

function item_redium_lens:GetBehavior() 
    local behav = DOTA_ABILITY_BEHAVIOR_PASSIVE
    return behav
end

function item_redium_lens_nostack:GetAttributes() 
    return 
end

function item_redium_lens_stack:GetAttributes() 
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function item_redium_lens_stack:IsHidden()
    return true
end
function item_redium_lens_nostack:IsHidden()
    return true
end

function item_redium_lens_stack:DeclareFunctions() --we want to use these functions in this item
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
    }

    return funcs
end

function item_redium_lens_nostack:DeclareFunctions() --we want to use these functions in this item
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
    }

    return funcs
end

