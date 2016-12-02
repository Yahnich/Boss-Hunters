perk_enrage = class({})

LinkLuaModifier( "modifier_perk_enrage", "lua_abilities/heroes/modifiers/modifier_perk_enrage.lua" ,LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function perk_enrage:GetIntrinsicModifierName()
	return "modifier_perk_enrage"
end
