setabilitylayout = class({})

--------------------------------------------------------------------------------
function setabilitylayout:DeclareFunctions(params)
local funcs = {
    MODIFIER_PROPERTY_ABILITY_LAYOUT,
    }
    return funcs
end

function setabilitylayout:IsHidden()
	return true
end

function setabilitylayout:GetModifierAbilityLayout(params)
    return 6
end
