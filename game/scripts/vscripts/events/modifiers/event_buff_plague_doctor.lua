event_buff_plague_doctor_curse = class(relicBaseClass)

function relic_cursed_whale_heart:DeclareFunctions()
	return {MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE}
end

function relic_cursed_whale_heart:GetModifierHPRegenAmplify_Percentage()
	return -100
end

function relic_cursed_whale_heart:IsDebuff( )
    return true
end

event_buff_plague_doctor_blessing = class(relicBaseClass)

function relic_cursed_whale_heart:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end

function relic_cursed_whale_heart:GetModifierPreAttack_BonusDamage()
	return 80
end

function relic_cursed_whale_heart:GetModifierSpellAmplify_Percentage()
	return 32
end

function relic_cursed_whale_heart:GetModifierMoveSpeedBonus_Constant()
	return 20
end