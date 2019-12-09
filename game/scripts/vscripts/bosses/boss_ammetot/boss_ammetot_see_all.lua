boss_ammetot_see_all = class({})

function boss_ammetot_see_all:GetIntrinsicModifierName()
	return "modifier_boss_ammetot_see_all"
end

modifier_boss_ammetot_see_all = class({})
LinkLuaModifier( "modifier_boss_ammetot_see_all", "bosses/boss_ammetot/boss_ammetot_see_all", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_ammetot_see_all:DeclareFunctions()
	return {MODIFIER_PROPERTY_BONUS_DAY_VISION, MODIFIER_PROPERTY_BONUS_NIGHT_VISION}
end

function modifier_boss_ammetot_see_all:IsAura()
	return true
end

function modifier_boss_ammetot_see_all:GetAuraRadius()
	return -1
end

function modifier_boss_ammetot_see_all:GetAuraDuration()
	return 0.5
end

function modifier_boss_ammetot_see_all:GetModifierAura()
	return "modifier_boss_ammetot_see_all_sight"
end

function modifier_boss_ammetot_see_all:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_boss_ammetot_see_all:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_boss_ammetot_see_all:GetBonusDayVision()
	return 9999
end

function modifier_boss_ammetot_see_all:GetBonusNightVision()
	return 9999
end

function modifier_boss_ammetot_see_all:IsHidden()
	return true
end

modifier_boss_ammetot_see_all_sight = class({})
LinkLuaModifier( "modifier_boss_ammetot_see_all_sight", "bosses/boss_ammetot/boss_ammetot_see_all", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_ammetot_see_all_sight:CheckState()
	return {[MODIFIER_STATE_INVISIBLE] = false}
end

function modifier_boss_ammetot_see_all_sight:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end

function modifier_boss_ammetot_see_all_sight:IsHidden()
	return true
end