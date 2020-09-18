modifier_boss_hard_enrage = class({})

function modifier_boss_hard_enrage:GetTexture()
	return "axe_berserkers_call"
end

function modifier_boss_hard_enrage:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
    }

    return funcs
end

function modifier_boss_hard_enrage:GetModifierPercentageCooldown()
  return 33
end

function modifier_boss_hard_enrage:GetModifierAttackSpeedBonus_Constant()
	return 450
end

function modifier_boss_hard_enrage:GetModifierMoveSpeedBonus_Percentage()
	return 50
end

function modifier_boss_hard_enrage:GetModifierStatusResistanceStacking()
	return 50
end

function modifier_boss_hard_enrage:GetModifierHealAmplify_Percentage()
	return -50
end

function modifier_boss_hard_enrage:GetModifierStatusAmplify_Percentage()
	return -33
end

function modifier_boss_hard_enrage:GetEffectName()
	return "particles/units/bosses/boss_hard_enrage.vpcf"
end

function modifier_boss_hard_enrage:GetStatusEffectName()
	return "particles/status_fx/status_effect_avatar.vpcf"
end

function modifier_boss_hard_enrage:StatusEffectPriority()
	return 50
end

function modifier_boss_hard_enrage:IsHidden()
    return false
end

function modifier_boss_hard_enrage:IsPurgable()
	return false
end