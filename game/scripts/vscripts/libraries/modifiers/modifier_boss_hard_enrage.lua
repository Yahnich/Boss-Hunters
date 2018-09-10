modifier_boss_hard_enrage = class({})

function modifier_boss_hard_enrage:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }

    return funcs
end

function modifier_boss_hard_enrage:GetModifierPercentageCooldown()
  return 50
end

function modifier_boss_hard_enrage:GetModifierAttackSpeedBonus_Constant()
	return 200
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