event_buff_ruined_cathedral = class(relicBaseClass)

function event_buff_ruined_cathedral:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }

    return funcs
end

function event_buff_ruined_cathedral:GetModifierConstantHealthRegen( params )
    return 2
end

function event_buff_ruined_cathedral:GetModifierMagicalResistanceBonus( params )
    return 5
end