event_buff_defense_or_offense_1 = class(relicBaseClass)

function event_buff_defense_or_offense_1:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		
    }

    return funcs
end

function event_buff_defense_or_offense_1:GetModifierPreAttack_BonusDamage( params )
    return 40
end

function event_buff_defense_or_offense_1:GetModifierAttackSpeedBonus( params )
    return 40
end

event_buff_defense_or_offense_2 = class(relicBaseClass)

function event_buff_defense_or_offense_2:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }

    return funcs
end

function event_buff_defense_or_offense_2:GetModifierPhysicalArmorBonus( params )
    return 10
end

function event_buff_defense_or_offense_2:GetModifierMagicalResistanceBonus( params )
    return 20
end

event_buff_defense_or_offense_3 = class(relicBaseClass)

function event_buff_defense_or_offense_3:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

    return funcs
end

function event_buff_defense_or_offense_3:GetModifierBonusStats_Strength( params )
    return 10
end

function event_buff_defense_or_offense_3:GetModifierBonusStats_Agility( params )
    return 10
end

function event_buff_defense_or_offense_3:GetModifierBonusStats_Intellect( params )
    return 10
end