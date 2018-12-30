event_buff_stick = class(relicBaseClass)

function event_buff_stick:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,}
end

function event_buff_stick:GetModifierPreAttack_BonusDamage()
	return 35
end

function event_buff_stick:GetModifierAttackSpeedBonus()
	return 35
end

function event_buff_stick:GetModifierMoveSpeedBonus_Constant()
	return 35
end