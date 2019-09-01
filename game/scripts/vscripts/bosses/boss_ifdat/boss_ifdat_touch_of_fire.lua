boss_ifdat_touch_of_fire = class({})

function boss_ifdat_touch_of_fire:GetIntrinsicModifierName()
	return "modifier_boss_ifdat_touch_of_fire"
end

modifier_boss_ifdat_touch_of_fire = class({})
LinkLuaModifier( "modifier_boss_ifdat_touch_of_fire", "bosses/boss_ifdat/boss_ifdat_touch_of_fire", LUA_MODIFIER_MOTION_NONE )