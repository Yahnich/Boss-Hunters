modifier_invisibility_custom = class({})

function modifier_invisibility_custom:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
    }

    return funcs
end

function modifier_invisibility_custom:CheckState()
	local state = { [MODIFIER_STATE_INVISIBLE] = true}
	
	return state
end

function modifier_invisibility_custom:GetModifierInvisibilityLevel( params )
    return 1
end

function modifier_invisibility_custom:IsHidden()
    return true
end

function modifier_invisibility_custom:IsPurgable()
    return false
end