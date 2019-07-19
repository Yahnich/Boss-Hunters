boss_ammetot_unbound = class({})

function boss_ammetot_unbound:GetIntrinsicModifierName()
	return "modifier_boss_ammetot_unbound"
end

modifier_boss_ammetot_unbound = class({})
LinkLuaModifier( "modifier_boss_ammetot_unbound", "bosses/boss_ammetot/boss_ammetot_unbound", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_ammetot_unbound:CheckState()
	return {[MODIFIER_STATE_ROOTED] = false,
			[MODIFIER_STATE_DISARMED] = false,
			[MODIFIER_STATE_SILENCED] = false,
			[MODIFIER_STATE_FLYING] = true,
			[MODIFIER_STATE_UNSLOWABLE] = true,
			}
end

function modifier_boss_ammetot_unbound:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end

function modifier_boss_ammetot_unbound:IsHidden()
	return true
end