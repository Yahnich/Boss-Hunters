perk_movement = class({})

LinkLuaModifier( "modifier_perk_movement", "lua_abilities/heroes/modifiers/modifier_perk_movement.lua" ,LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function perk_movement:GetIntrinsicModifierName()
	return "modifier_perk_movement"
end
