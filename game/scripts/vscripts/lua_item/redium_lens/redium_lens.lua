if item_testium_lens == nil then
    item_testium_lens = class({})
end

function item_testium_lens:GetBehavior() 
    local behav = DOTA_ABILITY_BEHAVIOR_PASSIVE
    return behav
end

LinkLuaModifier( "lua_redium_lens_modifier", "lua_item/redium_lens/lua_redium_lens_modifier.lua", LUA_MODIFIER_MOTION_NONE )

function item_testium_lens:GetIntrinsicModifierName()
    return "lua_redium_lens_modifier"
end
