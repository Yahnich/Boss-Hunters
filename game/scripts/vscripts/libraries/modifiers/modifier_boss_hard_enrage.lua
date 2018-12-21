modifier_boss_hard_enrage = class({})

function modifier_boss_hard_enrage:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_boss_hard_enrage:GetModifierPercentageCooldown()
  return 33
end

function modifier_boss_hard_enrage:GetModifierAttackSpeedBonus()
	return 300
end

function modifier_boss_hard_enrage:GetModifierMoveSpeedBonus_Percentage()
	return 100
end

function modifier_boss_hard_enrage:GetEffectName()
	return "particles/items2_fx/mask_of_madness.vpcf"
end

function modifier_boss_hard_enrage:GetStatusEffectName()
	return "particles/status_fx/status_effect_bloodrage.vpcf"
end

function modifier_boss_hard_enrage:StatusEffectPriority()
	return 50
end

function modifier_boss_hard_enrage:IsHidden()
    return true
end

function modifier_boss_hard_enrage:IsPurgable()
	return false
end