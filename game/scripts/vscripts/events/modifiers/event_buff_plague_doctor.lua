event_buff_plague_doctor_curse = class(relicBaseClass)

function event_buff_plague_doctor_curse:DeclareFunctions()
	return {MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE}
end

function event_buff_plague_doctor_curse:GetModifierHPRegenAmplify_Percentage()
	return -100
end

function event_buff_plague_doctor_curse:IsDebuff( )
    return true
end

event_buff_plague_doctor_blessing = class(relicBaseClass)

function event_buff_plague_doctor_curse:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end

function event_buff_plague_doctor_curse:GetModifierPreAttack_BonusDamage()
	return 80
end

function event_buff_plague_doctor_curse:GetModifierSpellAmplify_Percentage()
	return 32
end

function event_buff_plague_doctor_curse:GetModifierMoveSpeedBonus_Constant()
	return 20
end