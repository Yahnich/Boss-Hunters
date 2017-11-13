spectre_dispersion_ebf = class({})

LinkLuaModifier( "modifier_spectre_dispersion_ebf", "lua_abilities/heroes/modifiers/spectre_dispersion.lua" ,LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function spectre_dispersion_ebf:GetIntrinsicModifierName()
    return "modifier_spectre_dispersion_ebf"
end
