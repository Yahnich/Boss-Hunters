boss_necro_deathbringer = class({})

function boss_necro_deathbringer:GetIntrinsicModifierName()
	return "modifier_boss_necro_deathbringer"
end

modifier_boss_necro_deathbringer = class({})
LinkLuaModifier("modifier_boss_necro_deathbringer", "bosses/boss_necro/boss_necro_deathbringer", LUA_MODIFIER_MOTION_NONE )

